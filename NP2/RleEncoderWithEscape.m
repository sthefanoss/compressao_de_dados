classdef RleEncoderWithEscape

    properties
        escape
    end

    methods
        function obj = RleEncoderWithEscape(escape)
            obj.escape = escape;
        end

        function [Tys,Cys] = encode(obj, data)
            arguments
                obj,
                data (1,:)
            end
            Tys = uint64([1 1]); % {starting index,repetitions}
            Cys = uint64([1 1]); % {value,repetitions}
            tIndex = 0;
            cIndex = 0;
            if data(1) == obj.escape
                tIndex = 1;
                Tys(1,:) = [1,1];
            else
                cIndex = 1;
                Cys(1,:) = [data(1),1];
            end

            for i=2:length(data)
                current = data(i);
                previuos = data(i-1);
                if current == previuos && current == obj.escape
                    Tys(tIndex,2) = Tys(tIndex,2) + 1;
                elseif current ~= previuos && current == obj.escape
                    tIndex = tIndex + 1;
                    Tys(tIndex,:) = [i,1];
                elseif current == previuos % && current != escape
                    Cys(cIndex,2) = Cys(cIndex,2) + 1;
                else %current != previuos && current != escape
                    cIndex = cIndex+1;
                    Cys(cIndex,:) = [data(i),1];
                end
            end
        end

        function data = decode(obj, Tys, Cys)
            data = uint64(1:(sum(Tys(:,2))+sum(Cys(:,2))));

            tIndex = 1;
            cIndex = 1;
            k=1;
            tuplesLength = length(Tys) + length(Cys);
            for i=1:tuplesLength
                if k == Tys(tIndex,1)
                    for j=1:Tys(tIndex,2)
                        data(k) = obj.escape;
                        k = k + 1;
                    end
                    tIndex = tIndex + 1;
                else
                    for j=1:Cys(cIndex,2)
                        data(k) = Cys(cIndex,1);
                        k = k + 1;
                    end
                    cIndex = cIndex + 1;
                end
            end
        end
    end
end