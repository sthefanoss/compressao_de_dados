close all; clear; clc;

imagePaths = {};
for i=7:12
    index = length(imagePaths)+1;
    imagePaths{index} = sprintf('./corpusNP1/Binarizado%d.jpg',i);
end

imageCompressor2x2 = TysCysCompressor([2 2]);
imageCompressor5x5 = TysCysCompressor([5 5]);

imageCompressor2x2.runImagesBenchmark(imagePaths);
imageCompressor5x5.runImagesBenchmark(imagePaths);

