classdef TysCysCompressor
    properties
        matrixSerializer MatrixSerializer
        rleEncoder RleEncoderWithEscape
        eliasGammaEncoder EliasGammaEncoder
    end

    methods
        function obj = TysCysCompressor(blockSize)
            arguments
                blockSize (1,2)
            end
            obj.matrixSerializer = MatrixSerializer(blockSize);
            escapeValue = 2^(blockSize(1)*blockSize(2))-1;
            obj.rleEncoder = RleEncoderWithEscape(escapeValue);
 
%             indexes = 1:length(trainImagePaths);
% 
%             for i=indexes
%                 image = imread(trainImagePaths{i}) > 150;
%                 imageSymbols{i} = obj.matrixSerializer.serialize(image);
%                 rleTuples{i} = obj.rleEncoder.encode(imageSymbols{i});
%             end
%             totalSymbols = cell2mat(imageSymbols);
%             obj.symbolsTotalCount = length(totalSymbols);
%             [obj.symbolsValues, obj.symbolsProbabilities] = ImageCompressor.getProbabilities(totalSymbols,'uint64',@(X,i) X(i));
%             obj.symbolsInformationQuantities = -log2(obj.symbolsProbabilities);
%             obj.symbolsEntropy = sum(obj.symbolsProbabilities.*obj.symbolsInformationQuantities);
%             
%             totalRleTuples = [rleTuples{indexes}];
%             obj.rleTuplesTotalCount = length(totalRleTuples);
%             [obj.rleTuplesValues, obj.rleTuplesProbabilities] = ImageCompressor.getProbabilities(string(totalRleTuples),'char',@(X,i) X(i));
%             obj.rleTuplesInformationQuantities = -log2(obj.rleTuplesProbabilities);
%             obj.rleTuplesEntropy = sum(obj.rleTuplesProbabilities.*obj.rleTuplesInformationQuantities);
% 
%             obj.huffmanDictionary = HuffmanDictionary.make(obj.rleTuplesValues,obj.rleTuplesProbabilities, escapeMethod);
        end

        function [Tys, Cys, imageSize] = compressImage(obj, image)
            image = image > 150;
            imageSymbols = obj.matrixSerializer.serialize(image);
            [Tys,Cys] = obj.rleEncoder.encode(imageSymbols);
            imageSize = size(image);
        end

        function compressImageAndSave(obj, image, path)
            image = image > 150;
            imageSymbols = obj.matrixSerializer.serialize(image);
            [Tys,Cys] = obj.rleEncoder.encode(imageSymbols);
            data = {Tys,Cys,size(image)};
            save(path,'data');
        end


        function image = decompressImage(obj, Tys, Cys, imageSize)
            symbols = obj.rleEncoder.decode(Tys, Cys);
            image = obj.matrixSerializer.deserialize(symbols,imageSize);
        end

        function image = loadCompressedImage(obj, path)
            load(path);
            image = obj.decompressImage(data{1}, data{2}, data{3});
        end
    
%         function showBlocksAnalysis(obj, imagePaths)
%             sprintf('Total of %d symbols, %d unique symbols. With entropy H=%f.',obj.symbolsTotalCount, length(obj.symbolsValues),obj.symbolsEntropy)
%            
%             indexes = 1:min(16, length(obj.symbolsValues));
%             figure
%             bar(obj.symbolsProbabilities(indexes))
%             set(gca,'xticklabel', obj.symbolsValues(indexes),'XTick', indexes)
%    
%             Index = indexes';
%             Probability = obj.symbolsProbabilities(indexes)';
%             Symbol = obj.symbolsValues(indexes)';
%             InformationQuantity = obj.symbolsInformationQuantities(indexes)';
%             table(Index, Symbol, Probability, InformationQuantity)
%         end
% 
%         function showRleTuplesAnalysis(obj)
%             sprintf('Total of %d rle tuples, %d unique rle tuples. With entropy H=%f.', obj.rleTuplesTotalCount, length(obj.rleTuplesValues),obj.rleTuplesEntropy)
%             indexes = 1:min(16, length(obj.rleTuplesValues));
%             figure
%             bar(obj.rleTuplesProbabilities(indexes))
%             set(gca,'xticklabel', obj.rleTuplesValues(indexes),'XTick', indexes)
% 
%             Index = indexes';
%             Probability = obj.rleTuplesProbabilities(indexes)';
%             RleTuple = obj.rleTuplesValues(indexes)';
%             InformationQuantity = obj.rleTuplesInformationQuantities(indexes)';
%             table(Index, RleTuple, Probability, InformationQuantity)
%         end
% 
%         function showHuffmanAnalysis(obj)
%             if not(strcmp(obj.huffmanDictionary.escapeMethod,'without'))
%                 sprintf('Huffman dictionary with %d escape symbols. Average length of %f.', obj.huffmanDictionary.escapeLength,obj.huffmanDictionary.averageLength)
%             else
%                 sprintf('Huffman dictionary without escape symbols. Average length of %f.', obj.huffmanDictionary.averageLength)
%             end
%         end
% 
        function runImagesBenchmark(obj, imagePath)
            arguments
                obj
                imagePath (1,:) cell
            end
            sprintf('For %dx%d size blocks:', obj.matrixSerializer.blockSize(1),obj.matrixSerializer.blockSize(2))
            indexes = 1:length(imagePath);
            for i=indexes
                image = imread(imagePath{i}) > 150;
                serializedMatrix = obj.matrixSerializer.serialize(image);
                [Tys,Cys] = obj.rleEncoder.encode(serializedMatrix);
                whiteBlocks(i) = sum(Tys(:,2));
                nonWhiteBlocks = sum(Cys(:,2));
                whiteBlocksPercentual(i) = 100*whiteBlocks/(whiteBlocks+nonWhiteBlocks);
                whiteBlocksTuplesCount(i) = length(Tys);

                rleTuples = join(string(Cys));
                rleTuplesCount(i) = length(Cys);
                [rleTuplesValues, rleTuplesProbabilities] = getProbabilities(rleTuples,'char',@(X,i) X(i));
                rleTuplesInformationQuantities = -log2(rleTuplesProbabilities);
                rleTuplesEntropy(i) = sum(rleTuplesProbabilities.*rleTuplesInformationQuantities);
                whiteBlocksIndexBitlength = ceil(log2(double(max(Tys(:,1)))));
                whiteBlocksCountBitlength = ceil(log2(double(max(Tys(:,2)))));
                estimatedSize(i) = ((whiteBlocksIndexBitlength+whiteBlocksCountBitlength)*whiteBlocksTuplesCount(i) + rleTuplesEntropy(i)*rleTuplesCount(i))/(8*1024);
            end
            Index = indexes';
            WhiteBlocksCount = whiteBlocks';
            WhiteBlocksPercentual = whiteBlocksPercentual';
            WhiteBlocksTuplesCount = whiteBlocksTuplesCount';
            RleTuplesEntropy = rleTuplesEntropy';
            RleTuplesCount = rleTuplesCount';
            EstimatedSizeInKBytes = estimatedSize';
            table(Index, WhiteBlocksCount, WhiteBlocksPercentual,WhiteBlocksTuplesCount,RleTuplesEntropy,RleTuplesCount,EstimatedSizeInKBytes)
            
            average = mean(whiteBlocks);
            variance = var(whiteBlocks);
            sprintf('With average=%f and variance=%f.', average, variance)
        end
    end
end