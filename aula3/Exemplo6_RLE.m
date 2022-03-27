% Gera uma sequencia de números aleatória em que o próximo valor depende do
% valor atual. Isso deve gerar numero consideravel de corridas de zero e de
% um.
% Em seguida calcula o numero de corridas de zero e de um.

clear all; close all;

% Define o tamanho da sequencia de valores
N = 100;

% Define N valores aleatorios entre 0 e 1
ale = rand(1,N);

% Inicializa a saida com o tamanho certo
vetor = zeros(1,N);

% Parte 1: Primeiro elemento tem 50% de chance de ser 1 ou 0
if ale(1) >0.5
    vetor(1) = 1;
end;

for i=1:(N-1)
    % Passo 2: se o valor anterior é zero aplica as probabilidades
    if vetor(i) == 0
        vetor(i+1) = (ale(i+1)<1/3); % chance de ir para 1 é de 1/3
    end;
    
    if vetor(i) == 1
        vetor(i+1) = (ale(i+1)<0.6); % chance de ficar em 1 é de 60%
    end;
end;

% Salva o vetor criado para ser usado por voces a tarefa
save('VetorCondicional', 'vetor');

clear all; close all; % Limpei tudo, ou seja, a partir daqui é como se fosse comecar do zero

% Parte 2: A partir daqui implementa um algoritmo rapido de contagem de corridas de
% zeros e corridas de uns

% Quando forem fazer o código de voces comecem carregando o vetor salvo
load('VetorCondicional', 'vetor');

% Encontra zeros uns e retorna o indice para todos
idx1 = find(vetor==0); idx2 = find(vetor==1);

% Localiza diferencas de indices maiores que um (indicam que são trechos
% separados de uns ou zeros


l1 = find(idx1(2:end)>(idx1(1:end-1)+1));
l2 = find(idx2(2:end)>(idx2(1:end-1)+1));

% Aponta para todas as transicoes de zero para um e de um para zero
% Se queremos detectar corridas existe 
zeropraum = idx1(l1); umprazero = idx2(l2);

% Trata agora os casos de inicio e fim
% Se o vetor comeca em zero para a contagem estar correta tem que colocar o
% indice zero na primeira posicao de umprazero, caso contrario coloca o
% indice zero na primeira posicao de zeropraum
if vetor(1) == 0
    umprazero = [0 umprazero];
else
    zeropraum = [0 zeropraum];
end;

% Se o vetor termina em zero a ultima corrida inicia no ultimo indice um e
% termina no fim do vetor
if vetor(end) == 0
    zeropraum = [zeropraum length(vetor)];
    umprazero = [umprazero idx2(end)];
else
    zeropraum = [zeropraum idx1(end)];
    umprazero = [umprazero length(vetor)];
end;

% Calcula vetores de corrida de zeros e de uns
if zeropraum(1) == 0
    L1 = length(umprazero); L2 = length(zeropraum);
    RL_1 = umprazero(1:L1) - zeropraum(1:L1);
    RL_0 = zeropraum(2:L2) - umprazero(1:L2-1);
end;
if umprazero(1) == 0
    L1 = length(zeropraum); L2 = length(umprazero);
    RL_1 = umprazero(2:L2) - zeropraum(1:L2-1);
    RL_0 = zeropraum(1:L1) - umprazero(1:L1);
end;

%Exibe frequencia de corridas de cada tamanho
figure;
subplot(1,2,1);
hist(RL_1, max(RL_1));
ylabel('Corridas encontradas');
xlabel('Comprimento de corrida(L)');
title('Corridas de 1´s');

subplot(1,2,2);
hist(RL_0, max(RL_0));
ylabel('Corridas encontradas');
xlabel('Comprimento de corrida (L)');
title('Corridas de 0´s');

% Salva esses vetores para usar nas atividades de organização de imagem
figure;
imshow(reshape(vetor,10,10));