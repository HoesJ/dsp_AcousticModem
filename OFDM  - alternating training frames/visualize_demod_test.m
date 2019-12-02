N = 1024;
Ld = 2;
refreshRate = 0.02;
qam_order_default = 16;

rxBitStream = qam_demod(rxQamStream,qam_order_default);

[bitstream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

visualize_demod(rxBitStream, H, refreshRate, Ld, N, qam_order_default);

%%
% sizeH = size(H);
% for i = 1:sizeH(2)
% % zerostream + rxBitStream(1:i*Ld*(N/2-1)

%%
rxBitStream = qam_demod(rxQamStream,qam_order_default);
rxim = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);
image(rxim);