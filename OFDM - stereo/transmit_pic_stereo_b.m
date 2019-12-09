fs =16000;
M_default = 16;
N_default = 1024;
L_default = 320;
gamma = 10;
%% Stereo transmssion
M = M_default;
N = N_default;
L = L_default;
Lt = 15;

% Convert; BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%training block gen  ration
trainblock = randi([0,1],(N/2-1)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);

% QAM modulation
qamStream = qam_mod(zeros(length(bitStream),1), M);

% OFDM modulation
[ofdmStream1,ofdmStream2] = ofdm_mod_stereo(0,0, N, L, qam_trainblock, Lt,1,1);

%generating two training blocks that get played after eachother.

ofdmStreamRight = [zeros(length(ofdmStream1),1); ofdmStream2];
ofdmStreamLeft = [ofdmStream1; zeros(length(ofdmStream2),1)];

%% transmit training blocks to determine a and b
[simin,nbsecs,fs,pulse]=initparams_stereo(ofdmStreamLeft,ofdmStreamRight, fs, L);
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse);

% splitting received signal in right and left
rxOfdmStreamLeft = rxOfdmStream(1:length(ofdmStream1),:);
rxOfdmStreamRight = rxOfdmStream(length(ofdmStream1): length(ofdmStream1)*2,:);

figure
subplot(3,1,1);plot(rxOfdmStream);
subplot(3,1,2);plot(rxOfdmStreamLeft);
subplot(3,1,3);plot(rxOfdmStreamRight);

%channel estimation

[~,HLeft] = ofdm_demod(rxOfdmStreamLeft,N,L,qam_trainblock);
[~,HRight] = ofdm_demod(rxOfdmStreamRight,N,L,qam_trainblock);


%%
[a,b, H1and2] = fixed_transmitter_side_beamformer(HLeft,HRight);

% plotting channel estimation
figure
subplot(3,1,1);plot(abs(HLeft));
subplot(3,1,2);plot(abs(HRight));
subplot(3,1,3);plot(abs(H1and2));

%% Stereo transmssion
M = M_default;
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
qamStream = qam_mod(bitStream, M);

% OFDM modulation
[ofdmStreamLeft,ofdmStreamRight] = ofdm_mod_stereo(qamStream,qamStream, N, L, qam_trainblock, Lt,a,b);
% [ofdmStreamLeft,ofdmStreamRight] = ofdm_mod_stereo_alternating(qamStream,qamStream, N, L, qam_trainblock, Lt, Ld,a,b);

[simin,nbsecs,fs,pulse]=initparams_stereo(ofdmStreamLeft,ofdmStreamRight, fs, L);
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse,40);

%% OFDM demodulation
mu = 0.1;
alphaOverride = 1e-8;
if (alphaOverride == 0)
    alpha = 10^(floor(log10(rxOfdmStream(length(rxOfdmStream)/3)) * 2 - 1));
else
    alpha = alphaOverride;
end

[rxQamStream, H] = ofdm_demod_stereo(rxOfdmStream,N,L,qam_trainblock,Lt,mu,alpha,M);
% [rxQamStream,H] = ofdm_demod_stereo_alternating(rxOfdmStream,N,L,qam_trainblock,Lt,Ld);

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

%%
refreshRate = (N/2-1)*Ld / fs; % (samples / channel estimate) / (samples / s) = s / channel estimate
pixPerPacket = (N/2-1)*log2(M)*Ld;
visualize_demod(rxBitStream, H, refreshRate, 1, N, M, pixPerPacket);