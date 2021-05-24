fs =16000;
M_default = 16;
N_default = 1024;
L_default = 320;
gamma = 10;

%%
load('H_2_2.mat');
h1 = ifft([0;H(:,20);0;conj(flip(H(:,20)))]);
h2 = ifft([0;H(:,30);0;conj(flip(H(:,30)))]);
h1 = h1(1:300);
h2 = h2(1:300);
H1 = fft(h1,N);
H2 = fft(h2,N);
H1 = H1(2:512);
H2 = H2(2:512);


[a,b,H12] = fixed_transmitter_side_beamformer(H1,H2);
% h12 = ifft(H12);
% h12cut = h12(1:round(length(h12)/2),1);
% H12cut = fft(h12cut, 511);

%%
figure
subplot(3,2,1); plot(abs(fft(h1)));ylim([0 0.1])
subplot(3,2,3); plot(abs(fft(h2)));ylim([0 0.1])
subplot(3,2,5); plot(abs(H12));ylim([0 0.1])
subplot(3,2,2); plot(abs(h1));
subplot(3,2,4); plot(abs(h2));
subplot(3,2,6); plot(abs(ifft(H12)));

%% Stereo transmssion
M = M_default;
N = N_default;
L = L_default;
Lt = 3;

% Convert; BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%training block generation
trainblock = randi([0,1],(N/2-1)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);

% QAM modulation
qamStream = qam_mod(bitStream, M);

% OFDM modulation
[ofdmStream1,ofdmStream2] = ofdm_mod_stereo(qamStream,qamStream, N, L, qam_trainblock, Lt,a,b);

rxOfdmStream = (fftfilt(h1,ofdmStream1)+fftfilt(h2,ofdmStream2));
rxOfdmStream = awgn(rxOfdmStream, 25, 'measured');

% OFDM demodulation
mu = 0.5;
alphaOverride = 0;
if (alphaOverride == 0)
    alpha = 10^(floor(log10(rxOfdmStream(length(rxOfdmStream)/3)) * 2 - 1));
else
    alpha = alphaOverride;
end

[rxQamStream, H] = ofdm_demod_stereo(rxOfdmStream,N,L,qam_trainblock,Lt,mu,alpha,M);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
pics = figure;
subplot(2,2,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,2,2); colormap(colorMap); image(imageRx); axis image; title(strcat('Both Channels -- ',num2str(berTransmission))); drawnow;
%% Channel 1 with noise
M = M_default;
N = N_default;
L = L_default;
Lt = 3;

a = 1; b = 0;
% Convert; BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%training block generation
trainblock = randi([0,1],(N/2-1)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);

% QAM modulation
qamStream = qam_mod(bitStream, M);

% OFDM modulation
[ofdmStream1,ofdmStream2] = ofdm_mod_stereo(qamStream,qamStream, N, L, qam_trainblock, Lt,a,b);

rxOfdmStream = (fftfilt(h1,ofdmStream1)+fftfilt(h2,ofdmStream2));
rxOfdmStream = awgn(rxOfdmStream, 25, 'measured');

% OFDM demodulation
mu = 0.5;
alphaOverride = 0;
if (alphaOverride == 0)
    alpha = 10^(floor(log10(rxOfdmStream(length(rxOfdmStream)/3)) * 2 - 1));
else
    alpha = alphaOverride;
end

[rxQamStream, H] = ofdm_demod_stereo(rxOfdmStream,N,L,qam_trainblock,Lt,mu,alpha,M);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
figure(pics);
subplot(2,2,3); colormap(colorMap); image(imageRx); axis image; title(strcat('CH1 -- ',num2str(berTransmission))); drawnow;
%% Channel 2 with noise
M = M_default;
N = N_default;
L = L_default;
Lt = 3;

a = 0; b = 1;
% Convert; BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%training block generation
trainblock = randi([0,1],(N/2-1)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);

% QAM modulation
qamStream = qam_mod(bitStream, M);

% OFDM modulation
[ofdmStream1,ofdmStream2] = ofdm_mod_stereo(qamStream,qamStream, N, L, qam_trainblock, Lt,a,b);

rxOfdmStream = (fftfilt(h1,ofdmStream1)+fftfilt(h2,ofdmStream2));
rxOfdmStream = awgn(rxOfdmStream, 25, 'measured');

% OFDM demodulation
mu = 0.5;
alphaOverride = 0;
if (alphaOverride == 0)
    alpha = 10^(floor(log10(rxOfdmStream(length(rxOfdmStream)/3)) * 2 - 1));
else
    alpha = alphaOverride;
end

[rxQamStream, H] = ofdm_demod_stereo(rxOfdmStream,N,L,qam_trainblock,Lt,mu,alpha,M);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
figure(pics);
subplot(2,2,4); colormap(colorMap); image(imageRx); axis image; title(strcat('CH2 -- ',num2str(berTransmission))); drawnow;
