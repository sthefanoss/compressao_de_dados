function hex = binToHex(bin)
    bin = reshape(bin',1,[]);
    mod4 = mod(length(bin), 4);    
    if(mod4 ~= 0)
        bin = padarray(bin,[0 4-mod4], 0,'pre');
    end
    
  tupla = join(string(reshape(bin,4, [])'))
        tupla = strrep(tupla,' ','');
            tupla = strrep(tupla,'0000','0');
            tupla = strrep(tupla,'0001','1');
            tupla = strrep(tupla,'0010','2');
            tupla = strrep(tupla,'0011','3');
            tupla = strrep(tupla,'0100','4');
            tupla = strrep(tupla,'0101','5');
            tupla = strrep(tupla,'0110','6');
            tupla = strrep(tupla,'0111','7');
            tupla = strrep(tupla,'1000','8');
            tupla = strrep(tupla,'1001','9');
            tupla = strrep(tupla,'1010','A');
            tupla = strrep(tupla,'1011','B');
            tupla = strrep(tupla,'1100','C');
            tupla = strrep(tupla,'1101','D');
            tupla = strrep(tupla,'1110','E');
            tupla = strrep(tupla,'1111','F');
        tupla = join(tupla)
      tupla = strrep(tupla,' ','');

    hex = tupla;
end