% Implementa o código Elias Gamma
clear all; close all;
N = 25;
i = 1:N; % Gera uma sequencia de números para converter
% Efetua a codificação por Elias Gamma
for i=1:N
% Passo 1: calcula o número em binário
M = floor(log2(i));
L = i - 2^M;
beta = dec2bin(M+1);
% Passo 2: Seu comprimento é um número M
MM = length(beta);
% Passo 3: Gera um prefixo formado por M-1 zeros seguidos de 1
if (MM-1) > 0
prefixo = repmat('0',1,MM-1);
end
% Passo 4: Anexa prefixo ao numero (uso celulas pq sao strings de tamanho
% diferente em cada indice
if (MM-1) > 0
numero{i} = strcat(prefixo, beta, pad(dec2bin(L),MM-1,'left','0'));
else
numero{i} = beta;
end
end
% Exibe os primeiros L elementos do conjunto de códigos
L = 25;
for i=1:L
codigo = numero(i);
disp(sprintf('n:%d -> %s',i, codigo{:}));
end
