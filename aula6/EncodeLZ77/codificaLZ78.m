% codificacao LZ78 implementada de forma recursiva
% retorna o codebook, onde i eh um vetor de indices e s eh um vetor de char
% a entrada eh uma string
function [i,s] = codificaLZ78(input)
    input = string(input);
    i(1) = 0; s(1) = input{1}(1);
    bufferStart = 2;
    bufferEnd = 2;
    nodeIndexToInsert = 0;
    while bufferStart < strlength(input)
        buffer = input{1}(bufferStart:bufferEnd);
        bufferNodeIndexToInsert = getNodeIndexToInsert(i, s, buffer);
        if bufferNodeIndexToInsert ~= 0
            nodeIndexToInsert = bufferNodeIndexToInsert;
        end
        
        if bufferNodeIndexToInsert ~= 0 && bufferEnd < strlength(input)
            bufferEnd = bufferEnd+1;
            continue
        end

        newIndex = length(i) + 1;
        i(newIndex) = nodeIndexToInsert;
        s(newIndex) = input{1}(bufferEnd);
        bufferStart = bufferEnd + 1;
        bufferEnd = bufferStart;
        nodeIndexToInsert = 0;
    end
end

% recebe o codebook e um no, retorna a string de forma recursiva
function expression = getNodeStringValue(i, s, index, char)
    if(index == 0)
        expression = char;
    else
        expression = [getNodeStringValue(i, s, i(index), s(index)) char];
    end
end

% procura alguma expressao no codebook que tenha match com o buffer
% comeca com os maiores indices, retorna 0 se nao encontrar
function index = getNodeIndexToInsert(i, s, buffer)
    index = 0;
    for j=length(i):-1:1
       nodeString = getNodeStringValue(i, s, i(j), s(j));
       if strcmp(nodeString, buffer)
           index = j;
           return;
       end
    end
end