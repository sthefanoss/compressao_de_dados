classdef WhiteBlockSeparator
    methods
        function obj = WhiteBlockSeparator()
        end

        function [Tys,Cys] = split(obj, blocks)
            arguments
                obj,
                blocks 
            end
            Tys = []; % {starting index,repetitions} (RLE)
            Cys = []; % {block value} (NOT RLE)
            tIndex = 0;
            cIndex = 0;
            if all(all(blocks(:,:,1) == 255))
                tIndex = 1;
                Tys(1,:) = [1,1];
            else
                cIndex = 1;
                Cys(1,:) = blocks(:,:,1);
            end

            for i=2:length(blocks)
                current = blocks(:,:,i);
                previuos = blocks(:,:,i-1);
                isWhiteBlock = all(all(current == 255));

                if isWhiteBlock && all(all(current == previuos)) 
                    Tys(tIndex,2) = Tys(tIndex,2) + 1;
                elseif isWhiteBlock % !areEqual 
                    tIndex = tIndex + 1;
                    Tys(tIndex,:) = [i,1];
                else %!isWhiteBlock
                    cIndex = cIndex + 1;
                    Cys(:,:,cIndex) = current;
                end
            end
        end

        function blocks = join(obj, Tys, Cys)
            blockSize = size(Cys(:,:,1));
            whiteBlock = 255*ones(blockSize(1),blockSize(2));
            blocks = [];
            tIndex = 1;
            cIndex = 1;
            k=1;
            tuplesLength = size(Tys,1) + size(Cys,3);
            for i=1:tuplesLength
                if tIndex <= size(Tys,1) && k == Tys(tIndex,1)
                    for j=1:Tys(tIndex,2)
                        blocks(:,:,k) = whiteBlock;
                        k = k + 1;
                    end
                    tIndex = tIndex + 1;
                else
                    blocks(:,:,k) = Cys(:,:,cIndex);
                    k = k + 1;
                    cIndex = cIndex + 1;
                end
            end
        end
    end
end