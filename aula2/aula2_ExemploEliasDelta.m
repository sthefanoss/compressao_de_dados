% Implementa o código Elias Gamma
clear all; close all;
L = 16;
I = 1:L;

for i=1:L
    gamma = toEliasGamma(i);
    delta = toEliasDelta(i);
    omega = toEliasOmega(i);
    rice = toRice(i, 2);
    g(i) = length(gamma);
    d(i) = length(delta);
    o(i) = length(omega);
    r(i) = length(rice);
    disp(sprintf('n:%d -> g%s d%s w%s r%s',i, gamma, delta, omega,rice));
end

varg = var(g);
vard = var(d);
varo = var(o);
varr = var(r);
mg = mean(g);
mr = mean(r);

plot(I,g,I,d,I,o,I,r,'LineWidth',2)
legend('gamma','delta', 'omega','rice')

function [M,L] = getML(x)
    M = floor(log2(x));
    L = x - 2^M;
end

function xAsEliasGamma = toEliasGamma(x)
    if(x == 1) 
        xAsEliasGamma = '1';
    else   
        [M,L] = getML(x);
        prefixo = repmat('0', 1, M);
        sufixo = pad(dec2bin(L),M,'left', '0');
        xAsEliasGamma = strcat(prefixo, '1', sufixo);
    end
end

function xAsEliasDelta = toEliasDelta(x)
    if(x == 1)
        xAsEliasDelta = '1';
    else
        [M,L] = getML(x);
        xAsEliasDelta = strcat(toEliasGamma(M+1), pad(dec2bin(L),M,'left','0'));
    end
end

function xAsEliasOmega = toEliasOmega(x)
    xAsEliasOmega = strcat(toEliasOmegaInternal(x), '0');
end

function xAsEliasOmegaInternal = toEliasOmegaInternal(x)
    if x == 1
        xAsEliasOmegaInternal = '';
    else
        xAsEliasOmegaInternal = strcat(toEliasOmegaInternal(floor(log2(x))), dec2bin(x)); 
    end
end 

function [rice,xAsBinary] = toRice(x, k)
    j = floor(x/(2^k));
    xAsBinary = dec2bin(x);
    if length(xAsBinary) == k
        LSB = xAsBinary;
    elseif length(xAsBinary) > k
        xLength = length(xAsBinary);
        LSB = xAsBinary(xLength-k+1:xLength);
    else
        LSB = pad(xAsBinary,k,'left', '0');
    end
    rice = strcat(repmat('1', 1, j),'0', LSB);
end