function str=addZeros(str,num)

for i=1:(num-length(str))
    str=strcatNew('0',str);
end
end