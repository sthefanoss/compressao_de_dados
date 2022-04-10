classdef HuffmanDictionaryWithEscape < HuffmanDictionary
    properties
        escapeLength
        codeToSymbolEscapeMap
        symbolToCodeEscapeMap
        codeToSymbolHuffmanMap
        symbolToCodeHuffmanMap
        escapeCode
        escapeSymbolLength
    end

    methods
        function obj = HuffmanDictionaryWithEscape(symbols, probabilities, escapeMethod)
            arguments
                symbols (1,:) cell
                probabilities (1,:) {mustBeNumeric, mustBeFinite}
                escapeMethod char {mustBeMember(escapeMethod,{'expectedValue', 'lessFrequent'})} = 'expectedValue'
            end
            obj.escapeMethod = escapeMethod;
            [probabilities, indexes] = sort(probabilities, 'descend');
            symbols = symbols(indexes);

            if strcmp(escapeMethod, 'expectedValue')
                expectedValue = mean(probabilities);
                obj.escapeSymbolLength = floor(log2(sum(probabilities < expectedValue)));
            else
                smallerProbability = probabilities(length(probabilities));
                smallerCount = sum(probabilities == smallerProbability);
                obj.escapeSymbolLength = ceil(log2(smallerCount));
                if obj.escapeSymbolLength >= ceil(log2(length(symbols)))
                    obj.escapeSymbolLength = obj.escapeSymbolLength -1;
                end
            end
            obj.escapeLength = 2^obj.escapeSymbolLength;
            escapeIndexes = length(symbols)-obj.escapeLength+1:length(symbols);
            huffmanIndexes = 1:escapeIndexes(2)-2;

            huffmanSymbols =  symbols(huffmanIndexes);
            huffmanProbabilities =  probabilities(huffmanIndexes);
            escapeSymbols = symbols(escapeIndexes);
            obj.codeToSymbolEscapeMap = containers.Map('KeyType','char', 'ValueType', 'char');
            obj.symbolToCodeEscapeMap = containers.Map('KeyType','char', 'ValueType', 'char');
            for i=1:obj.escapeLength
                code = dec2bin(i-1, obj.escapeSymbolLength);
                tuple = escapeSymbols{i};
                obj.codeToSymbolEscapeMap(code) = tuple;
                obj.symbolToCodeEscapeMap(tuple) = code;
            end

            escapeSymbolIndex = length(huffmanSymbols) + 1;
            escapeProbability = sum(probabilities(escapeIndexes));
            huffmanSymbols(escapeSymbolIndex) = {'escape'};
            huffmanProbabilities(escapeSymbolIndex) = escapeProbability;
            [huffmanProbabilities, sortedIndexes] = sort(huffmanProbabilities, 'descend');
            huffmanSymbols = huffmanSymbols(sortedIndexes);
            huffmanSymbolsProbabilityMap = containers.Map('KeyType','char','ValueType', 'double');
            for i=1:length(huffmanSymbols)
                huffmanSymbolsProbabilityMap(huffmanSymbols{i}) = huffmanProbabilities(i);
            end
            
            obj.dictionary = huffmandict(huffmanSymbols, huffmanProbabilities);
       

            obj.codeToSymbolHuffmanMap = containers.Map('KeyType','char', 'ValueType', 'char');
            obj.symbolToCodeHuffmanMap = containers.Map('KeyType','char', 'ValueType', 'char');
            obj.averageLength = 0;
            for i=1:length(obj.dictionary)
                code = join(string(obj.dictionary{i,2}),'');
                tuple = obj.dictionary{i,1};
                obj.codeToSymbolHuffmanMap(code) = tuple;
                obj.symbolToCodeHuffmanMap(tuple) = code;
                if(strcmp(tuple,'escape'))
                    obj.escapeCode = code;
                    codeAverageLength = (strlength(code)+obj.escapeSymbolLength)*escapeProbability;
                    obj.averageLength = obj.averageLength + codeAverageLength;
                else
                    codeAverageLength = strlength(code)*huffmanSymbolsProbabilityMap(tuple);
                    obj.averageLength = obj.averageLength + codeAverageLength;
                end
            end
        end

        function encodedData = encode(obj, data)
            stream = "";
            for i=1:length(data)
                symbol = data{i};
                if isKey(obj.symbolToCodeEscapeMap, symbol)
                    currentCode = strcat(obj.escapeCode, obj.symbolToCodeEscapeMap(symbol));
                else
                    currentCode = obj.symbolToCodeHuffmanMap(symbol);
                end
                stream = strcat(stream, currentCode);
            end
            streamLength = strlength(stream);
            encodedData = zeros(1,streamLength);
            for i=1:streamLength
                encodedData(i) = stream{1}(i) == '1';
            end
        end

        function data = decode(obj, encodedData)
            data = {};
            bitDataAsString = join(string(encodedData),'');
            bitDataLength = length(encodedData);
            bufferStart = 1;
            bufferEnd = 1;
            while bufferStart < bitDataLength
                code = bitDataAsString{1}(bufferStart:bufferEnd);
                if isKey(obj.codeToSymbolHuffmanMap, code)
                    isEscape = strcmp(code, obj.escapeCode);
                    if isEscape
                        scapeCodeStartIndex = bufferEnd+1;
                        scapeCodeEndIndex = scapeCodeStartIndex+obj.escapeSymbolLength-1;
                        scapeCode = bitDataAsString{1}(scapeCodeStartIndex:scapeCodeEndIndex);
                        symbol = obj.codeToSymbolEscapeMap(scapeCode);
                        data{length(data)+1} = symbol;

                        bufferStart = scapeCodeEndIndex+1;
                        bufferEnd = bufferStart;
                    else
                        symbol = obj.codeToSymbolHuffmanMap(code);
                        data{length(data)+1} = symbol;
                        bufferStart = bufferEnd + 1;
                        bufferEnd = bufferStart;
                    end
                else
                    bufferEnd = bufferEnd+1;
                end
            end
        end
    end
end