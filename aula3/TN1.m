close all; clear; clc;
% 1. gera matriz para imagem
img = imread('./corpusNP1/Binarizado10.jpg');

% 2. segmentar em blocos 2x2 | 4x4
img2x2Blocks = splitMatrixInBlocks(img, [2 2]);
img4x4Blocks = splitMatrixInBlocks(img, [4 4]);

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

function sweep = splitMatrixInBlocks(X, sweepSize)
X = padMatrixForMultiple(X, sweepSize);
xSize = size(X);
xSubSize = xSize./sweepSize;
sweep = zeros(sweepSize(1),sweepSize(2),xSubSize(1)*xSubSize(2));
for i=1:xSize(1)
    for j=1:xSize(2)
        innerI = mod(i-1,sweepSize(1)) + 1;
        innerJ = mod(j-1,sweepSize(2)) + 1;
        k = floor((i-1)/xSubSize(2))*xSubSize(2) + floor((j-1)/xSubSize(2))+1;
        sweep(innerI, innerJ, k) = X(i,j);
    end
end
end