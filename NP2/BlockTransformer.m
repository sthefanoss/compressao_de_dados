classdef BlockTransformer
    %BLOCKTRANSFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        blockSize (1,2)
        matrix
        matrixInv
        padSize
        method
    end
    
    methods
        function obj = BlockTransformer(blockSize, method)
            arguments
                blockSize
                method char {mustBeMember(method,{'dct','wht'})} = 'dct'
            end
            obj.blockSize = blockSize;
            obj.method = method(1);
            if method == 'dct'
                obj.matrix = dctmtx(blockSize(1));
                obj.padSize = [0 0];
            else
                nextPowerOf2 = 2^ceil(log2(blockSize(1))); 
                obj.matrix = hadamard(nextPowerOf2);
                pad = nextPowerOf2 - blockSize(1);
                obj.padSize = [pad pad];
            end
   
            obj.matrixInv = inv(obj.matrix);
        end
        
        function transformedBlock = transform(obj,block)
            if obj.padSize(1) == 0
                transformedBlock = obj.matrix*block*obj.matrix';
                return;
            end

            block = padarray(block,obj.padSize, 'post');
            transformedBlock =  obj.matrix*block*obj.matrix';
        end

        function block = inverseTransform(obj,transformedBlock)
            if obj.padSize(1) == 0 
                block = obj.matrixInv*transformedBlock*obj.matrixInv';
                return;
            end

            block = obj.matrixInv*transformedBlock*obj.matrixInv';
            block = block(1:obj.blockSize(1),1:obj.blockSize(2));
        end
    end
end

