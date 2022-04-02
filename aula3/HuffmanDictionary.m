classdef HuffmanDictionary
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        method
        dict
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
        function obj = HuffmanDictionary(symbols, probabilities, method)
            arguments
                symbols
                probabilities (1,:) {mustBeNumeric, mustBeFinite}
                method {mustBeMember(method,{'none', 'mean', 'slowest'})} = 'none'
            end

            obj.method = method;
            if strcmp(method, 'none')
                obj.dict = huffmandict(symbols,probabilities);
                obj.escapeLength = 0;
            else
                expectedValue = mean(probabilities);
                obj.escapeSymbolLength = floor(log2(sum(probabilities < expectedValue)));
                obj.escapeLength = 2^obj.escapeSymbolLength;
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
                obj.dict = huffmandict(huffmanSymbols, huffmanProbabilities);
                obj.codeToSymbolHuffmanMap = containers.Map('KeyType','char', 'ValueType', 'char');
                obj.symbolToCodeHuffmanMap = containers.Map('KeyType','char', 'ValueType', 'char');
                for i=1:length(obj.dict)
                    code = join(string(obj.dict{i,2}),'');
                    tuple = obj.dict{i,1};
                    obj.codeToSymbolHuffmanMap(code) = tuple;
                    obj.symbolToCodeHuffmanMap(tuple) = code;
                    if(strcmp(tuple,'escape'))
                        obj.escapeCode = code;
                    end
                end
                obj.minLength = length(obj.dict{1,2});
            end
        end

        function bitArray = encode(obj, data)
            if strcmp(obj.method, 'none')
                bitArray = huffmanenco(data, obj.dict);
            else
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
                bitArray = zeros(1,streamLength);
                for i=1:streamLength    
                    bitArray(i) = stream{1}(i) == '1';
                end
            end
        end

        function data = decode(obj, bitData)
            if strcmp(obj.method, 'none')
                data = huffmandeco(bitData, obj.dict);
            else
                data = {};
                bitDataAsString = join(string(bitData),'');
                bitDataLength = length(bitData);
                bufferStart = 1;
                bufferEnd = bufferStart + obj.minLength;
                while(bufferStart < bitDataLength)
%                      data
%                      [bufferStart,bufferEnd]
                     code = bitDataAsString{1}(bufferStart:bufferEnd);
%                      pause(1);
                     if isKey(obj.codeToSymbolHuffmanMap, code)
                        isEscape = strcmp(code, obj.escapeCode);
                        if isEscape
                            scapeCodeStartIndex = bufferEnd+1;
                            scapeCodeEndIndex = scapeCodeStartIndex+obj.escapeSymbolLength-1;
                            scapeCode = bitDataAsString{1}(scapeCodeStartIndex:scapeCodeEndIndex);
                            symbol = obj.codeToSymbolScapeMap(scapeCode);
                            data{length(data)+1} = symbol;
                           
                            bufferStart = scapeCodeEndIndex+1;
                            bufferEnd = bufferStart + obj.minLength-1;
                        else
                            symbol = obj.codeToSymbolHuffmanMap(code);
                            data{length(data)+1} = symbol;
                            bufferStart = bufferEnd + 1;
                            bufferEnd = bufferStart + obj.minLength-1;
                        end
                     else
                         bufferEnd = bufferEnd+1;
                     end
                end
            end
        end
    end
end