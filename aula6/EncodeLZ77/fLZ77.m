function [code,SB_out,LAB_out] = fLZ77(SB_in, LAB_in)
    arguments
        SB_in (1,:) char
        LAB_in (1,:) char
    end
    if isempty(SB_in) || isempty(LAB_in)
        return;
    end

    match = 0;
    offset = 0;

    %i desliza o offset
    for i=0:length(SB_in)-1
        %ignora os matches depois de achar o primeiro
        if match ~= 0
            continue;
        end

        %j desliza a comparacao das janelas
        for j=1:min(length(SB_in)-i, length(LAB_in))
           if SB_in(1+i:j+i) == LAB_in(1:j)
               match = j;
               offset = i;
           end
        end
    end
    if match == length(LAB_in) 
        match = match -1;
    end
    code = sprintf('(%d,%d,%c)', offset,match,LAB_in(match+1));
    SB_out = [SB_in LAB_in(1:match+1)];
    LAB_out = LAB_in(match+2:length(LAB_in));
end