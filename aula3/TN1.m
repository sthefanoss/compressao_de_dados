close all; clear; clc;

trainImagePaths = {};
for i=7:12
    index = length(trainImagePaths)+1;
    trainImagePaths{index} = sprintf('./corpusNP1/Binarizado%d.jpg',i);
end

imageCompressor = ImageCompressor([6 6], trainImagePaths,'expectedValue');

[compressedImage,imageSize, compressionRatio] = imageCompressor.compressImageByPath(trainImagePaths{1});
image = imageCompressor.decompressImage(compressedImage, imageSize);
imshow(image);
