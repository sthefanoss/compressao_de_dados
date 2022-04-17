classdef EliasGammaEncoder
    methods (Static)
        function [M,L] = getML(x)
            M = floor(log2(x));
            L = x - 2^M;
        end
    end

    methods
        function obj = EliasGammaEncoder()
        end

        function encoded = encode(obj, x)
            encoded = zeros(1,1);
            if(x == 1)
                encoded(1) = 1;
            else
                [M,L] = EliasGammaEncoder.getML(x);
                prefix = repmat('0', 1, M);
                suffix = pad(dec2bin(L),M,'left', '0');
                encodedAsString = strcat(prefix, '1', suffix);
                encoded = zeros(1,length(encodedAsString));
                for i=1:length(encoded)
                    encoded(i) = strcmp(encodedAsString(i),"1");
                end
            end
        end

        function x = decode(obj, encoded)
            if length(encoded) == 1
                x = 1;
            else
                padding = ceil(length(encoded)/2);
                x =   bin2dec(join(string(encoded(padding:length(encoded))),""));
            end
        end


        function encoded = encodeList(obj, x)
            encoded = cell(1,length(x));
            for i=1:length(x)
                encoded{i} = obj.encode(x(i));
            end
            encoded = cell2mat(encoded);
        end

        function [x,reminder] = decodeList(obj, encoded, count)
            arguments
                obj,
                encoded (1,:)
                count = 0
            end

            x = [];
            startIndex = 1;
            endIndex = 1;
            while startIndex < length(encoded) && (count == 0 || length(x) < count)
                buffer = encoded(startIndex:endIndex);
                if sum(buffer) == 0
                    endIndex = endIndex + 1;
                    continue;
                end

                if length(buffer) == 1
                    x(length(x)+1) = 1;
                    startIndex = endIndex+1;
                    endIndex = startIndex;
                    continue;
                end

                endIndex = endIndex + length(buffer) -1;
                word = encoded(startIndex:endIndex);
                x(length(x)+1) = obj.decode(word);
                startIndex = endIndex+1;
                endIndex = startIndex;
            end
            
            if count ~= 0 
                reminder = encoded(startIndex:length(encoded));
            end
        end
    end
end