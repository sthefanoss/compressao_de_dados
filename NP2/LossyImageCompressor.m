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
        whiteBlockSeparator WhiteBlockSeparator
        transformBlockSize 
        blockSize
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
        transformMethod
    end

    methods
        function obj = LossyImageCompressor(blockSize, trainImages, escapeMethod,transformMethod, quantizerValueGenerator)
            arguments
                blockSize (1,1)
                trainImages (1,:) cell
                escapeMethod char {mustBeMember(escapeMethod,{'without','expectedValue', 'lessFrequent'})} = 'without'
                transformMethod char {mustBeMember(transformMethod,{'dct','wht'})} = 'dct'
                quantizerValueGenerator = @(i,j) 1 + 25*i + 25*j;
            end
            obj.transformMethod = transformMethod;
            obj.blockSize = [blockSize blockSize];
            if transformMethod == 'dct'
                obj.transformBlockSize = obj.blockSize;
            else
                transformSize = 2^ceil(log2(blockSize));
                obj.transformBlockSize = [transformSize transformSize];
            end
            obj.trainImages = trainImages;
            obj.matrixSerializer = MatrixSerializer(obj.blockSize);
            obj.rleEncoder = RleEncoder();
            obj.eliasGammaEncoder = EliasGammaEncoder();
            obj.blockTransformer = BlockTransformer(obj.blockSize,transformMethod);
            obj.blockQuantizer = BlockQuantizer.fromGenerator(obj.transformBlockSize,quantizerValueGenerator);
            obj.blockScanner = BlockScanner(obj.transformBlockSize);
            obj.whiteBlockSeparator = WhiteBlockSeparator();
          
            indexes = 1:length(trainImages);
            totalRleTuples = {};
            for i=indexes
                image = trainImages{i};
                blocks = obj.matrixSerializer.splitMatrixIntoBlocks(image);
                for j=1:size(blocks,3)
                    if all(all(blocks(:,:,j) == 255))
                        continue;
                    end
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

        function [Tys,Cys] = getTysCysFromImage(obj, image)
            blocks = obj.matrixSerializer.splitMatrixIntoBlocks(image);
            [Tys, Cys] = obj.whiteBlockSeparator.split(blocks);
        end

        function image = getImageFromTysCys(obj, Tys,Cys,imageSize)
            blocks = obj.whiteBlockSeparator.join(Tys,Cys);
            image = obj.matrixSerializer.joinMatrixBlocks(blocks,imageSize);
            image = uint8(image);
        end

        function writeImageTysCys(obj, image, path)
            blocks = obj.matrixSerializer.splitMatrixIntoBlocks(image);
            [Tys, Cys] = obj.whiteBlockSeparator.split(blocks);
            data = {Tys,Cys,size(image)};
            save(path,'data');
        end

        function image = readImageFromTysCys(obj, path)
            load(path);
            image = obj.getImageFromTysCys(data{1}, data{2}, data{3});
        end

        function [compressedImage, compressionLength, ratio] = compressImage(obj, image)
                blocks = obj.matrixSerializer.splitMatrixIntoBlocks(image);
                [Tys,Cys] = obj.whiteBlockSeparator.split(blocks);
                rleTuples = {};
                for j=1:size(Cys,3)
                    transformedBlock = obj.blockTransformer.transform(Cys(:,:,j));
                    quantizedBlock = obj.blockQuantizer.quantize(transformedBlock);
                    blockScan = obj.blockScanner.scan(quantizedBlock);
                    blockRleTuples = obj.rleEncoder.encode(blockScan);
                    for k=1:length(blockRleTuples)
                        rleTuples{length(rleTuples)+1} = blockRleTuples{k};
                    end
                end
                tysLenght = size(Tys,1);
                compressedQuantizationMatrix = obj.eliasGammaEncoder.encodeList(reshape(obj.blockQuantizer.matrix', 1,[]));
                if obj.transformMethod == 'dct'
                    transformMethodCode = 1;
                else
                    transformMethodCode = 2;
                end
                compressedWhiteBlocks = obj.eliasGammaEncoder.encodeList(reshape(Tys',1,[]));
                compressedRleTuples = obj.huffmanDictionary.encode(rleTuples);
                compressedImage = [compressedQuantizationMatrix compressedWhiteBlocks compressedRleTuples];
                metaData = [(tysLenght+1) size(image) size(obj.blockQuantizer.matrix,1) transformMethodCode obj.blockSize];
                encodedMetaData = obj.eliasGammaEncoder.encodeList(metaData);
                compressedImage = [encodedMetaData, compressedImage];
                compressionLength = length(compressedImage);
                ratio = compressionLength / (8*size(image,1)*size(image,2));
        end

        function [compressedImage, compressionRatio] = compressImageByPath(obj, imagePath)
            image = imread(imagePath);
            [compressedImage, compressionRatio] = obj.compressImage(image);
        end

        function image = decompressImage(obj, compressedImage)
            [metaData, compressedImage] = obj.eliasGammaEncoder.decodeList(compressedImage, 7);
            tysLenght = metaData(1) - 1;
            imageSize = metaData(2:3);
            blockQuantizedBlockSize = [metaData(4) metaData(4)];
            blockSize = metaData(6:7);
            if metaData(5) == 1
                blockTransformer = BlockTransformer(blockSize, "dct");
            else
                blockTransformer = BlockTransformer(blockSize, "wht");
            end
            [quantizationMatrix,compressedImage] = obj.eliasGammaEncoder.decodeList(compressedImage, blockQuantizedBlockSize(1)^2);
            quantizationMatrix =  reshape(quantizationMatrix,blockQuantizedBlockSize(1),[])';
            blockQuantizer = BlockQuantizer(blockQuantizedBlockSize, quantizationMatrix);
            TysLength = metaData(1)-1;
            if TysLength > 0
                [Tys, compressedImage] = obj.eliasGammaEncoder.decodeList(compressedImage, 2*TysLength);
                Tys = reshape(Tys', 2,[])';
            else
                Tys = [];
            end
            rleTuples = obj.huffmanDictionary.decode(compressedImage);
            stream = obj.rleEncoder.decode(rleTuples);
            scanSize = obj.transformBlockSize(1)*obj.transformBlockSize(2);
            blockScans = reshape(stream, scanSize, [])';
            blockScanSize =  size(blockScans);
            Cys = zeros(obj.matrixSerializer.blockSize(1),obj.matrixSerializer.blockSize(2),length(blockScans));
            for i=1:blockScanSize(1)
                blockScan = obj.blockScanner.build(blockScans(i,:));
                dequantizedBlock = blockQuantizer.dequantize(blockScan);
                Cys(:,:,i) = blockTransformer.inverseTransform(dequantizedBlock);
            end
            blocks = obj.whiteBlockSeparator.join(Tys,Cys);
            image = uint8(obj.matrixSerializer.joinMatrixBlocks(blocks,metaData(2:3)));
        end

        function showTask1Table(obj)
            sprintf('For %dx%d size blocks:', obj.blockSize(1),obj.blockSize(2))
            indexes = 1:length(obj.trainImages);
            blocksCount = zeros(1, length(obj.trainImages));
            whiteBlocksCount = zeros(1, length(obj.trainImages));
            whiteBlocksPercent = zeros(1, length(obj.trainImages));
            whiteBlocksTuplesCount = zeros(1, length(obj.trainImages));
            for i=indexes
                blocks = obj.matrixSerializer.splitMatrixIntoBlocks(obj.trainImages{i});
                [Tys,Cys] = obj.whiteBlockSeparator.split(blocks);
                blocksCount(i) = length(blocks);
                whiteBlocksCount(i) = sum(Tys(:,2));
                whiteBlocksPercent(i) = 100*whiteBlocksCount(i)/blocksCount(i);
            end
            Index = indexes';
            BlocksCount = blocksCount';
            WhiteBlocksCount = whiteBlocksCount';
            WhiteBlocksPercent = whiteBlocksPercent';
            table(Index, BlocksCount, WhiteBlocksCount, WhiteBlocksPercent)
            average = mean(whiteBlocksCount);
            variance = var(whiteBlocksCount);
            sprintf('With average = %.2f, variance = %.2f and std deviation = %.2f.', average, variance, sqrt(variance))
        end

     function showTask2Table(obj)
            sprintf('For %dx%d size blocks with %s method:', obj.blockSize(1),obj.blockSize(2),obj.transformMethod)
            sprintf('Transform matrix')
            obj.blockTransformer.matrix
            sprintf('Quantization matrix')
            obj.blockQuantizer.matrix
            indexes = 1:length(obj.trainImages);
            mse = zeros(1, length(obj.trainImages));
            timeSpent = zeros(1, length(obj.trainImages));
            for i=indexes
                tic;
                blocks = obj.matrixSerializer.splitMatrixIntoBlocks(obj.trainImages{i});
                detransformedBlock = 0 * blocks;
                [Tys,Cys] = obj.whiteBlockSeparator.split(blocks);
                for j=1:size(Cys,3)
                    Dys = obj.blockTransformer.transform(Cys(:,:,j));
                    truncatedDys = floor(Dys);
                    restoredCys(:,:,j) = obj.blockTransformer.inverseTransform(truncatedDys);
                end
                restoredBlocks = obj.whiteBlockSeparator.join(Tys,restoredCys);
                restoredImage = obj.matrixSerializer.joinMatrixBlocks(restoredBlocks, size(obj.trainImages{i}));
                timeSpent(i) = toc;
                mse(i) = quadraticMeanError(restoredImage, obj.trainImages{i});
            end
            Index = indexes';
            TimeSpent = timeSpent';
            MSE = mse';
            table(Index, TimeSpent, MSE)
     end

     function showTask3Table(obj)   
            sprintf('Quantization matrix')
            obj.blockQuantizer.matrix
            indexes = 1:length(obj.trainImages);
            mse = zeros(1, length(obj.trainImages));
            for i=indexes
                blocks = obj.matrixSerializer.splitMatrixIntoBlocks(obj.trainImages{i});
                detransformedBlock = 0 * blocks;
                [Tys,Cys] = obj.whiteBlockSeparator.split(blocks);    
                rleTuples = {};
                quantizedRleTuples = {};
                for j=1:size(Cys,3)
                    Dys = obj.blockTransformer.transform(Cys(:,:,j));
                    quantizedBlock = obj.blockQuantizer.quantize(Dys);
                    dequantizedBlock = obj.blockQuantizer.dequantize(quantizedBlock);
                    restoredCys(:,:,j) = obj.blockTransformer.inverseTransform(dequantizedBlock);
                    
                    % original blocks rle tuples
                    blockScan = obj.blockScanner.scan(Dys);
                    blockRleTuples = obj.rleEncoder.encode(blockScan);
                    for k=1:length(blockRleTuples)
                        rleTuples{length(rleTuples)+1} = blockRleTuples{k};
                    end

                    % resored blocks rle tuples (from quantization)
                    blockScan = obj.blockScanner.scan(quantizedBlock);
                    blockRleTuples = obj.rleEncoder.encode(blockScan);
                    for k=1:length(blockRleTuples)
                        quantizedRleTuples{length(quantizedRleTuples)+1} = blockRleTuples{k};
                    end
                end
                rleTuplesCount(i) = length(rleTuples);
                quantizedRleTuplesCount(i) = length(quantizedRleTuples);

                [rleTuplesValues, rleTuplesProbabilities] = getProbabilities(string(rleTuples),'char',@(X,i) X(i));
                entropy(i) = -sum(rleTuplesProbabilities.*log2(rleTuplesProbabilities));

                [rleTuplesValues, rleTuplesProbabilities] = getProbabilities(string(quantizedRleTuples),'char',@(X,i) X(i));
                quantizedEntropy(i) = -sum(rleTuplesProbabilities.*log2(rleTuplesProbabilities));

                restoredBlocks = obj.whiteBlockSeparator.join(Tys,restoredCys);
                restoredImage = obj.matrixSerializer.joinMatrixBlocks(restoredBlocks, size(obj.trainImages{i}));
                mse(i) = quadraticMeanError(restoredImage, obj.trainImages{i});
            end
            Index = indexes';
            RleCount = rleTuplesCount';
            QuantizedRleCount = quantizedRleTuplesCount';
            Entropy = entropy';
            QuantizedEntropy = quantizedEntropy';
            MSE = mse';
            table(Index, RleCount, QuantizedRleCount, Entropy, QuantizedEntropy, MSE)
     end

    end
end