close all; clear; clc;

% 0. pre aloca espaco 
imageRead = 7:12;
blockSize = [2 2];
binaryToIntMap = containers.Map('KeyType','char','ValueType','uint64');
symbols = {};
for i=imageRead
    imagePath = sprintf('./corpusNP1/Binarizado%d.jpg',i);
    img255 = imread(imagePath);
    imageSubBlocksSize = ceil(size(img255)./blockSize);
    symbolsLength = imageSubBlocksSize(1)*imageSubBlocksSize(2);
    symbols{i} = int32(zeros(1,symbolsLength));
    clear img255 imageSubBlocksSize;
end

% 1. gera matriz para imagem
for i=imageRead
    imagePath = sprintf('./corpusNP1/Binarizado%d.jpg',i);
    img = imread(imagePath) == 255; 
    
% 2. segmentar em blocos
    [paddedImg, imagePadding] = padMatrixForMultiple(img, blockSize);
    blocks = splitMatrixInBlocks(paddedImg, blockSize);
    for j=1:length(blocks)
        symbols{i}(j) = encodeBlock(blocks(:,:,j), binaryToIntMap);
    end
    clear imagePath img paddedImg imagePadding blocks j;
end
clear i;

% 3. estatisticas de simbolos unicos
[symbolsValues, symbolsProbabilities] = getProbabilities(cell2mat(symbols(imageRead)),'uint32',@(X,i) X(i));
symbolInformationQuantities = -log2(symbolsProbabilities);
symbolsEntropy = sum(symbolsProbabilities.*symbolInformationQuantities);

% 3. estatisticas de simbolos de rle
for i=imageRead
    rleTuples{i} = rleEncode(symbols{i});
end
[rleTuplesValues, rleTuplesProbabilities] = getProbabilities([rleTuples{imageRead}],'char',@(X,i) X(i).toString());
rleTuplesInformationQuantities = -log2(rleTuplesProbabilities);
rleTuplesEntropy = sum(rleTuplesProbabilities.*rleTuplesInformationQuantities);

dict = huffmandict(rleTuplesValues, rleTuplesProbabilities);
encodedImage = huffmanenco(rleTuples{7}.toCell(), dict);
decodedImage = huffmandeco(encodedImage, dict);
areTheSame = areCellsEqual(decodedImage, rleTuples{7}.toCell());

% Extras. funcoes auxiliares
% Adiciona linhas/colunas a uma matriz que nao tem um tamanho 
% multiplo do tamanho do bloco
function [paddedMatrix, padding] = padMatrixForMultiple(M, divider)
    sizeReminder = mod(size(M), divider);
    padding = [0 0];
    if(sizeReminder(1) ~= 0)
        padding(1) = divider(1) - sizeReminder(1);
    end
    if (sizeReminder(2) ~=0)
        padding(2) = divider(2) - sizeReminder(2);
    end
    paddedMatrix = padarray(M, padding, 'post');
end

% remove o padding da matriz
function M = unpadMatrix(paddedMatrix, padding)
    %TO-DO
end

% Divide uma matriz MxN em um tensor AxBxN. As dimensoues MxN devem 
% multiplas de AxB respectivamente. Use a funcao [padMatrixForMultiple]
% para grantir isso. N = MxN/(AxB). Ou seja, o produto das dimensoes se mantem.
% a terceira dimensao eh utilizada para separar os blocos. Esse valor eh
% calculado varrendo a matriz principal em submatrizes AxB, da direita para
% esqueda, de cima para baixo.
function T = splitMatrixInBlocks(X, sweepSize)
    xSize = size(X);
    xSubSize = xSize./sweepSize;
    T = false(sweepSize(1),sweepSize(2),xSubSize(1)*xSubSize(2));
    for i=1:xSize(1)
        for j=1:xSize(2)
            innerI = mod(i-1,sweepSize(1)) + 1;
            innerJ = mod(j-1,sweepSize(2)) + 1;
            outterI = floor((i-1)/sweepSize(1)) + 1;
            outterJ = floor((j-1)/sweepSize(2)) + 1;
            k = outterI + (outterJ-1) * xSubSize(1); 
            T(innerI, innerJ, k) = X(i,j);
        end
    end
end

% transforma um tensor AxBxN de volta em uma matrix MxN
% cada bloco T(:,:,i) deve ter o mesmo tamanho. 
function M = joinMatrixBlocks(T)
    % TO-DO
end

% varre um bloco AxB de cima para baixo, 
% da esquerda para direita se j%2 = 1
% da direita para esquerda se j%2 = 0
% os valores sao acumulados em um vetor binario, que depois vira um uint.
function value = encodeBlock(m, binaryToIntMap)
    mSize = size(m);
    stream = false(1,mSize(1)*mSize(2));
    k=1;
    for i=1:mSize(1)
        if mod(i,2)==1
            for j=1:mSize(2)
                stream(k) = m(i,j);
                k=k+1;
            end
        else
            for j=mSize(2):-1:1
                stream(k) = m(i,j);
                k=k+1;
            end
        end
    end
    key = char(stream + '0');
    if(binaryToIntMap.isKey(key))
        value = binaryToIntMap(key);
    else
        value = bin2dec(key);
        binaryToIntMap(key) = value;
    end
end

function block = decodeBlock(value, blockSize)
    %TO-DO
end

function tuples = rleEncode(X)
    tuples = RleTuple(X(1), 1);
    k = 1;
    for i=2:length(X)
        if(X(i) == tuples(k).symbol)
            tuples(k) = tuples(k).bumpCount();
        else
            k = k + 1;
            tuples(k) = RleTuple(X(i),1);
        end
    end
end

function X = rleDecode(tuples)
    elements =  sum([tuples.count]);
    X = padarray([], [1 elements], tuples(1).symbol, "post");
    k = 1;
    for i=1:length(tuples)
        for j=1:tuples(i).count
            X(k) = tuples(i).symbol;
            k = k + 1;
        end
    end
end

function [values, prob] = getProbabilities(X, keyType, keyAccessCallback)
    dict = containers.Map('KeyType',keyType,'ValueType','double');
    for i=1:length(X)
        key = keyAccessCallback(X,i);         
        if(isKey(dict,key))
            dict(key) = dict(key) + 1;
        else
            dict(key) = 1.0;
        end
    end
    prob = cell2mat(dict.values);
    prob = prob/sum(prob);
    [prob, indexes] = sort(prob,'descend');
    keys = dict.keys;
    values = keys(indexes);
    %values = cell2mat(keys(indexes)); 
end

function [sortedX, sortedY] = sortTuplesBySecond(X,Y)
    [sortedY, indexes] = sort(Y, 'descend');
    sortedX = X(indexes);
end


