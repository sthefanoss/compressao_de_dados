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
        huffmanDictionary
        symbolsValues
        symbolsProbabilities
        symbolsInformationQuantities
        symbolsEntropy
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

            obj.matrixSerializer = MatrixSerializer(blockSize);
            obj.rleEncoder = RleEncoder();
            obj.eliasGammaEncoder = EliasGammaEncoder();
            indexes = 1:length(trainImagePaths);

            for i=indexes
                image = imread(trainImagePaths{i}) > 150;
                imageSymbols{i} = obj.matrixSerializer.serialize(image);
                rleTuples{i} = obj.rleEncoder.encode(imageSymbols{i});
            end
            [obj.symbolsValues, obj.symbolsProbabilities] = ImageCompressor.getProbabilities(cell2mat(imageSymbols),'uint64',@(X,i) X(i));
            obj.symbolsInformationQuantities = -log2(obj.symbolsProbabilities);
            obj.symbolsEntropy = sum(obj.symbolsProbabilities.*obj.symbolsInformationQuantities);

            [obj.rleTuplesValues, obj.rleTuplesProbabilities] = ImageCompressor.getProbabilities(string([rleTuples{indexes}]),'char',@(X,i) X(i));
            obj.rleTuplesInformationQuantities = -log2(obj.rleTuplesProbabilities);
            obj.rleTuplesEntropy = sum(obj.rleTuplesProbabilities.*obj.rleTuplesInformationQuantities);

            obj.huffmanDictionary = HuffmanDictionary.make(obj.rleTuplesValues,obj.rleTuplesProbabilities, escapeMethod);
        end

        function [compressedImage, compressionRatio] = compressImage(obj, image)
            image = image > 150;
            [imageSymbols,imageSize] = obj.matrixSerializer.serialize(image);
            rleTuples = obj.rleEncoder.encode(imageSymbols);
            compressedImage = obj.huffmanDictionary.encode(rleTuples);
            compressionRatio = length(compressedImage)/(imageSize(1)*imageSize(2));
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


    end
end