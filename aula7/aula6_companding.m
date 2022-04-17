% Constroi uma distribuição não uniforme e a quantiza medindo o erro e
% comparando com a mesma distribuição usando um compandind

close all; clear all; clc;

% Estabelece um sinal a ser quantizado aleatório com distribuicao não
% uniforme
N = 1000;
x = -4:.1:4;
x = exp(x);

t = 0:1/(N-1):1;

Xmax = max(x);
Xmin = min(x);


% Aproxima a distribuição de probabilidade pelo histograma. Usa numero alto
% M de bins
M = 200; xb = Xmin:(Xmax-Xmin)/(M-1):Xmax;
hx = hist(x, M)/N;

% Faz companding com a lei u
mu = 255;
A = 87.56;
x_mu = compand(x, mu, Xmax, 'mu/compressor');
hx_mu = hist(x_mu, M)/N;

% Faz companding com a lei A
x_A = compand(x, A, Xmax, 'A/compressor');
hx_A = hist(x_A, M)/N;

% Compara as três versões de distribuição com companding
figure;
subplot(3,1,1)
bar(xb, hx)
xlabel('Quantizado uniforme')
subplot(3,1,2)
bar(xb, hx_mu)
xlabel('Compressor mu')
subplot(3,1,3)
bar(xb, hx_A)
xlabel('Compressor A')


% Quantiza o sinal de forma regular, e faz o mesmo com os sinais que
% passaram por companding

% Na funcao i é o indice do valor quantizado (qual a cada de quantixacao),
% qx é o valor quantizado e dx é a distorcao
partition = 0:floor(Xmax);
codebook = 0:ceil(Xmax);

[ix,qx,dx] = quantiz(x,partition,codebook);
[ix_mu,eqx_mu,dx_mu] = quantiz(x_mu,partition,codebook);
[ix_A,eqx_A,dx_A] = quantiz(x_A,partition,codebook);

% Agora retorna as funções que passaram por compander para sua faixa normal
qx_mu = compand(eqx_mu,mu,Xmax,'mu/expander');
qx_A  = compand(eqx_A,A,Xmax,'A/expander');

% Calcula a SNR de qx, qx_mu e qx_A
% Determina a varianca do sinal antes da quantizcao
var_x = var(x);
% Determina a varianca do erro de quantizaxao em cada caso
var_e_qx = sum((x-qx).^2)/N;
var_e_qx_mu = sum((x-qx_mu).^2)/N;
var_e_qx_A = sum((x-qx_A).^2)/N;


% Calcula a SNR
SNR_xq    = 10*log10(var_e_qx./var_x);
SNR_xq_mu = 10*log10(var_e_qx_mu./var_x);
SNR_xq_A  = 10*log10(var_e_qx_A./var_x);

% Mostra a distribuicao final dos sinais quantizados
hxr = hist(qx,M)/N;
hxr_mu = hist(qx_mu,M)/N;
hxr_A  = hist(qx_A,M)/N;

% Compara as três versões de distribuição de sinal reconstruido após quantizacao
figure;
subplot(3,1,1)
bar(xb, hxr)
xlabel(sprintf('Sinal reconstruido quantizado SNRq: %f',SNR_xq));

subplot(3,1,2)
bar(xb, hxr_mu)
xlabel(sprintf('Sinal reconstruido u-law SNRq: %f',SNR_xq_mu));

subplot(3,1,3)
bar(xb, hxr_A)
xlabel(sprintf('Sinal reconstruido quantizado SNRq: %f',SNR_xq_A));

