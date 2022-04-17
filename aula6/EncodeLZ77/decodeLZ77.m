function decompressed=decodeLZ77(binaryStr,searchWindowLen,lookAheadWindowLen)

decompressed='';
bytenumSW=length(dec2bin(searchWindowLen));
bytenumLA=length(dec2bin(lookAheadWindowLen));
i=1;

while i<length(binaryStr)
    SW=returnPartOfString(binaryStr,i,i-1+bytenumSW);
    SWdec=bin2dec(SW);
    i=i+bytenumSW;    
    if(SWdec~=0)
        LA=returnPartOfString(binaryStr,i,i-1+bytenumLA);
        LAdec=bin2dec(LA);
        i=i+bytenumLA;
    else
        LAdec=0;
    end
    
    Chr=returnPartOfString(binaryStr,i,i-1+8);
    Chrch=char(bin2dec(Chr));
    i=i+8;

    if(SWdec==0)
        decompressed=strcatNew(decompressed,Chrch);
 
    else
        location=length(decompressed)-SWdec;
        
        for j=1:LAdec
        decompressed=strcatNew(decompressed,decompressed(location+j));
                
        end
        decompressed=strcatNew(decompressed,Chrch);

    end    
end
end