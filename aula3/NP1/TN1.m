close all; clear; clc;

trainImagePaths = {};
for i=7:12
    index = length(trainImagePaths)+1;
    trainImagePaths{index} = sprintf('./corpusNP1/Binarizado%d.jpg',i);
end

imageCompressor = ImageCompressor([4 4], trainImagePaths,'lessFrequent');
imageCompressor.showBlocksAnalysis();
imageCompressor.showRleTuplesAnalysis();
imageCompressor.showHuffmanAnalysis()
imageCompressor.runImagesBenchmark()
