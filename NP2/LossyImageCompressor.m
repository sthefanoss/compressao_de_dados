classdef LossyImageCompressor

    methods (Static, Access = private)
        function [values, prob] = getProbabilities(X, keyType, keyAccessCallback)
            dict = containers.Map('KeyType',keyType,'ValueType','double');
            for i=1:length(X)
                key = keyAccessCallback(X,i);
                if(isKey(dict,key))
                    dict(key) = dict(key) + 1;
                else
                    dict(key) = 1.0;
                end
            end
            prob = cell2mat(dict.values);
            prob = prob/sum(prob);
            [prob, indexes] = sort(prob,'descend');
            keys = dict.keys;
            values = keys(indexes);
        end
    end

    properties
        matrixSerializer MatrixSerializer
        rleEncoder RleEncoder
        eliasGammaEncoder EliasGammaEncoder
        blockTransformer BlockTransformer
        blockQuantizer BlockQuantizer
        blockScanner BlockScanner
        trainImages
        huffmanDictionary
        symbolsTotalCount
        symbolsValues
        symbolsProbabilities
        symbolsInformationQuantities
        symbolsEntropy
        rleTuplesTotalCount
        rleTuplesValues
        rleTuplesProbabilities
        rleTuplesInformationQuantities
        rleTuplesEntropy
    end

    methods
        function obj = LossyImageCompressor(blockSize, trainImages, escapeMethod)
            arguments
                blockSize (1,2)
                trainImages (1,:) cell
                escapeMethod char {mustBeMember(escapeMethod,{'without','expectedValue', 'lessFrequent'})} = 'without'
            end
            obj.trainImages = trainImages;
            obj.matrixSerializer = MatrixSerializer(blockSize);
            obj.rleEncoder = RleEncoder();
            obj.eliasGammaEncoder = EliasGammaEncoder();
            obj.blockTransformer = BlockTransformer(blockSize);
            obj.blockQuantizer = BlockQuantizer(blockSize);
            obj.blockScanner = BlockScanner(blockSize);
            indexes = 1:length(trainImages);
            totalRleTuples = {};
            for i=indexes
                image = trainImages{i};
                blocks = obj.matrixSerializer.splitMatrixIntoBlocks(image);
                for j=1:length(blocks)
                    transformedBlock = obj.blockTransformer.transform(blocks(:,:,j));
                    quantizedBlock = obj.blockQuantizer.quantize(transformedBlock);
                    blockScan = obj.blockScanner.scan(quantizedBlock);
                    blockRleTuples = obj.rleEncoder.encode(blockScan);
                    for k=1:length(blockRleTuples)
                        totalRleTuples{length(totalRleTuples)+1} = blockRleTuples{k};
                    end
                end
            end
            obj.rleTuplesTotalCount = length(totalRleTuples);
            [obj.rleTuplesValues, obj.rleTuplesProbabilities] = LossyImageCompressor.getProbabilities(string(totalRleTuples),'char',@(X,i) X(i));
            obj.rleTuplesInformationQuantities = -log2(obj.rleTuplesProbabilities);
            obj.rleTuplesEntropy = sum(obj.rleTuplesProbabilities.*obj.rleTuplesInformationQuantities);

            obj.huffmanDictionary = HuffmanDictionary.make(obj.rleTuplesValues,obj.rleTuplesProbabilities, escapeMethod);
        end

        function [compressedImage, compressionLength] = compressImage(obj, image)
                blocks = obj.matrixSerializer.splitMatrixIntoBlocks(image);
                rleTuples = {};
                for j=1:length(blocks)
                    transformedBlock = obj.blockTransformer.transform(blocks(:,:,j));
                    quantizedBlock = obj.blockQuantizer.quantize(transformedBlock);
                    blockScan = obj.blockScanner.scan(quantizedBlock);
                    blockRleTuples = obj.rleEncoder.encode(blockScan);
                    for k=1:length(blockRleTuples)
                        rleTuples{length(rleTuples)+1} = blockRleTuples{k};
                    end
                end
                compressedImage = obj.huffmanDictionary.encode(rleTuples);
                compressionLength = length(compressedImage);
                encodedImageSize = obj.eliasGammaEncoder.encodeList(size(image));
                compressedImage = [encodedImageSize, compressedImage];
        end

        function [compressedImage, compressionRatio] = compressImageByPath(obj, imagePath)
            image = imread(imagePath);
            [compressedImage, compressionRatio] = obj.compressImage(image);
        end

        function image = decompressImage(obj, compressedImage)
            [imageSize,compressedImage] = obj.eliasGammaEncoder.decodeList(compressedImage, 2);
            rleTuples = obj.huffmanDictionary.decode(compressedImage);
            stream = obj.rleEncoder.decode(rleTuples);
            scanSize = obj.matrixSerializer.blockSize(1)*obj.matrixSerializer.blockSize(2);
            blockScans = reshape(stream, scanSize, [])';
            blocks = zeros(obj.matrixSerializer.blockSize(1),obj.matrixSerializer.blockSize(2),length(blockScans));
            for i=1:length(blockScans)
                blockScan = obj.blockScanner.build(blockScans(i,:));
                dequantizedBlock = obj.blockQuantizer.dequantize(blockScan);
                blocks(:,:,i) = obj.blockTransformer.inverseTransform(dequantizedBlock);
            end
            image = uint8(obj.matrixSerializer.joinMatrixBlocks(blocks,imageSize));
        end
    
        function showBlocksAnalysis(obj)
            sprintf('Total of %d symbols, %d unique symbols. With entropy H=%f.',obj.symbolsTotalCount, length(obj.symbolsValues),obj.symbolsEntropy)
           
            indexes = 1:min(16, length(obj.symbolsValues));
            figure
            bar(obj.symbolsProbabilities(indexes))
            set(gca,'xticklabel', obj.symbolsValues(indexes),'XTick', indexes)
   
            Index = indexes';
            Probability = obj.symbolsProbabilities(indexes)';
            Symbol = obj.symbolsValues(indexes)';
            InformationQuantity = obj.symbolsInformationQuantities(indexes)';
            table(Index, Symbol, Probability, InformationQuantity)
        end

        function showRleTuplesAnalysis(obj)
            sprintf('Total of %d rle tuples, %d unique rle tuples. With entropy H=%f.', obj.rleTuplesTotalCount, length(obj.rleTuplesValues),obj.rleTuplesEntropy)
            indexes = 1:min(16, length(obj.rleTuplesValues));
            figure
            bar(obj.rleTuplesProbabilities(indexes))
            set(gca,'xticklabel', obj.rleTuplesValues(indexes),'XTick', indexes)

            Index = indexes';
            Probability = obj.rleTuplesProbabilities(indexes)';
            RleTuple = obj.rleTuplesValues(indexes)';
            InformationQuantity = obj.rleTuplesInformationQuantities(indexes)';
            table(Index, RleTuple, Probability, InformationQuantity)
        end

        function showHuffmanAnalysis(obj)
            if not(strcmp(obj.huffmanDictionary.escapeMethod,'without'))
                sprintf('Huffman dictionary with %d escape symbols. Average length of %f.', obj.huffmanDictionary.escapeLength,obj.huffmanDictionary.averageLength)
            else
                sprintf('Huffman dictionary without escape symbols. Average length of %f.', obj.huffmanDictionary.averageLength)
            end
        end

        function result = runImagesBenchmark(obj, imagePaths)
            arguments
                obj
                imagePaths (1,:) cell = obj.trainImages
            end
            indexes = 1:length(imagePaths);
            for i=indexes
                image = imread(imagePaths{i});
                blockSize = obj.matrixSerializer.blockSize;
                imageSize = ceil(size(image)./blockSize).*blockSize;
                imageSizeInBits(i) = imageSize(1)*imageSize(2);
                imageSymbols = obj.matrixSerializer.serialize(image > 150);
                rleTuples = obj.rleEncoder.encode(imageSymbols);
                tuplesCount(i) = length(rleTuples);
                estimatedCompressionLength(i) = tuplesCount(i)*obj.huffmanDictionary.averageLength;
                [imageCompressed, compressionLength(i)] = obj.compressImage(image);
                ratio(i) = compressionLength(i)/imageSizeInBits(i);
            end
            Index = indexes';
            ImageSizeInBits = imageSizeInBits';
            TuplesCount = tuplesCount';
            EstimatedCompressionLength = estimatedCompressionLength';
            CompressionLength= compressionLength';
            Ratio = ratio';
            result = table(Index, ImageSizeInBits, TuplesCount, EstimatedCompressionLength, CompressionLength, Ratio);
        end
    end
end