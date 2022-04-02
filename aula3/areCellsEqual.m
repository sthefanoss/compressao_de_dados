function [test,firstInequal] = areCellsEqual(a,b)
%     if(length(a) ~= length(b))
%         test = false;
%         firstInequal = 'size';
%         return;
%     end

    for i=1:length(a)
        if a{i} ~= b{i}
            test = false;
            firstInequal = i;
            return;
        end
    end
    test = true;
    firstInequal = -1;
end