% Um exemplo simples de codificação aritmética usando o toolbox MATLAB
% São duas funções arithenco e arithdeco.
%
% Para usa-las é necessário preparar os dados de duas maneiras:
% 1 - todos os simbolos devem ser substituidos por indices numericos
% 2 - uma sequencia deve ser fornecida para a contagem de repeticoes de
% cada simbolo na mensagem a codificar. É similar as probabilidade da
% função huffmandic mas aqui usa-se contagens.

% Imaginem que nossa mensagem seja a frase abaixo
msg_txt = 'A CANA DA CASA BACANA DA ANA';

% Primeiro precisamos montar o alfabeto usado e suas contagens assim:
alfabeto = ['A' 'B' 'C' 'D' 'E'];
cont     = [11 1 3 2 3 6 6];

for i=1:length(msg_txt);
   seq(i) = find(alfabeto==msg_txt(i))
end;

code = arithenco(seq, cont);

% Mostra a mensagem codificada
binario = ['0' '1']; % para exibir

disp(sprintf('Essa é a mensagem codificada:%s', binario(code+1)));
disp(sprintf('A mensagem codificada tem %d bits', length(code)));
disp(sprintf('O tamanho minimo possivel seriam H x L = %0.2f bits', H*L));

% Aqui decodifica a mensagem
deco = arithdeco(code, cont, L);

% Como a mensagem são os indices para exibir uso eles no alfabeto
disp(sprintf('Decodifica: %s', alfabeto(deco)));