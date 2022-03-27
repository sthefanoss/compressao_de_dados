% trab3 exercicio 9
close all; clear; clc;

im_rgb = imread('imagem4.jpeg');
im_gray = rgb2gray(im_rgb);
% imshow(im_gray)

buffer = im_gray;
% figure
for  i=1:8
    planes(:,:,i) = mod(buffer,2);
    subplot(2,4,i)
    imshow(planes(:,:,i)*255)
    buffer = bitshift(buffer,-1);
end

tamanho = 2;
img_size = size(im_gray);
plano8 = planes(:,:,8);

for i=1:img_size(1)
    for j=1:img_size(2)
        blocos(ceil(i/tamanho),ceil(j/tamanho),mod(i,tamanho)+1,mod(j,tamanho)+1) = plano8(i,j);
    end
end

tuplasV = strings;
tuplasC = [];
for i=1:ceil(img_size(1)/tamanho)
    for j=1:ceil(img_size(2)/tamanho)
        flipped = flip(reshape(blocos(i,j,:,:),1,[]));
        tupla =   join(string(flipped));
        tupla = strrep(tupla,' ','');
        tupla = split(tupla,'');
        tupla = tupla(2:length(tupla)-1);
        tupla = join(reshape(tupla,4,[]));
        tupla = strrep(tupla,' ','');
            tupla = strrep(tupla,'0000','0');
            tupla = strrep(tupla,'0001','1');
            tupla = strrep(tupla,'0010','2');
            tupla = strrep(tupla,'0011','3');
            tupla = strrep(tupla,'0100','4');
            tupla = strrep(tupla,'0101','5');
            tupla = strrep(tupla,'0110','6');
            tupla = strrep(tupla,'0111','7');
            tupla = strrep(tupla,'1000','8');
            tupla = strrep(tupla,'1001','9');
            tupla = strrep(tupla,'1010','A');
            tupla = strrep(tupla,'1011','B');
            tupla = strrep(tupla,'1100','C');
            tupla = strrep(tupla,'1101','D');
            tupla = strrep(tupla,'1110','E');
            tupla = strrep(tupla,'1111','F');
        tupla = join(tupla);
        tupla
        index = find(tuplasV == tupla);
        if(isempty(index))
            newIndex = length(tuplasV)+1;
            tuplasV(newIndex) = tupla;
            tuplasC(newIndex) = 1;
        else
            tuplasC(index) = tuplasC(index) + 1;
        end
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
L = h*length(tuplasV);
