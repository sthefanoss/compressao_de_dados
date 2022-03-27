clear; close all;
T = 1000;
m = 6;
n = 3;
li = ceil(log2(m));
l = floor(log2(m)) + 1/n;

T1=ceil(l*T);
T2 = li*T;
p = (T2-T1)/T2;