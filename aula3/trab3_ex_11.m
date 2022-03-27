% trab3 exercicio 9
close all; clear; clc;

im_rgb = imread('imagem3.jpeg');
im_gray = rgb2gray(im_rgb);
imshow(im_gray)

buffer = im_gray;
figure
for  i=1:8

planes(:,:,i) = mod(buffer,2);
subplot(2,4,i)
imshow(planes(:,:,i)*255)
buffer = bitshift(buffer,-1);
end

corrida = reshape(planes(:,:,8)',1,[]);

previousValue = -1;
indiceRLE = 0;

for i=1:length(corrida)
    if(corrida(i) == previousValue)
        C(indiceRLE) = C(indiceRLE) + 1;
    else
        indiceRLE=indiceRLE+1;
        C(indiceRLE) = 1;
        V(indiceRLE) = corrida(i);
        previousValue = corrida(i);
    end
end

tuplasV = strings;
tuplasC = [];
for i=1:length(V)
    tupla = sprintf("(%d,%d)",C(i),V(i));
    index = find(tuplasV == tupla);
    if(isempty(index))
        newIndex = length(tuplasV)+1;
        tuplasV(newIndex) = tupla;
        tuplasC(newIndex) = 1;
    else
        tuplasC(index) = tuplasC(index) + 1;
    end
end

for i=1:length(tuplasV)
    for j=i+1:length(tuplasV)
        if(tuplasC(j)>tuplasC(i))
            trocaC = tuplasC(j);
            trocaV = tuplasV(j);
            tuplasV(j) = tuplasV(i);
            tuplasC(j) = tuplasC(i);
            tuplasV(i) = trocaV;
            tuplasC(i) = trocaC;
        end
    end
end
tuplasC = tuplasC(1:length(tuplasC)-1);
tuplasV = tuplasV(1:length(tuplasV)-1);
p = tuplasC/sum(tuplasC);
h = sum(-p.*log2(p));
L = h*length(C);
