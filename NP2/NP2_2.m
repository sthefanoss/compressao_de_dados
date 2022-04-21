close all; clear; clc;

%% setup
trainImages = {};
 drmanhattan = rgb2gray(imread('drmanhattan.jpeg'));   

for i=7:7
    index = length(trainImages)+1;    
     trainImages{index} = imread(sprintf('./corpusNP1/Binarizado%d.jpg',i));
%     trainImages{index} = drmanhattan;
     trainImages{index} = trainImages{index}(1:100,1:100);
      imshow(trainImages{index})
end
imageCompressor = LossyImageCompressor([5 5], trainImages,'lessFrequent', 'wht');
[compressedImage,len,ratio] = imageCompressor.compressImage(trainImages{1});

%% Compression and decompression exemple
image = imageCompressor.decompressImage(compressedImage);
figure
imshow(image)

%% Uncomment to see compressor analisys
% imageCompressor.showBlocksAnalysis();
% imageCompressor.showRleTuplesAnalysis();
% imageCompressor.showHuffmanAnalysis()
% imageCompressor.runImagesBenchmark()


