% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
qam_order = 256;
qamStream = qam_mod(bitStream, qam_order);

% OFDM modulation
N= 1024;
L = 120; %length impulse response;
ofdmStream = ofdm_mod(qamStream, N, L);

% Channel
SNR = 35;
rxOfdmStream = fftfilt(h,ofdmStream);
rxOfdmStreamWithNoise = awgn(rxOfdmStream, SNR, 'measured');

% OFDM demodulation
rxQamStream = ofdm_demod(rxOfdmStreamWithNoise, N, L, h);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, qam_order);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;


%% BER per bin
res = zeros(N,1);
ratio = zeros(N,1);
for k = 1:length(qamStream)/N
    for i = 1:N
       rx = rxBitStream((i-1)*8+1+(k-1)*N*8:i*8+(k-1)*N*8);
       tx = bitStream((i-1)*8+1+(k-1)*N*8:i*8+(k-1)*N*8);
       [t,p] = ber(rx,tx);
       res(i) = res(i) + t;
       ratio(i) = ratio(i) + p;
    end
end
figure
plot(res);

%% Use On-Off bit loading now
lastBin = 460;

% OFDM modulation
N= 1024;
L = 120; %length impulse response;
ofdmStream = ofdm_mod(qamStream, N, L, lastBin);

% Channel
SNR = 35;
rxOfdmStream = fftfilt(h,ofdmStream);
rxOfdmStreamWithNoise = awgn(rxOfdmStream, SNR, 'measured');

% OFDM demodulation
rxQamStream = ofdm_demod(rxOfdmStreamWithNoise, N, L, h, lastBin);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, qam_order);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;


