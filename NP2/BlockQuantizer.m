classdef BlockQuantizer
    %BLOCKTRANSFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        blockSize (1,2)
        matrix
        matrixInv
    end
    
    methods (Static)
        function obj = fromGenerator(blockSize, valueGenerator)
            matrix = zeros(blockSize);
            matrixInv = zeros(blockSize);
            for i=1:blockSize(1)
                for j=1:blockSize(2)
                    value = ceil(valueGenerator((i-1)/(blockSize(1)-1),(j-1)/(blockSize(2)-1)));
                    matrix(i,j) = value;
                end
            end
            obj = BlockQuantizer(blockSize,matrix);
        end
    end

    methods
        function obj = BlockQuantizer(blockSize, matrix)
            obj.blockSize = blockSize;
            obj.matrix = matrix;
            obj.matrixInv = 1./matrix;
        end
        
        function quantizedBlock = quantize(obj,block)
            quantizedBlock = floor(block.*obj.matrixInv);
        end

        function block = dequantize(obj,quantizedBlock)
            block = quantizedBlock.*obj.matrix;
        end
    end
end
