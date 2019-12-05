fs =16000;
M_default = 16;
N_default = 1024;
L_default = 320;
gamma = 10;

%%
h1 = ifft(H(:,20));
h2 = ifft(H(:,30));
H1 = H(:,10);
H2 = H(:,20);

% figure
% subplot(2,1,1); plot(abs(h1));
% subplot(2,1,2); plot(abs(h2));

[a,b,H1and2] = fixed_transmitter_side_beamformer(h1,h2);

%%
figure
subplot(3,2,1); plot(abs(fft(h1)));ylim([0 0.1])
subplot(3,2,3); plot(abs(fft(h2)));ylim([0 0.1])
subplot(3,2,5); plot(H12);ylim([0 0.1])
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

rxOfdmStream = fftfilt(h1,ofdmStream1)+fftfilt(h2,ofdmStream1);

% transmit
[simin,nbsecs,fs,pulse]=initparams_stereo(ofdmStream,fs, L);
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse);

% OFDM demodulation
mu = 0.3;
alphaOverride = 0;
if (alphaOverride == 0)
    alpha = 10^(floor(log10(rxOfdmStream(length(rxOfdmStream)/3)) * 2 - 1));
else
    alpha = alphaOverride;
end
h1and2 = ifft(H1and2);
[rxQamStream,H] = ofdm_demod(rxOfdmStream,N,L,trainblock,Lt,mu,alpha,M);

%%
% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
pics = figure;
subplot(2,2,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,2,2); colormap(colorMap); image(imageRx); axis image; title(strcat('Simple transmission -- ',num2str(berTransmission))); drawnow;

% refreshRate = (N/2-1) * Ld / fs; % (samples / channel estimate) / (samples / s) = s / channel 
refreshRate = 1;
visualize_demod(rxBitStream, H, refreshRate, Ld, N, M);
