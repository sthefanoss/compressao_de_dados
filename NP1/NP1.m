close all; clear; clc;

%% setup
trainImagePaths = {};
for i=7:12
    index = length(trainImagePaths)+1;
    trainImagePaths{index} = sprintf('./corpusNP1/Binarizado%d.jpg',i);
end

imageCompressor = ImageCompressor([4 4], trainImagePaths,'lessFrequent');
compressedImage = imageCompressor.compressImageByPath(trainImagePaths{1});

%% Compression and decompression exemple
image = imageCompressor.decompressImage(compressedImage);
imshow(image)

%% Uncomment to see compressor analisys
% imageCompressor.showBlocksAnalysis();
% imageCompressor.showRleTuplesAnalysis();
% imageCompressor.showHuffmanAnalysis()
% imageCompressor.runImagesBenchmark()


