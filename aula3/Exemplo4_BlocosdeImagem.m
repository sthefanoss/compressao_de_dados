% Nesse exemplo faço a leitura de uma imagem

clear all; close all;

% Le a imagem
im_rgb = imread('imagem2.jpeg');
im_YCbCr = rgb2ycbcr(im_rgb);

% calcula as dimensoes da matriz
altura  = length(im_rgb(:,1,1));
largura = length(im_rgb(1,:,1));
L = altura*largura; 

% Vou usar so a luminancia para exemplificar (e faco multiplo de 16
ima_entrada = 255*ones(ceil(altura/16)*16, ceil(largura/16)*16);
ima_entrada(1:altura, 1:largura) = im_YCbCr(:,:,1);

% A ideia aqui é ler blocos de um tamanho fixo de pontos e guardar essa
% informação em sequencia
% Primeiro defino o bloco (no caso uso 16x16)
h = 16; k =1;
v = 16; wv = 1:v;

bloco = ima_entrada(wv+3*16, wv+2*16);
imshow(bloco/256);
