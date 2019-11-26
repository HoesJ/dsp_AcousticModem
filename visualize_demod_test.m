% qamsig = load('rxQamStream_2_2.mat');
H = load('H_2_2.mat');
refreshrate = 0.2;
Ld = 2;

% originalImage = load('image.bmp'); 
visualize_demod(rxQamStream ,H, refreshRate, Ld, imageSize, bitsPerPixel, 'image.bmp');

%%
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
figure
subplot(2,2,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;