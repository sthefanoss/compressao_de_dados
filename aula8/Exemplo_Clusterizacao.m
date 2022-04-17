% Nesse arquivo mostro a idéia basica por trás da clusterização e como os
% vetores de centroide representam a subdivisão do espaço

clear all; close all; clc;

% Em primeiro lugar lê um conjunto de dados. Nesse caso o arquivo dangerous
% que contem dados de voz em uma variável data

load ('dangerous');

% Tomando os dados como um conjunto de vetores, exibe a dispersao 
xdados = dados(1:2:end-1);
ydados = dados(2:2:end);

% Total de vetores necessarios
N = length(xdados);

plot(xdados, ydados, 'g.')
title('Dispersão de dados na variável de entrada');

% O algoritmo de clusterização procura subdividir os dados em um conjunto
% de vetores que melhor representam o total de dados sem assim ser
% necessário impor uma métrica fixa. No caso exibido é evidente que os
% dados não se espalham igualmente em todas as direções.

% Defino que vou usar apenas uma fracao 1/K do total de pontos de entrada
K = 1000;
M = 32; %round(N/K);

% Defino M vetores de saída
X = [xdados ydados];
[cidx, ctrs] = kmeans(X, M);

hold on;
plot(ctrs(:,1), ctrs(:,2), 'mx', 'LineWidth',2);
xlabel ('Os pontos mostram os centros de vetores significativos');
pause;
voronoi(ctrs(:,1), ctrs(:,2));
pause;

% É evidente que se aumentarmos o numero de pontos, mesmo assim iremos
% precidar de menos vetores para representar todos os dados
[cidx, ctrs] = kmeans(X, M*10);
X = [xdados ydados];

figure; plot(xdados, ydados, 'g.')
title('Usando centros mais significativos preciso de menos intervalos');

hold on;
plot(ctrs(:,1), ctrs(:,2), 'mx', 'LineWidth',2);
xlabel ('Os pontos mostram os centros de vetores significativos');
voronoi(ctrs(:,1), ctrs(:,2));


% dadosX = (sinal);
% dadosY = (diferenca);
% 
% figure;
% plot(dadosX, dadosY, '.');
% 
% X = [dadosX dadosY];
% opts = statset('Display','final');
% [cidx, ctrs] = kmeans(X, 4);
% plot(X(cidx==1,1),X(cidx==1,2),'r.', ...
% X(cidx==2,1),X(cidx==2,2),'g.',...
% X(cidx==3,1),X(cidx==3,2), 'b.', X(cidx==4,1),X(cidx==4,2), 'c.',...
% ctrs(:,1),ctrs(:,2),'kx', 'LineWidth', 3);
% title('espalhamento do sinal e sua diferenca primeira');
% grid on;
% 
% dadosX = (sinal);
% dadosY = dct(sinal);
% 
% figure;
% plot(dadosX, dadosY, '.');
% 
% X = [dadosX dadosY];
% opts = statset('Display','final');
% [cidx, ctrs] = kmeans(X, 4);
% plot(X(cidx==1,1),X(cidx==1,2),'r.', ...
% X(cidx==2,1),X(cidx==2,2),'g.',...
% X(cidx==3,1),X(cidx==3,2), 'b.', X(cidx==4,1),X(cidx==4,2), 'c.',...
% ctrs(:,1),ctrs(:,2),'kx', 'LineWidth', 3);
% title('espalhamento do sinal e sua transformada');
% grid on;
%  
% 
% 