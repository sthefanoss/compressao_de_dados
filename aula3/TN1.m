close all; clear; clc;
% 1. gera matriz para imagem
img255 = imread('./corpusNP1/Binarizado10.jpg');
img = img255 == 255;

% 2. segmentar em blocos 2x2 | 4x4
img2x2Blocks = splitMatrixInBlocks(img, [2 2]);
img2x2Sweep = uint8(length(img2x2Blocks));
for i=1:length(img2x2Blocks)
    img2x2Sweep(i) = sweepMatrix(img2x2Blocks(:,:,i));
end

img4x4Blocks = splitMatrixInBlocks(img, [4 4]);
img4x4Sweep = uint16(length(img4x4Blocks));
for i=1:length(img4x4Blocks)
    img4x4Sweep(i) = sweepMatrix(img4x4Blocks(:,:,i));
end

% 3. estatisticas, entropia, rle etc 
[img2x2Symbols,img2x2Probabilities] = getProbabilities(img2x2Sweep);
[img2x2Symbols,img2x2Probabilities] = sortTuplesBySecond(img2x2Symbols,img2x2Probabilities);
H2x2Symbols = sum(-img2x2Probabilities.*log2(img2x2Probabilities));
[rle2x2Symbols,rle2x2Counts] = rleEncode(img2x2Sweep);
[xx,yy] = getProbabilities(formatRleTuples(rle2x2Symbols, rle2x2Counts));

[img4x4Symbols,img4x4Probabilities] = getProbabilities(img4x4Sweep);
[img4x4Symbols,img4x4Probabilities] = sortTuplesBySecond(img4x4Symbols,img4x4Probabilities);
H4x4Symbols = sum(-img4x4Probabilities.*log2(img4x4Probabilities));
[rle4x4Symbols,rle4x4Counts] = rleEncode(img4x4Sweep);



% Extras. funcoes auxiliares
function paddedX = padMatrixForMultiple(X, divider)
sizeReminder = mod(size(X), divider);
padSize = [0 0];
if(sizeReminder(1) ~= 0)
    padSize(1) = divider(1) - sizeReminder(1);
end
if (sizeReminder(2) ~=0)
    padSize(2) = divider(2) - sizeReminder(2);
end
paddedX = padarray(X, padSize, 'post');
end

function blocks = splitMatrixInBlocks(X, sweepSize)
X = padMatrixForMultiple(X, sweepSize);
xSize = size(X);
xSubSize = xSize./sweepSize;
blocks = false(sweepSize(1),sweepSize(2),xSubSize(1)*xSubSize(2));
for i=1:xSize(1)
    for j=1:xSize(2)
        innerI = mod(i-1,sweepSize(1)) + 1;
        innerJ = mod(j-1,sweepSize(2)) + 1;
        outterI = floor((i-1)/sweepSize(1)) + 1;
        outterJ = floor((j-1)/sweepSize(2)) + 1;
        k = outterI + (outterJ-1) * xSubSize(1); 
        blocks(innerI, innerJ, k) = X(i,j);
    end
end
end

function value = sweepMatrix(m)
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
value = 0;
for i=1:length(stream)
    if(stream(i) == 1)
        value = value + bitshift(1,length(stream) - i);
    end
end
end

function [values, prob] = getProbabilities(X)
    values(1) = X(1);
    k = 1;
    prob(1) = 1;
    for i=2:length(X)
        index = find(X(i)==values, 1);
        if(isempty(index))
            k = k + 1;
            values(k) = X(i);
            prob(k) = 1;
        else
            prob(index) = prob(index) + 1;
        end
    end
    prob = prob/sum(prob);
end

function [sortedX, sortedY] = sortTuplesBySecond(X,Y)
    for i=1:length(X)
        for j=i+1:length(X)
            if(Y(i)<Y(j))
                tempX = X(i); tempY = Y(i);
                X(i) = X(j); Y(i) = Y(j);
                X(j) = tempX; Y(j) = tempY;
            end
        end
    end
    sortedX = X;
    sortedY = Y;
end

function [values,counts] = rleEncode(X)
    values(1) = X(1);
    counts(1) = 1;
    k = 1;
    for i=2:length(X)
        if(X(i) == values(k))
            counts(k) = counts(k) + 1;
        else
            k = k + 1;
            values(k) = X(i);
            counts(k) = 1;
        end
    end
end

function tuples = formatRleTuples(values,counts)
    for i=1:length(values)
        tuples =  sprintf('(%d,%d)',values(i), counts(i));
    end
end

function X = rleDecode(values,counts)
    X = padarray([],[1 sum(counts)],values(1),"post")
    k = 1;
    for i=1:length(counts)
        for j=1:counts(i)
            X(k) = values(i);
            k = k + 1;
        end
    end
end