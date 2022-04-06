classdef HuffmanDictionaryWithoutEscape < HuffmanDictionary
    methods
        function obj = HuffmanDictionaryWithoutEscape(symbols, probabilities)
            obj.dictionary = huffmandict(symbols, probabilities);
            obj.escapeMethod = 'without';
        end

        function encodedData = encode(obj, data)
            encodedData = huffmanenco(data, obj.dictionary);
        end

        function data = decode(obj, encodedData)
            data = huffmandeco(encodedData, obj.dictionary);
        end
    end
end