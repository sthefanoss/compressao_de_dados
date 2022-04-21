classdef BlockTransformer
    %BLOCKTRANSFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        blockSize (1,2) 
    end
    
    methods
        function obj = BlockTransformer(blockSize)
            obj.blockSize = blockSize;
        end
        
        function transformedBlock = transform(obj,block)
            transformedBlock = dct2(block);
        end

        function block = inverseTransform(obj,transformedBlock)
            block = idct2(transformedBlock);
        end
    end
end

