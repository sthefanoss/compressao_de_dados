% Leitura de arquivo texto e de arquivo audio
% Usamos dois arquivos de base exemplo.txt e exemplo.wav
clear all; close all;

% Le o texto palavra por palavra e caracter por caracter e coloca os
% simbolos encontrados em células individuais
mensagem_em_simbolos  = textread('exemplo1.txt', '%c');

L = length(mensagem_em_simbolos);

% Note que eu sei todos os caracteres possíveis de serem usados no texto.
% Nesse caso são apenas os caracteres ASCII entre '0' e '~'; 

Tabela = '0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^-`abcdefghijklmnopqrstuvwxyz{|}~ ';

% Notem que o índice de cada simbolo na tabela corresponde ao simbolo assim
% 1 corresponde ao simbolo '0', 23 corresponde ao simbolo F e assim por
% diante

% A codificação é o processo pelo qual todos os simbolos serão substituidos
% por referencias a tabela
N = length(mensagem_em_simbolos);
M = length(Tabela);
contagem = zeros(2,M);
for i=1:M
    contagem(1,i) = i;
end
for i=1:N % percorre to texto e substitui os simbolos pelos seus códigos
    simbolo = min(find(Tabela==mensagem_em_simbolos(i)));
    texto(i) = simbolo;
%     contagemSimbolos(simbolo) = contagemSimbolos(simbolo) + 1;
    contagem(2,simbolo) =  contagem(2,simbolo) + 1;
end
for i=1:80
    for j=i+1:80
        if(contagem(2,j)>contagem(2,i))
            troca = contagem(:,j);
            contagem(:,j) = contagem(:,i);
            contagem(:,i) = troca;
        end
    end
end
esp1 = sum(contagem(1,:).*contagem(2,:))/L;
x = split(Tabela(contagem(1,:)),'');
x = x(2:81);
y = contagem(2,:)/sum(contagem(2,:));
L=20;
bar(y(1:L));
set(gca, 'XTickLabel',x, 'XTick',1:length(x))



% Note-se que, a fim de reconstruir o texto basta ter o vetor de indices
mensagem_reconstruida = Tabela(texto);

% Na leitura de arquivos de audio, duas informações são fornecidas, um
% vetor com a informação adquirida e a taxa de amostragem
[msg_audio, taxa] = audioread('exemplo1.wav');

% Para tocar o som basta usar a função sound
%sound(msg_audio, taxa);

% Notem, no entanto, que o numero não é inteiro, idealmente seria
% necessário substituir cada valor por um índice para esse valor na escala
% de quantização
% Se olharmos as diferenças entre valores é possivel notar que existe um
% passo mínimo de quantizaçãode  0.0078125
% AQUIfigure; plot(diff(sort(msg_audio)));

% Uso esse passo para construir uma versão inteira do meu vetor de som
q = 0.0078125;
msg_audio_q = msg_audio./q;

% figure;
% AQUIplot(msg_audio_q);

% Os limites estão entre +112 e -111. Logo pode-se ver que é um numero de 
% oito bits com sinal. Assim, para obter indices, somo com a metade da
% faixa de escursão. Ou seja r = 8
r = 8;
Amp = 2^(r-1);
Centro = 2^(r-1); %Nesse caso são iguais, nao precisariam ser sempre
imsg = floor(msg_audio_q)+ Centro; 
% imsg esta entre 0 e 255 e pode ser considerado como simbolos a codificar
audioCount = zeros(2,2^r);
for i=1:2^r
    audioCount(1,i) = i-1;
end
for i=1:length(imsg)
    audioCount(2,imsg(i)) = audioCount(2,imsg(i)) + 1;
end
for i=1:length(audioCount)
    for j=i+1:length(audioCount)
        if(audioCount(2,j)>audioCount(2,i))
            troca = audioCount(:,j);
            audioCount(:,j) = audioCount(:,i);
            audioCount(:,i) = troca;
        end
    end
end
figure
esp2 = sum(audioCount(1,:).*audioCount(2,:))/length(imsg);
x2 = audioCount(1,:)+1;
y2 = audioCount(2,:)/sum(audioCount(2,:));
bar(y2);
set(gca, 'XTickLabel',x2, 'XTick',1:length(x2))

% Uma vez decodificado se obtem valores entre 0 e 255
% Para recuperar o sinal se deve subtrair o centro e dividir pela amplitude
msg_audio_recuperada = (imsg-Centro)./Amp;

% Com a informação de amostragem é possivel reproduzir o audio
%sound(msg_audio_recuperada, taxa);

