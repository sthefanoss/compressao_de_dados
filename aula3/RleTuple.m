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
            str = sprintf('(%d,%d)',obj.symbol, obj.count);
        end
    end
end