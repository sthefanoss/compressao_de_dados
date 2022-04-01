classdef RleTuple
    properties
        symbol
        count
    end

    methods
        function obj = RleTuple(symbol, count)
            obj.symbol = symbol;
            obj.count = count;
        end

        function test = eq(a, b)
            arguments
                a RleTuple
                b RleTuple
            end
            test = false(1,length(b));
            for i=1:length(b)
                test(i) = a.count == b(i).count & a.symbol == b(i).symbol;
            end
        end

        function newObj = bumpCount(obj)
            newObj = RleTuple(obj.symbol, obj.count + 1);
        end

        function str = toString(obj)
            str = strings(1,length(obj));
            for i=1:length(obj)
                str(i) = sprintf('(%d,%d)',obj(i).symbol, obj(i).count);
            end
        end

        function cell = toCell(obj)
            cell = {};
            for i=1:length(obj)
                cell{i} = obj(i).toString();
            end
        end
        
    end
end