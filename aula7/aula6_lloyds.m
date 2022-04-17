%Quantiza usando codebook e particoes escolhidas pelo método de Lloyds

clear all; close all;

% Define o sinal que será quantizado, nesse caso um sinal aleatorio
% gaussiano
N = 1000; 
t = 0:1/(N-1):1; 
s = 1/4.*randn(1,N);

%ETAPA 1: Cria um codebook uniforme e suas particoes. A regra a lembrar é que o
% número de particoes sempre é um a meos que o número de códigos. Uso r
% como a resolução pretendida
r = 3;
M = 2^r;
partition = [-1:2/(M-1):1];
codebook = [-1-2/(M-1):2/(M-1):1];

% Usa uniforme como chute inicial e otimiza
[partition2,codebook2] = lloyds(s,codebook);

%ETAPA 2: Quantiza o sinal com o codebook uniforme e com o novo
[index,sq,distor] = quantiz(s,partition,codebook);
[index2,s2q,distor2] = quantiz(s,partition2,codebook2);

% Exibe o sinal quantizado com cada um dos dois codebooks
figure;
subplot(2,1,1)
plot(t,s); hold on; plot(t,sq, 'r');
xlabel(sprintf('distorcao total = %f', distor));

subplot(2,1,2)
plot(t,s); hold on; plot(t,s2q, 'r');
xlabel(sprintf('distorcao total = %f', distor2));

% ETAPA3: Mostra a caracteristica entrada-saida dos dois quantizadores. Para isso
% cria um sinal uniforme que varre a entrada (x) e o quantiza. Isso deve
% mostrar a relacao entrada saída (degraus de quantização). 
x = -1:2/(N-1):1;

[ix,xq,dx] = quantiz(x,partition,codebook);
[ix2,x2q,dx2] = quantiz(x,partition2,codebook2);

figure; hold on;
plot(x,xq); hold on; plot(x,x2q, 'r');
axis([-1 1 -1 1]);
title(sprintf('Distorcao uniforme= %d. Distorcao não uniforme= %d', dx, dx2));
xlabel('x');
ylabel('Xq uniforme(b) Xq lloyd(r)');

% Notem que o uniforme é intencionalmente ruim pois é enviesado. Seria
% possível fazer um uniforme melhor usando o mesmo algoritmo de Lloyds,
% bastaria para isso usar como entrada no "treinamento" algum sinal de 
% distribuicao uniforme como o próprio x

[partition3,codebook3] =  lloyds(x,codebook);
[ix3,x3q,dx3] = quantiz(x,partition3,codebook3);

figure; hold on;
plot(x,xq); hold on; plot(x,x3q, 'r');
axis([-1 1 -1 1]);
title(sprintf('Compara uniforme (%d) e uniforme otimizado (%d) ', dx, dx3));
xlabel('x');
ylabel('Uniforme inicial(b) Uniforme ajustado(r)');
