classdef (Abstract) HuffmanDictionary
    properties
        dictionary
        escapeMethod char
    end

    methods (Static)
        function obj = make(symbols, probabilities, escapeMethod)
            arguments
                symbols (1,:) cell
                probabilities (1,:) {mustBeNumeric,mustBeFinite}
                escapeMethod char {mustBeMember(escapeMethod,{'without','expectedValue', 'lessFrequent'})} = 'without'
            end
            
            if strcmp(escapeMethod, 'without')
                obj = HuffmanDictionaryWithoutEscape(symbols, probabilities);
                return;
            end

            obj = HuffmanDictionaryWithEscape(symbols, probabilities, escapeMethod);
        end
    end

    methods (Abstract)
         encodedData = encode(obj, data)
         data = decode(obj, encodedData)
    end
end