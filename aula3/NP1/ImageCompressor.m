classdef ImageCompressor

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
        trainImagePaths
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
        function obj = ImageCompressor(blockSize, trainImagePaths, escapeMethod)
            arguments
                blockSize (1,2)
                trainImagePaths (1,:) cell
                escapeMethod char {mustBeMember(escapeMethod,{'without','expectedValue', 'lessFrequent'})} = 'without'
            end
            obj.trainImagePaths = trainImagePaths;
            obj.matrixSerializer = MatrixSerializer(blockSize);
            obj.rleEncoder = RleEncoder();
            obj.eliasGammaEncoder = EliasGammaEncoder();
            indexes = 1:length(trainImagePaths);

            for i=indexes
                image = imread(trainImagePaths{i}) > 150;
                imageSymbols{i} = obj.matrixSerializer.serialize(image);
                rleTuples{i} = obj.rleEncoder.encode(imageSymbols{i});
            end
            totalSymbols = cell2mat(imageSymbols);
            obj.symbolsTotalCount = length(totalSymbols);
            [obj.symbolsValues, obj.symbolsProbabilities] = ImageCompressor.getProbabilities(totalSymbols,'uint64',@(X,i) X(i));
            obj.symbolsInformationQuantities = -log2(obj.symbolsProbabilities);
            obj.symbolsEntropy = sum(obj.symbolsProbabilities.*obj.symbolsInformationQuantities);
            
            totalRleTuples = [rleTuples{indexes}];
            obj.rleTuplesTotalCount = length(totalRleTuples);
            [obj.rleTuplesValues, obj.rleTuplesProbabilities] = ImageCompressor.getProbabilities(string(totalRleTuples),'char',@(X,i) X(i));
            obj.rleTuplesInformationQuantities = -log2(obj.rleTuplesProbabilities);
            obj.rleTuplesEntropy = sum(obj.rleTuplesProbabilities.*obj.rleTuplesInformationQuantities);

            obj.huffmanDictionary = HuffmanDictionary.make(obj.rleTuplesValues,obj.rleTuplesProbabilities, escapeMethod);
        end

        function [compressedImage, compressionLength] = compressImage(obj, image)
            image = image > 150;
            imageSymbols = obj.matrixSerializer.serialize(image);
            rleTuples = obj.rleEncoder.encode(imageSymbols);
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
            symbols = obj.rleEncoder.decode(rleTuples);
            image = obj.matrixSerializer.deserialize(symbols, imageSize);
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
                imagePaths (1,:) cell = obj.trainImagePaths
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