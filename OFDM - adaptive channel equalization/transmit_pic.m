fs =16000;
M_default = 16;
N_default = 1024;
L_default = 320;
gamma = 10;
BWusage = 0.7;
%% Simple transmssion
M = M_default;
N = N_default;
L = L_default;
Lt = 3;
%% Probe channel
if (BWusage == 1)
    usedbins = 1:N/2-1;
else
    trainblock = randi([0,1],(N/2-1)*log2(M),1);
    qam_trainblock = qam_mod(trainblock,M);
    num = floor(fs/N/1.5);
    ofdmStream = ofdm_mod(qam_trainblock, N, L, qam_trainblock, num);
    [simin,nbsecs,fs,pulse]=initparams(ofdmStream,fs, L,0.1);
    simin = 0.25 * simin;
    sim('recplay');
    out = simout.signals.values;
    [rxOfdmStream,~] = alignIO(out,pulse);
    [rxQamStream, H] = ofdm_demod(rxOfdmStream, N, L, qam_trainblock, num, 0.2,1e-8,M);

    [~,usedbins] = sort(abs(H), 'descend');
    usedbins = usedbins(1:floor(BWusage*(N/2-1)));
end
%%
% Convert; BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%training block generation
trainblock = randi([0,1],(N/2-1)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);

% QAM modulation
qamStream= qam_mod(bitStream, M);

% OFDM modulation
ofdmStream = ofdm_mod(qamStream, N, L, qam_trainblock, Lt, usedbins);

% transmit
[simin,nbsecs,fs,pulse]=initparams(ofdmStream,fs, L);
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse);
% rxOfdmStream = fftfilt(h,ofdmStream);
% rxOfdmStreamWithNoise = awgn(rxOfdmStream, 30, 'measured');
%%
% OFDM demodulation
mu = 0.15;
alphaOverride = 1e-8;
if (alphaOverride == 0)
    alpha = 10^(floor(log10(rxOfdmStream(floor(length(rxOfdmStream)/3))) * 2 - 1));
else
    alpha = alphaOverride;
end
[rxQamStream, H] = ofdm_demod(rxOfdmStream, N, L, qam_trainblock, Lt, mu,alpha,M, usedbins);
figure;
subplot(2,1,1); plot(abs(H(256,:)));
subplot(2,1,2); plot(abs(H(300,:)));

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

refreshRate = (N/2-1) / fs; % (samples / channel estimate) / (samples / s) = s / channel estimate
pixPerPacket = (N/2-1)*log2(M);
visualize_demod(rxBitStream, H, refreshRate, 1, N, M, pixPerPacket);
