% Exercise session 4: DMT-OFDM transmission scheme

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
qam_order = 256;
qamStream = qam_mod(bitStream, qam_order);

% OFDM modulation
N= 512;
L = 120; %length impulse response;
ofdmStream = ofdm_mod(qamStream, N, L);

% Channel
SNR = 25; %addes noise snr
% rxOfdmStream = awgn(ofdmStream, SNR);
% h = fir1(100, 0.3, 'low');
% h = rand(L,1);
rxOfdmStream = fftfilt(h,ofdmStream);
rxOfdmStream = awgn(rxOfdmStream, SNR, 'measured');

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

%% BER per bin
res = zeros(N,1);
for k = 1:length(qamStream)/N
    for i = 1:N
       rx = rxBitStream((i-1)*8+1+(k-1)*N*8:i*8+(k-1)*N*8);
       tx = bitStream((i-1)*8+1+(k-1)*N*8:i*8+(k-1)*N*8);
       [t,~] = ber(rx,tx);
       res(i) = res(i) + t;
    end
end
