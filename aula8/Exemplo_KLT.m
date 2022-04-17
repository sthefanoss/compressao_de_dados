% Nesse arquivo calcula a transformada KLT de um conjunto de imagens
% tomando os pontos dois a dois. Mostra que a quantização ao londo do eixo
% transformado é melhor do que 

clear all; close all; clc;

% Primeiro lê a imagem, que ja foi previamente salva. É uma imagem em
% escala de cinza.
load 'imagem3'; % a imagem esta armazenada na variavel imagem

% ETAPA 1: Toma todos os pontos dois a dois (considera blocos de 2) e os coloca no
% vetor de imagem v_im
M = length(imagem(1,:));
N = length(imagem(:,1));

k = 1;
for i = 1:M
    for j = 1:2:N
        v_im(k,:) = imagem(i,j:j+1);
        k = k+1;
    end;
end;
v_im = double(v_im);

% Calcula os histogramas dos dados que foram agrupados em v_im
% Calcula o histograma dos pontos x0
hist_x0 = hist(v_im(:,1), 256);

% Calcula o histograma dos pontos x0
hist_x1 = hist(v_im(:,2), 256);

figure;
subplot(2,1,1)
bar(0:255, hist_x0);
axis([0 255 0 500]);
xlabel('x_0');
ylabel('histograma de x_0');
subplot(2,1,2)
bar(0:255, hist_x1);
axis([0 255 0 500]);
xlabel('x_1');
ylabel('histograma de x_1');

% ETAPA 2: Calcula a transformada de Karhunen-Loeve
[V,D]=eig(cov(v_im));
KLT = V' * v_im';

% Calcula o histograma do sinal transformado
hist_kx0 = hist(KLT(2,:),256);
hist_kx1 = hist(KLT(1,:),256);

figure;
subplot(2,2,1)
plot(v_im(:,1), v_im(:,2), '.');
axis([0 255 0 255]);
title('Dispersao original')
subplot(2,2,2)
title('Karhunen-Loeve')
plot(KLT(2,:), KLT(1,:),'r.');
axis([0 255 -255 255]);

% Mostra o histograma do sinal transformado e do original
subplot(2,2,3); hold on;
plot(0:255, hist_x0);
plot(0:255, hist_x1,'r');
xlabel('x_0, x_1');
ylabel('histograma de x_0 (b) x_1(r)');
axis([0 255 0 500]);

subplot(2,2,4); hold on;
plot(0:255, hist_kx0);
plot(0:255, hist_kx1,'r');
xlabel('kx_0, kx_1');
ylabel('KHT de x_0 (b) x_1(r)');
axis([0 255 0 1500]);