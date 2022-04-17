% Nesse arquivo analisamos a fun��o caracteristica de um sinal para
% determinar o quanto ele pode ser requantizado com menor granularidade.

clc; clear all; close all

% Utilizamos o sinal de voz que j� esta em .mat e carrega mais rapidamente.
% Dentro do arquivo o sinal se encontra em dados.
load dangerous.mat

% Passo 1: Carrega o sinal e calcula sua distribui��o de probabilidade aproximada
% pelo histograma. Utiliza um n�mero de bins inicial do histograma elevado.
% � esse numero que representa a "amostragem em amplitude" do sinal e que
% vai corresponder ao qu�o bem o mesmo pode ser quantizado

% Os dados que ser�o analisados ir�o ficar em s
s = dados; N = length(s);

% A frequencia de amostragem desse sinal � de 5kHz, 
fa = 5000;

% Define o vetor tempo com a dura��o do periodo de aquisicao
T = fa*N;
t = 0:T/(N-1):T; % vetor tempo

% Define um histograma para aproximar a fun��o distribui��o de
% probabilidade do sinal
M = 300; % numero de subdivisoes da faixa dinamica
fs = hist(dados,M)/N; % distribui��o de probabilidade aproximada
Cf = fftshift(fft(fs)); % func�o caracteristica

% Define o eixo da fun��o densidade de probabilidades
eixo_s = -1:2/(M-1):1;
% Define o eixo da fun��o caracteristica
omega = (-M/2+1):M/2;

% Encontra o maior valor n�o zero da fun��o caracteristica
idx = find(abs(Cf)>.02);
i_min = min(idx);
i_max = max(idx);
Maximo = omega(i_max);


figure;
subplot(3,1,1);
plot(t,s);
title('sinal no tempo');
ylabel('s'); xlabel('t');
subplot(3,1,2)
plot(eixo_s,fs);
title('distribui��o de probabilidades');
ylabel('f_s(s)'); xlabel('s');

subplot(3,1,3); hold on;
plot(omega, abs(Cf));
title('fun��o caracter�stica 2\pi/q, marcas indicam |Cf|>.02,');
text(25,0.5, sprintf('u_{max} = %d, logo qmax=1/(2x%d)', Maximo, Maximo));
xlabel(sprintf('M�ximo = %f',Maximo));
plot(omega(i_min), 0, 'rd');
plot(omega(i_max), 0, 'rd');
ylabel('\Phi_s(u)'); xlabel('u');

%break;
% Passo 2: Determino q. Nota-se que o sinal desaparece para fun��o caracteristica com
% |omega|<9. Lembrando que pelo QT1 Psi/2 tem que ser maior que a banda da
% CF. Assim Psi tem que ser maior que o dobro disso. Como a frequencia corresponde ao
% intervalo completo subdividido por isso precisamos de um passo q < 1/18
q = 1/(2*Maximo) % calculado pelo m�ximo da CF

% Passo 3: Requantizo com esse novo n�mero de divisoes e vejo como fica a
% distribui��o

sq = floor(s/q)*q;

% Calcula de novo
fsq = hist(sq,M)/N; % distribui��o de probabilidade aproximada
Cfq = fftshift(fft(fsq)); % func�o caracteristica

% repete o mesmo usando passo ainda menor
q2 = q/2;
sq2 = floor(s/q2)*q2;
fsq2 = hist(sq2,M)/N; % distribui��o de probabilidade aproximada
Cfq2 = fftshift(fft(fsq2)); % func�o caracteristica

%Calcula as resolucoes para os dois casos (vou usar isso na reconstrucao)
DR = max(s)-min(s);
subq = round(DR/q);
res_q = ceil(log2(subq));

subq2 = round(DR/q2);
res_q2 = ceil(log2(subq2));


figure;
subplot(4,2,1)
plot(eixo_s,fsq);
title(sprintf('PDF, q=%f (maximo)',q));
ylabel('f_s_q(s)'); xlabel('s_q');
subplot(4,2,3); hold on;
plot(omega, abs(Cfq));
title(sprintf('CF, q=%f (maximo)',q));
ylabel('\Phi_s_q(u)'); xlabel('u_q');
subplot(4,2,5)
plot(eixo_s,fsq2);
title(sprintf('PDF, q=%f (metade)',q/4));
ylabel('f_s_{q2}(s)'); xlabel('s_{q2}');
subplot(4,2,7); hold on;
plot(omega, abs(Cfq2));
title(sprintf('CF, q=%f (metade)',q/4));
ylabel('\Phi_s_{q2}(u)'); xlabel('u_{q2}');


w = 300:400;
% Agora exibe um trecho do sinal original e das duas quantiza��es
subplot(2,2,2); hold on; %grid on;
plot(t(w), s(w), 'r'); 
plot(t(w), sq(w), 'b'); 
axis([t(w(1)) t(w(end)) -.15 .15]);
ylabel('s_q1');
xlabel('t')
subplot(2,2,4); hold on; %grid on;
plot(t(w), s(w), 'r'); 
plot(t(w), sq2(w), 'b'); 
axis([t(w(1)) t(w(end)) -.15 .15]);
ylabel('s_q2');
xlabel('t')

% Reconstruir a PDF original pode ser feito pelo m�todo do livro
% ('Quantizaion Noise') na sua p�gina 73 (ver isso para a tarefa).

% Aqui vou me preocupar com a melhoria do sinal faco isso usando uma funcao
% de smoothing simples e compensando o offset. � possivel fazer melhor mas
% � o suficiente para ilustrar o ponto

r_s = smooth(sq-mean(sq)+mean(s),'sgolay');
r_s2 = smooth(sq2-mean(sq2)+mean(s),'sgolay');

erro = mean(abs(s-r_s));
erro2 = mean(abs(s-r_s2));

subplot(2,2,2); hold on; %grid on;
plot(t(w),r_s(w), 'k:');
title(sprintf('Res: %d bits, Erro: %f',res_q, erro));
legend('s', 's_q', 'r_{s_q}');
subplot(2,2,4); hold on; %grid on;
plot(t(w),r_s2(w), 'k:');
title(sprintf('Res: %d bits, Erro: %f',res_q2, erro2));
legend('s', 's_q', 'r_{s_{q2}}');

%Notem que o aumento de resolu��o trouze uma diminui��o no erro, mas n�o
%foi muito elevada (~20% menos erro com dois bits a mais). 
% Mais bits trarao melhorias decrescentes. 
% ATIVIDADE: mudem q2 para q/4 (linha 79) e verifiquem a melhoria (erro2/erro)

% ATIVIDADE: mudem o segundo passo de quantiza��o para um valor MAIOR que
% o m�ximo estimado (por exemplo 2*q) e verifiquem (erro2/erro). 

% Notem que isso corresponde a apenas usar um bit a menos do que o valor definido pelo
% m�todo da fun��o caracteristica indica.