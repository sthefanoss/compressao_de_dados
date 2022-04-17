% Constroi uma distribuição não uniforme e a quantiza medindo o erro e
% comparando com a mesma distribuição usando um compandind

close all; clear all; clc;

% ETAPA1: Estabelece um sinal a ser quantizado aleatório com distribuicao não
% uniforme
N = 40000;
x = -4:.1:4; t = x;
x = rand(1,N)-rand(1,N);
id = find(x>0);
x = x(id);
L = length(x);


Xmax = max(x);
Xmin = min(x);


% Aproxima a distribuição de probabilidade pelo histograma. Usa numero alto
% M de bins. 
M = 200; 
xb = Xmin:(Xmax-Xmin)/(M-1):Xmax;
hx = hist(x, M)/L;
eixo = Xmin:(Xmax-Xmin)/(M-1):Xmax;


% ETAPA 2: Cria uma lei de companding usando a equação ótima proposta em aula e a
% distribuicao conhecida
x_comp =1-((1-x).^4/3);

% faz o histograma dessa nova lei
hx_comp = hist(x_comp, M)/L;
eixo = Xmin:(Xmax-Xmin)/(M-1):Xmax;

figure;
subplot(2,1,1)
bar(eixo, hx);
xlabel('x');
ylabel('fx original');

subplot(2,1,2)
bar(eixo, hx_comp);
xlabel('x');
ylabel('fx com companding definido');

% ETAPA 3: Compara a quantidade de informação por bin dos dois histogramas
I_x = log2(1./hx);
I_x_comp = log2(1./hx_comp);
H_x = hx.*I_x;
H_x_comp = hx_comp.*I_x_comp;

figure;
subplot(2,1,1); hold on;
plot(eixo, I_x);
plot(eixo, I_x_comp, 'r');

xlabel('x');
ylabel('Quantidade de Informação');

subplot(2,1,2); hold on;
plot(eixo, H_x);
plot(eixo, H_x_comp, 'r');

xlabel('x');
ylabel('Entropia por simbolo');
