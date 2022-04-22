close all; clear; clc;

%% setup
trainImages = {};
 drmanhattan = rgb2gray(imread('drmanhattan.jpeg'));   

for i=7:12
    index = length(trainImages)+1;    
     trainImages{index} = imread(sprintf('./corpusNP1/Binarizado%d.jpg',i));
%     trainImages{index} = drmanhattan;
     trainImages{index} = trainImages{index};%(1:100,1:100);
%      imshow(trainImages{index})
end
quantizerValueGenerator = @(i,j) 1 + 10*i + 10*j;
imageCompressor = LossyImageCompressor([5 5], trainImages,'lessFrequent', 'dct',quantizerValueGenerator);
 imageCompressor.showTask1Table();
return;
% % return
% imageCompressor.writeImageTysCys(trainImages{1},'catata');
% im =  imageCompressor.readImageFromTysCys('catata');
% figure
% imshow(im);
% 
% err = quadraticMeanError(im,trainImages{1});
% return;
[compressedImage,len,ratio] = imageCompressor.compressImage(trainImages{1});

%% Compression and decompression exemple
image = imageCompressor.decompressImage(compressedImage);
err = quadraticMeanError(image,trainImages{1});
figure
imshow(image)

%% Uncomment to see compressor analisys
% imageCompressor.showBlocksAnalysis();
% imageCompressor.showRleTuplesAnalysis();
% imageCompressor.showHuffmanAnalysis()
% imageCompressor.runImagesBenchmark()


