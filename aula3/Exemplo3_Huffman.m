% Exemplo de uso do biblioteca de c�difica��o huffman no Matlab

clear all; close all;

im_rgb = imread('imagem3.jpeg');
im_gray = rgb2gray(im_rgb);
figure;
imshow(im_gray)
im_gray_vetor = reshape(im_gray,1,[]);

count = zeros(2,2^8);
for i=1:2^8
    count(1,i) = i-1;
end
for i=1:length(im_gray_vetor)
    symbol = im_gray_vetor(i) + 1;
    count(2,symbol) = count(2,symbol) + 1;
end
alfabeto = count(1,:);
p = count(2,:)/length(im_gray_vetor);
esperado = sum(p.*alfabeto);
potenciaDe2 = 2^floor(log2(esperado));
% Cria o dicionario e mostra
[dicionario, L] = huffmandict(alfabeto, p);

t_entra = length(im_gray_vetor)*8;
% Codifica o texto criado com o dicionario huffman construido
texto_sai = huffmanenco(im_gray_vetor, dicionario);
figure;
t_sai = length(texto_sai);
texto_volta = huffmandeco(texto_sai, dicionario);
im_volta_redimensionado = uint8(reshape(texto_volta,size(im_gray)));
imshow(im_volta_redimensionado)