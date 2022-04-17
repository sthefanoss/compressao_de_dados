% Separado em funções e com main Script

%Email: samira_ebrahimi@hotmail.com ,please contact me if you could improve
%this code, Thanks.
%function [timeC,timeDC,sourcestr,decoded]=mainLZ77(sourcestr)
%function [timeC,timeDC,sourcestr,decoded]=mainLZ77(sourcestr)
clear all; close all;
% sourcestr = 'vozes veladas veludosas vozes volupias dos violoes vozes veladas vagam nos velhos vortices velozes dos ventos vivas vas vulcanizadas';
% sourcestr = 'sir_sid_eastman_easily_teases_sea_sick_seals';

im_rgb = imread('imagem2.jpg');
im_gray = rgb2gray(im_rgb);
% im_YCbCr = rgb2ycbcr(im_rgb);

% calcula as dimensoes da matriz
altura  = length(im_gray(:,1));
largura = length(im_gray(1,:));
L = altura*largura; 

% Se eu quiser posso lineariza a matriz de imagem(transforma em vetor)
sourcestr = reshape(im_gray, 1,L);

searchWindowLen= 100;
lookAheadWindowLen= 100;
tic
      fprintf('LZ77-Compression is started.');
      
   sourcestr=[char(sourcestr) '$'];
      [coded,symbols,uniqueSymbols]=encodeLZ77(sourcestr,searchWindowLen,lookAheadWindowLen);
      
      fprintf('\n LZ77-Compression is finished.');
timeC=toc;
tic
    fprintf('\n LZ77-Decompression is started.');
    
    decoded=decodeLZ77(coded,searchWindowLen,lookAheadWindowLen);
    
    fprintf('\n LZ77-Decompression is finished.');
timeDC=toc;
ok=isequal(sourcestr,decoded)
%end
