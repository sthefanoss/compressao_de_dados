classdef HuffmanDictionary
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        method
        dict
        codeToSymbolMap
        symbolToCodeMap
        escapeLength
        %   minLength
        %  maxLength
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
                powerOfTwo = floor(log2(sum(probabilities < expectedValue)));
                obj.escapeLength = 2^powerOfTwo;
                scapeIndexes = length(symbols)-obj.escapeLength+1:length(symbols);
                huffmanIndexes = 1:scapeIndexes(2)-2;

                huffmanSymbols =  symbols(huffmanIndexes);
                huffmanProbabilities =  probabilities(huffmanIndexes);

                scapeSymbols = symbols(scapeIndexes);
                obj.codeToSymbolMap = containers.Map('KeyType','char', 'ValueType', 'char');
                obj.symbolToCodeMap = containers.Map('KeyType','char', 'ValueType', 'char');
                for i=1:obj.escapeLength
                    code = dec2bin(i-1,powerOfTwo);
                    tuple = scapeSymbols{i};
                    obj.codeToSymbolMap(code) = tuple;
                    obj.symbolToCodeMap(tuple) = code;
                end

                scapeSymbolIndex = length(huffmanSymbols) + 1;
                huffmanSymbols(scapeSymbolIndex) = {'(0,0)'};
                huffmanProbabilities(scapeSymbolIndex) = sum(probabilities(scapeIndexes));
                [huffmanProbabilities, sortedIndexes] = sort(huffmanProbabilities, 'descend');
                huffmanSymbols = huffmanSymbols(sortedIndexes);
                obj.dict = huffmandict(huffmanSymbols, huffmanProbabilities);
            end
        end

        function bitArray = encode(obj, data)
            if strcmp(obj.method, 'none')
                bitArray = huffmanenco(data, obj.dict);
            else
                replacedSymbols = {};
           
                for i=1:length(data)
                    symbol = data{i};
                    if isKey(obj.symbolToCodeMap, symbol)
                        replacedSymbols{length(replacedSymbols) + 1} = symbol;
                        data(i) = RleTuple(0,0).toCell();
                    end
                end
                bitArray = huffmanenco(data, obj.dict);
            end
        end

        function data = decode(obj, bitData)
            if strcmp(obj.method, 'none')
                data = huffmandeco(bitData, obj.dict);
            else
                data = huffmandeco(bitData, obj.dict);
            end

        end
    end
end