classdef RleEncoder
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    methods
        function obj = RleEncoder()
        end

        function tuples = encode(obj,data)
            arguments
                obj,
                data (1,:)
            end
            values(1) = data(1);
            counts(1) = uint64(1);
            k = 1;
            for i=2:length(data)
                if(data(i) == values(k))
                    counts(k) = counts(k) + 1;
                else
                    k = k + 1;
                    values(k) = data(i);
                    counts(k) = 1;
                end
            end

            tuples = cell(1,length(values));
            for i=1:length(values)
                tuples{i} = sprintf('%d %d',values(i), counts(i));
            end
        end

        function data = decode(obj, tuples)
            for i=1:length(tuples)
                tuple = split(tuples{i},' ');
                values(i) = str2num(tuple{1});
                counts(i) = str2num(tuple{2});
            end

            data = zeros(1,sum(counts));
            k = 1;
            for i=1:length(tuples)
                for j=1:counts(i)
                    data(k) = values(i);
                    k = k + 1;
                end
            end
        end
    end
end