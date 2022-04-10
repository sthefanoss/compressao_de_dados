close all; clear; clc;

trainImagePaths = {};
for i=7:12
    index = length(trainImagePaths)+1;
    trainImagePaths{index} = sprintf('./corpusNP1/Binarizado%d.jpg',i);
end

imageCompressor = ImageCompressor([4 4], trainImagePaths,'lessFrequent');
imageCompressor.showAnalysis();
% imageCompressor.benchmark(trainImagePaths(1:3))
return;
[compressedImage, compressionRatio] = imageCompressor.compressImageByPath(trainImagePaths{1});
image = imageCompressor.decompressImage(compressedImage);
imshow(image);
