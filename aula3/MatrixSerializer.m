classdef MatrixSerializer
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        blockSize (1,2) 
        binaryToUint64Map;
    end

    methods (Access = private)
         function paddedMatrix = padMatrixForMultiple(obj, matrix)
            sizeReminder = mod(size(matrix), obj.blockSize);
            padding = [0 0];
            if(sizeReminder(1) ~= 0)
                padding(1) = obj.blockSize(1) - sizeReminder(1);
            end
            if (sizeReminder(2) ~=0)
                padding(2) = obj.blockSize(2) - sizeReminder(2);
            end
            paddedMatrix = padarray(matrix, padding, 'post');
        end

        % Divide uma matriz MxN em um tensor AxBxN. As dimensoues MxN devem
        % multiplas de AxB respectivamente. Use a funcao [padMatrixForMultiple]
        % para grantir isso. N = MxN/(AxB). Ou seja, o produto das dimensoes se mantem.
        % a terceira dimensao eh utilizada para separar os blocos. Esse valor eh
        % calculado varrendo a matriz principal em submatrizes AxB, da direita para
        % esqueda, de cima para baixo.
        function blocks = splitMatrixIntoBlocks(obj, matrix)
            matrixSize = size(matrix);
            matrixSections = matrixSize./obj.blockSize;
            blocks = false(obj.blockSize(1),obj.blockSize(2),matrixSections(1)*matrixSections(2));
            for i=1:matrixSize(1)
                for j=1:matrixSize(2)
                    blockI = mod(i-1, obj.blockSize(1)) + 1;
                    blockJ = mod(j-1, obj.blockSize(2)) + 1;
                    sectionI = floor((i-1)/obj.blockSize(1)) + 1;
                    sectionJ = floor((j-1)/obj.blockSize(2)) + 1;
                    blockIndex = sectionI + (sectionJ-1) * matrixSections(1);
                    blocks(blockI, blockJ, blockIndex) = matrix(i,j);
                end
            end
        end

        % transforma um tensor AxBxN de volta em uma matrix MxN
        % cada bloco T(:,:,i) deve ter o mesmo tamanho.
        function matrix = joinMatrixBlocks(obj, blocks, matrixSize)
            matrixSections = matrixSize./obj.blockSize;
            matrix = false(matrixSize);
            for i=1:matrixSize(1)
                for j=1:matrixSize(2)
                    blockI = mod(i-1, obj.blockSize(1)) + 1;
                    blockJ = mod(j-1, obj.blockSize(2)) + 1;
                    sectionI = floor((i-1)/obj.blockSize(1)) + 1;
                    sectionJ = floor((j-1)/obj.blockSize(2)) + 1;
                    blockIndex = sectionI + (sectionJ-1) * matrixSections(1);
                    matrix(i,j) = blocks(blockI, blockJ, blockIndex);
                end
            end
        end

        % varre um bloco AxB de cima para baixo,
        % da esquerda para direita se j%2 = 1
        % da direita para esquerda se j%2 = 0
        % os valores sao acumulados em um vetor binario, que depois vira um uint.
        function symbol = encodeBlock(obj, block)
            stream = false(1, obj.blockSize(1)*obj.blockSize(2));
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
            key = char(stream + '0');
            if(obj.binaryToUint64Map.isKey(key))
                symbol = obj.binaryToUint64Map(key);
            else
                symbol = bin2dec(key);
                obj.binaryToUint64Map(key) = symbol;
            end
        end

        function block = decodeBlock(obj, symbol)
            block = false(obj.blockSize);
            bin = dec2bin(symbol, obj.blockSize(1)*obj.blockSize(2));
            k=1;
            for i=1:obj.blockSize(1)
                if mod(i,2)==1
                    for j=1:obj.blockSize(2)
                        block(i,j) = bin(k) == '1';
                        k=k+1;
                    end
                else
                    for j=obj.blockSize(2):-1:1
                        block(i,j) = bin(k) == '1';
                        k=k+1;
                    end
                end
            end
        end
    end

    methods
        function obj = MatrixSerializer(blockSize)
            arguments
                blockSize (1,2) 
            end
            obj.blockSize = blockSize;
            obj.binaryToUint64Map = containers.Map('KeyType','char','ValueType','uint64');
        end
        
        function [serializedMatrix,paddedMatrixSize] = serialize(obj, matrix)
            subBlocksSize = ceil(size(matrix)./(obj.blockSize));
            serializedMatrixLength = subBlocksSize(1)*subBlocksSize(2);
            serializedMatrix = uint64(zeros(1,serializedMatrixLength));
            paddedMatrix = obj.padMatrixForMultiple(matrix);
            paddedMatrixSize = size(paddedMatrix);

            blocks = obj.splitMatrixIntoBlocks(paddedMatrix);
            for i=1:serializedMatrixLength
                serializedMatrix(i) = obj.encodeBlock(blocks(:,:,i));
            end
        end

        function matrix = deserialize(obj, serializedMatrix, matrixSize)
            serializedMatrixSize = size(serializedMatrix);
            blocks = false(obj.blockSize(1),obj.blockSize(2),serializedMatrixSize(2));
            for i=1:serializedMatrixSize(2)
                blocks(:,:,i) = obj.decodeBlock(serializedMatrix(i));
            end
            paddedMatrixSize = ceil(matrixSize./obj.blockSize).*obj.blockSize;
            matrix = obj.joinMatrixBlocks(blocks, paddedMatrixSize);
            matrix = matrix(1:matrixSize(1),1:matrixSize(2));
        end
    end
end