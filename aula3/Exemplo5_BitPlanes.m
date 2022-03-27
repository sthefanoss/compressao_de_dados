% Versao 2018: Esse exemplo mostra como se pode tomar uma matriz qualquer formado apenas
% por zeros e uns e organizar essa matriz em planos de bits. Mostra tambem
% como a organização em plano de bits naturalmente gera a ocorrência de
% corridas de zeros e uns.

clear all; close all;


% Uso randsrc para gerar um vetor 1xN de valores aleatorios. 
% Notem que para gerar um vetor pastaria mudar os parametros para 1xN ou
% Nx1. A vantagem de usar essa função é que ela permite que se defina 
% o alfabeto do qual os valores serão sorteados. Nesse caso uso números 
% inteiros de 0 a 15
im_rgb = imread('imagem2.jpeg');
im_gray = rgb2gray(im_rgb);


% calcula as dimensoes da matriz
altura  = length(im_gray(:,1));
largura = length(im_gray(1,:));
L = altura*largura; 

% lineariza a matriz de imagem(transforma em vetor)
vetor = reshape(im_gray, 1,L);

thr = 180;
vetor_b = vetor > thr;
vetor = vetor_b;

% Exibo o vetor como uma imagem. Cada valor é mostrado como um ponto e a
% intensidade da cor é proporcional ao valor do ponto (valor mais alto
% ponto mais claro)
figure; subplot(2,1,1);
imshow(im_gray);
title('Imagem de referencia');
subplot(2,1,2);
bar(1:L, sort(vetor, 'descend'));
title('Valores do vetor, notem que valores altos são cores claras na imagem');
axis([0 L 0 300]);

% Transformo todos os números em binarios de tamanho fixo R bits com a função
% dec2bin. Os numeros binarios são para o MATLAB strings e podem ser
% tratados sempre como tal
R = 8;
vetorbin = dec2bin(vetor, R);

% Construo os bitplanes. Cada plano de bits corresponde a um dado bit para
% todos os elementos da matriz. Assim serão geradas oito matrizes comecando
% com uma contendo todos os bits mais significativos e terminando com
% todos os bits menos significativos
for i=1:R
    plano_de_bits(i,:) = bin2dec(vetorbin(:,i));
end;

% Mostro os planos de bits. Os números são todos zero e um, para aparecer 
% contraste na imagem uso um multiplicador.

figure; subplot(1,2,1);
imshow(255*reshape(plano_de_bits(1,:), altura, largura));
title('Plano de bits mais significativo');
% subplot(2,2,2);
% bar(1:L, plano_de_bits(1,:));
% title('Valores do plano mais significativo');
% axis([0 L 0 1.5]);


subplot(1,2,2);
imshow(255*reshape(plano_de_bits(R,:), altura, largura));
title('Plano de bits menos significativo');
% subplot(2,2,4);
% bar(1:L, plano_de_bits(R,:));
% title('Valores do plano menos significativo');
% axis([0 L 0 1.5]);

disp('Notem como cada plano de bits reune uma das colunas do vetor em binario');
disp(vetorbin);

