classdef HuffmanDictionaryWithEscape < HuffmanDictionary
    properties
        escapeLength
        codeToSymbolScapeMap
        symbolToCodeScapeMap
        codeToSymbolHuffmanMap
        symbolToCodeHuffmanMap
        escapeCode
        escapeSymbolLength
        minLength
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
                obj.escapeLength = 2^obj.escapeSymbolLength;
            else
                smallerProbability = probabilities(length(probabilities));
                smallerCount = sum(probabilities == smallerProbability);
                obj.escapeSymbolLength = ceil(log2(smallerCount));
                if obj.escapeSymbolLength >= ceil(log2(length(symbols)))
                    obj.escapeSymbolLength = obj.escapeSymbolLength -1;
                end
                obj.escapeLength = 2^obj.escapeSymbolLength;
            end
            
            scapeIndexes = length(symbols)-obj.escapeLength+1:length(symbols);
            huffmanIndexes = 1:scapeIndexes(2)-2;

            huffmanSymbols =  symbols(huffmanIndexes);
            huffmanProbabilities =  probabilities(huffmanIndexes);
            scapeSymbols = symbols(scapeIndexes);
            obj.codeToSymbolScapeMap = containers.Map('KeyType','char', 'ValueType', 'char');
            obj.symbolToCodeScapeMap = containers.Map('KeyType','char', 'ValueType', 'char');
            for i=1:obj.escapeLength
                code = dec2bin(i-1, obj.escapeSymbolLength);
                tuple = scapeSymbols{i};
                obj.codeToSymbolScapeMap(code) = tuple;
                obj.symbolToCodeScapeMap(tuple) = code;
            end

            scapeSymbolIndex = length(huffmanSymbols) + 1;
            huffmanSymbols(scapeSymbolIndex) = {'escape'};
            huffmanProbabilities(scapeSymbolIndex) = sum(probabilities(scapeIndexes));
            [huffmanProbabilities, sortedIndexes] = sort(huffmanProbabilities, 'descend');
            huffmanSymbols = huffmanSymbols(sortedIndexes);
            obj.dictionary = huffmandict(huffmanSymbols, huffmanProbabilities);
            obj.codeToSymbolHuffmanMap = containers.Map('KeyType','char', 'ValueType', 'char');
            obj.symbolToCodeHuffmanMap = containers.Map('KeyType','char', 'ValueType', 'char');
            for i=1:length(obj.dictionary)
                code = join(string(obj.dictionary{i,2}),'');
                tuple = obj.dictionary{i,1};
                obj.codeToSymbolHuffmanMap(code) = tuple;
                obj.symbolToCodeHuffmanMap(tuple) = code;
                if(strcmp(tuple,'escape'))
                    obj.escapeCode = code;
                end
            end
            obj.minLength = length(obj.dictionary{1,2});
        end

        function encodedData = encode(obj, data)
            stream = "";
            for i=1:length(data)
                symbol = data{i};
                if isKey(obj.symbolToCodeScapeMap, symbol)
                    currentCode = strcat(obj.escapeCode, obj.symbolToCodeScapeMap(symbol));
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
                        symbol = obj.codeToSymbolScapeMap(scapeCode);
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