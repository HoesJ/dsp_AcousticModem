fs =16000;
qam_order_default = 16;
N_default = 1024;
L_default = 320;

%% Simple transmssion
M = qam_order_default;
N = N_default;
L = L_default;

Lt = 3;
Ld = 5;

% Convert; BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%training block generation
trainblock = randi([0,1],(N/2-1)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);

% QAM modulation
qam_order = qam_order_default;
qamStream = qam_mod(bitStream, qam_order);

% OFDM modulation
ofdmStream = ofdm_mod(qamStream, N, L, qam_trainblock, Lt, Ld);

% Channel
[simin,nbsecs,fs,pulse]=initparams(ofdmStream,fs, L);
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse);
%%
% OFDM demodulation
[rxQamStream, H] = ofdm_demod(rxOfdmStream, N, L, qam_trainblock, Lt, Ld);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, qam_order);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
pics = figure;
subplot(2,2,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,2,2); colormap(colorMap); image(imageRx); axis image; title(strcat('Simple transmission -- ',num2str(berTransmission))); drawnow;


