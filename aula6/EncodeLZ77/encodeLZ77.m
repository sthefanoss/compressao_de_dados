function [compressed,symbols,symbolsCount]=encodeLZ77(str,searchWindowLen,lookAheadWindowLen)

compressed='';
symbols = {};
symbolsCount = containers.Map('KeyType','char','ValueType','double');
i=1; %codeindex

while i<=length(str)
    startindex=i-searchWindowLen;
    if(startindex)<1
        startindex=1;
    end
    
    if(i==1)
        searchBuffer='';
    else
    searchBuffer= returnPartOfString(str,startindex,i-1);
    end   
    %searchBuffer
     
    endindex=i+lookAheadWindowLen-1; 

    if(endindex)>length(str)
        endindex=length(str);
    end
    lookAheadBuffer=returnPartOfString(str,i,endindex);
    %lookAheadBuffer
    j=1;
    tobesearched=returnPartOfString(lookAheadBuffer,1,j);
    searchresult=strfind(searchBuffer,tobesearched);

    if(numel(lookAheadBuffer) > j)

        while (size(searchresult)~=0)
            j=j+1;
            if(j<=numel(lookAheadBuffer))
            %if(numel(lookAheadBuffer)<j)
            %lookAheadBuffer=strcat(lookAheadBuffer,'$');
            %end            
            tobesearched=returnPartOfString(lookAheadBuffer,1,j);
            searchresult=strfind(searchBuffer,tobesearched);
            else
                break;
            end
        end
    end

    if (j>1)
    tobesearched=returnPartOfString(lookAheadBuffer,1,j-1);
    searchresult=strfind(searchBuffer,tobesearched);
    end

    dim=size(searchresult);

    if(dim>0)
        occur=length(searchBuffer)-searchresult(dim(2))+1;
    else
        occur=0;
    end
    
        
    bytenum=length(dec2bin(searchWindowLen));

    if(occur~=0)
        compressed=strcatNew(compressed,addZeros(dec2bin(occur),bytenum));
        compressed=strcatNew(compressed,addZeros(dec2bin(j-1),bytenum));
        if(j>searchWindowLen)
            compressed=strcatNew(compressed,addZeros(dec2bin(str(i+j)-0),8));
            str(i+j)
        else
            compressed=strcatNew(compressed,addZeros(dec2bin(lookAheadBuffer(j)-0),8));
        end
        
    else
        %ignoring 2nd zero in compressed string
        compressed=strcatNew(compressed,addZeros(dec2bin(occur),bytenum));
        %compressed=strcat(compressed,addZeros(dec2bin(j-1),bytenum));
        if(j>searchWindowLen)
            compressed=strcatNew(compressed,addZeros(dec2bin(str(i+j)-0),8));
         else
            compressed=strcatNew(compressed,addZeros(dec2bin(lookAheadBuffer(j)-0),8));
         end
        
    end

    symbol = sprintf('(%d,%d,%c)',occur,j-1,lookAheadBuffer(j));
    if(isKey(symbolsCount,symbol))
        symbolsCount(symbol) = symbolsCount(symbol) + 1;
    else
        symbolsCount(symbol) = 1;
    end
    symbols{length(symbols)+1} = symbol;
%     fprintf('\n search result');
%     searchresult
%     fprintf('\n searchbuffer');
%     searchBuffer
%     fprintf('\n looAheadBuffer');
%     lookAheadBuffer
    i=i+j;
end
end
%---------------