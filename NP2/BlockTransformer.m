classdef BlockTransformer
    %BLOCKTRANSFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        blockSize (1,2)
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
        end
        
        function transformedBlock = transform(obj,block)
            if obj.method == 'd'
                transformedBlock = dct2(block);
            else
                transformedBlock = fwht(fwht(block)');
            end
        end

        function block = inverseTransform(obj,transformedBlock)
            if obj.method == 'd'
                block = idct2(transformedBlock);
            else
                block = ifwht(ifwht(transformedBlock)');
                block = block(1:obj.blockSize(1),1:obj.blockSize(2));
            end
        end
    end
end

