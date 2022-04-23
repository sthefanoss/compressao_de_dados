close all; clear; clc;

%% setup
trainImages = {};
 drmanhattan = rgb2gray(imread('drmanhattan.jpeg'));   

for i=7:7
    index = length(trainImages)+1;    
     trainImages{index} = imread(sprintf('./corpusNP1/Binarizado%d.jpg',i));
%     trainImages{index} = drmanhattan;
     trainImages{index} = trainImages{index}(1:100,1:100);
     figure
     subplot(2,3,1)
     imshow(trainImages{index})
end
quantizerValueGenerator = @(i,j) 1;% + 20.5*i + 20.5*j;
imageCompressor = LossyImageCompressor(5, trainImages,'lessFrequent', 'wht',quantizerValueGenerator);


% imageCompressor.showTask1Table();
  %imageCompressor.showTask2Table();

[compressedImage,len,ratio] = imageCompressor.compressImage(trainImages{1});
image = imageCompressor.decompressImage(compressedImage);
% Compression and decompression exemple
image = imageCompressor.decompressImage(compressedImage);
subplot(2,3,2)
imshow(image)
subplot(2,3,5)
imshow(abs(double(image)-double(trainImages{index})))

imageCompressor = LossyImageCompressor(5, trainImages,'lessFrequent', 'dct',quantizerValueGenerator);
% imageCompressor.showTask2Table();
% return;
[compressedImage,len,ratio] = imageCompressor.compressImage(trainImages{1});

%% Compression and decompression exemple
image = imageCompressor.decompressImage(compressedImage);
 subplot(2,3,3)
imshow(image)
 subplot(2,3,6)
imshow((abs(double(image)-double(trainImages{index}))))
% imageCompressor.showTask1Table();
%  
 return
% return
imageCompressor.writeImageTysCys(trainImages{1},'fooboobar');
image = imageCompressor.readImageFromTysCys('fooboobar');
% return;
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


