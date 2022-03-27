% Nesse exemplo faço a leitura de uma imagem

clear all; close all;

% Le a imagem
im_rgb = imread('imagem3.jpeg');
im_gray = rgb2gray(im_rgb);
% im_YCbCr = rgb2ycbcr(im_rgb);

count = zeros(2,2^8);
for i=1:2^8
    count(1,i) = i;
end
for i=1:length(im_gray)
    count(2,im_gray(i)) = count(2,im_gray(i)) + 1;
end
for i=1:length(count)
    for j=i+1:length(count)
        if(count(2,j)>count(2,i))
            troca = count(:,j);
            count(:,j) = count(:,i);
            count(:,i) = troca;
        end
    end
end
H = 0.0;
for i=1:2^8
    p = count(2,i)/length(count);
    if(p ~= 0)
        H = H - p * log2(p);
    end
end
Bits = ceil(H*length(count));

% calcula as dimensoes da matriz
altura  = length(im_gray(:,1));
largura = length(im_gray(1,:));
L = altura*largura; 

% Se eu quiser posso lineariza a matriz de imagem(transforma em vetor)
vetor_total = reshape(im_gray, 1,L);

% vetor_Y = reshape(im_YCbCr(:,:,1), 1,L);
% vetor_Cb = reshape(im_YCbCr(:,:,1), 1,L);
% vetor_Cr = reshape(im_YCbCr(:,:,1), 1,L);

% Cada um dos pontos agora tem numeros de 0 a 255
% Se eu quiser posso ainda converter todos os pontos em binario com 8 bits
vetor_binario = dec2bin(vetor_total, 8);

% Notem que esse vetor binario pode ser organizado como melhor achar

% O processo inverso é simples, mas, mais uma vez precisamos de informação adicional
% No caso, as dimensões e a resolução da imagem

vetor = bin2dec(vetor_binario(:,1));

% Se eu entar visualizar o vetor como uma imagem, verei que nao tem padrao
imshow(reshape(vetor, altura, largura));
 
