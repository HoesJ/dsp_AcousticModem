% Exercise session 4: DMT-OFDM transmission scheme

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
qam_order = 64;
qamStream = qam_mod(bitStream, qam_order);

% OFDM modulation
N= 512;
L = 100; %length impulse response;
ofdmStream = ofdm_mod(qamStream, N, L);

% Channel
% SNR = 20; %addes noise snr
% rxOfdmStream = awgn(ofdmStream, SNR);

h = rand(L,1);
rxOfdmStream = fftfilt(h,ofdmStream);

% OFDM demodulation
rxQamStream = ofdm_demod(rxOfdmStream, N, L, h);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, qam_order);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;
