close all; clear; clc;

%% setup
trainImages = {};
drmanhattan = rgb2gray(imread('drmanhattan.jpeg'));   
quantizerGenerators = {@(i,j) 1, @(i,j) 1 + 12.5*i + 11.5*j, @(i,j) 1 + 25*i + 24*j, @(i,j) 1 + 50*i + 49*j, @(i,j) 1 + 100*i + 99*j};

for i=7:7
    index = length(trainImages)+1;    
     trainImages{index} = imread(sprintf('./corpusNP1/Binarizado%d.jpg',i));
     trainImages{index} = drmanhattan(20:150,300:430);

%      trainImages{index} = trainImages{index}(1:100,1:100);
     figure
     subplot(2,length(quantizerGenerators)+1,1)
     imshow(trainImages{index})
end


for i=1:length(quantizerGenerators)
    i
    tic
    imageCompressor = LossyImageCompressor(5, trainImages,'lessFrequent', 'dct',quantizerGenerators{i});
    compressedImage = imageCompressor.compressImage(trainImages{1});
    image = imageCompressor.decompressImage(compressedImage);
    subplot(2,length(quantizerGenerators)+1,i+1)
    imshow(image)
    subplot(2,length(quantizerGenerators)+1,length(quantizerGenerators)+2+i)
    imshow(abs(double(image)-double(trainImages{index})))
    toc
end

return


% imageCompressor.showTask1Table();
% imageCompressor.showTask2Table();
% imageCompressor.showTask3Table();





image = imageCompressor.decompressImage(compressedImage);
% Compression and decompression exemple





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


