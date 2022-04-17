classdef RleEncoderWithEscape
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    properties
        escape
    end

   methods (Access = private)
       function   [Tys,Cys] = splitEscapeTuples(obj, tuples)

       end
      
       function   tuples = joinEscapeTuples(obj, Tys,Cys)
           
       end
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

            [Tys,Cys] =  obj.splitEscapeTuples(tuples); 
        end

        function data = decode(obj, Tys, Cys)
             tuples = obj.joinEscapeTuples(Tys,Cys);
            for i=1:length(tuples)
                tuple = split(tuples{i},' ');
                values(i) = str2num(tuple{1});
                counts(i) = str2num(tuple{2});
            end

            data = uint64(1:sum(counts));
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