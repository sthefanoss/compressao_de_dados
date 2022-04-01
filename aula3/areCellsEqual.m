function test = areCellsEqual(a,b)
    if(length(a) ~= length(b))
        test = false;
        return;
    end

    for i=1:length(a)
        if a{i} ~= b{i}
            test = false;
            return;
        end
    end
    test = true;
end