classdef BlockQuantizer
    %BLOCKTRANSFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        blockSize (1,2)
        matrix
        matrixInv
    end
    
    methods
        function obj = BlockQuantizer(blockSize, valueGenerator)
            arguments
                blockSize
                valueGenerator = @(i,j) 1 + 25*i + 25*j;
            end
            obj.blockSize = blockSize;
            obj.matrix = zeros(blockSize);
            obj.matrixInv = zeros(blockSize);
            for i=1:blockSize(1)
                for j=1:blockSize(2)
                    value = valueGenerator((i-1)/(blockSize(1)-1),(j-1)/blockSize(2)-1);
                    obj.matrix(i,j) = value;
                    obj.matrixInv(i,j) = 1/value;
                end
            end
        end
        
        function quantizedBlock = quantize(obj,block)
            quantizedBlock = floor(block.*obj.matrixInv);
        end

        function block = dequantize(obj,quantizedBlock)
            block = quantizedBlock.*obj.matrix;
        end
    end
end
