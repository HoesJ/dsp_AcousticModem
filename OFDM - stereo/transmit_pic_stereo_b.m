fs =16000;
M_default = 16;
N_default = 1024;
L_default = 320;
gamma = 10;
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
qamStream = qam_mod(zeros(length(bitStream),1), M);

% OFDM modulation
[ofdmStream1,ofdmStream2] = ofdm_mod_stereo(0,0, N, L, qam_trainblock, Lt,a,b);

%generating two training blocks that get played after eachother.

ofdmStreamRight = [zeros(length(ofdmStream1),1); ofdmStream2];
ofdmStreamLeft = [ofdmStream1; zeros(length(ofdmStream2),1)];

%% transmit
[simin,nbsecs,fs,pulse]=initparams_stereo(ofdmStreamLeft,ofdmStreamRight, fs, L);
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse);

%% splitting received signal in right and left
rxOfdmStreamLeft = rxOfdmStream(1:length(ofdmStream1),:);
rxOfdmStreamRight = rxOfdmStream(length(ofdmStream1): length(ofdmStream1)*2,:);
figure
subplot(3,1,1);plot(rxOfdmStream);
subplot(3,1,2);plot(rxOfdmStreamLeft);
subplot(3,1,3);plot(rxOfdmStreamRight);

%%
% OFDM demodulation
mu = 0.3;
alphaOverride = 0;
if (alphaOverride == 0)
    alpha = 10^(floor(log10(rxOfdmStream(length(rxOfdmStream)/3)) * 2 - 1));
else
    alpha = alphaOverride;
end

[qamsig,H] = ofdm_demod(rxOfdmStreamLeft,N,L,trainblock);