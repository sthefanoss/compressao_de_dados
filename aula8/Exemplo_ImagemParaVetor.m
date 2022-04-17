% Nesse arquivo toma uma imagem e mostra a correlação entre pontos
% subsequentes. Usando blocos de dois a dois e de três a três exibe os
% dados em um espaço de coordenadas.

clear all; close all; clc;

% Primeiro lê a imagem, que ja foi previamente salva. É uma imagem em
% escala de cinza.
load 'imagem3'; % a imagem esta armazenada na variavel imagem

% Exibe a imagem
figure;
subplot(2,2,1);
imshow(imagem);
title('Essa é a imagem que será analisada');

M = length(imagem(1,:));
N = length(imagem(:,1));

% Mostra o histograma dos valores
H_im = hist(single(imagem), 256);

% Exibe os histogramas de x e y
subplot(2,2,3); hold on;
bar(0:255, H_im);

axis([0 255 0 20]);
xlabel('Histograma da imagem');

% Toma todos os pontos dois a dois (considera blocos de 2) e os coloca no
% vetor de imagem v_im

k = 1;
for i = 1:M
    for j = 1:2:N
        v_im(k,:) = imagem(i,j:j+1);
        k = k+1;
    end;
end;

% Exibe o vetor de imagem que foi construído
subplot(2,2,2);
plot(v_im(:,1), v_im(:,2), 'k.');
ylabel('x_1');
xlabel('x_0');
title('Dispersao de pontos tomados dois a dois');
axis([0 255 0 255]);
view(2);

% Toma todos os pontos três a três (considera blocos de 3) e os coloca no
% vetor de imagem v_im

k = 1;
for i = 1:M
    for j = 1:3:N
        v3_im(k,:) = imagem(i,j:j+2);
        k = k+1;
    end;
end;

% Exibe o vetor tridimensional de dispersão. 
subplot(2,2,4);
plot3(v3_im(:,1), v3_im(:,2), v3_im(:,3), 'k.');
zlabel('x_3');
ylabel('x_1');
xlabel('x_0');
title('Dispersao de pontos tomados três a três');
axis([0 255 0 255]);
view(3);

