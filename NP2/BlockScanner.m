classdef BlockScanner    
    properties
        blockSize (1,2) 
    end
    
    methods
        function obj = BlockScanner(blockSize)
            obj.blockSize = blockSize;
        end
        
        function stream = scan(obj,block)
            stream = zeros(1, obj.blockSize(1)*obj.blockSize(2)); 
            k=1;
            for i=1:obj.blockSize(1)
                if mod(i,2)==1
                    for j=1:obj.blockSize(2)
                        stream(k) = block(i,j);
                        k=k+1;
                    end
                else
                    for j=obj.blockSize(2):-1:1
                        stream(k) = block(i,j);
                        k=k+1;
                    end
                end
            end
        end

        function block = build(obj,stream)
            block = zeros(obj.blockSize(1),obj.blockSize(2));
            k=1;
            for i=1:obj.blockSize(1)
                if mod(i,2)==1
                    for j=1:obj.blockSize(2)
                        block(i,j) = stream(k);
                        k=k+1;
                    end
                else
                    for j=obj.blockSize(2):-1:1
                        block(i,j) = stream(k);
                        k=k+1;
                    end
                end
            end
        end
    end
end

