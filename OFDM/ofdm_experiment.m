% Generate QAM
M = 64;
k = log2(M);
ranseq = randi([0,1],992*k,1); % 992 so qam length is multiple of N/2 - 1
qam = qam_mod(ranseq, M);

% Generate OFDM
N = 64;
P =length(qam)/(N/2-1);
[ofdmSeq] = ofdm_mod(qam,N,P);

% make returned QAM
[returnedqam] = ofdm_demod(ofdmSeq,N,P);

% demodulate
receivedSig = qam_demod(returnedqam,M);
[numberErr,ratio] = ber(ranseq,receivedSig);

%% Performance for diffent M and SNR
Ms = 2.^(1:1:10);
SNRs = 5:1:40;

result = zeros(length(Ms),length(SNRs));

for i = 1:length(Ms)
    for j = 1:length(SNRs)
        % Generate QAM
        M = Ms(i);
        k = log2(M);
        ranseq = randi([0,1],992*k,1); % 992 so qam length is multiple of N/2 - 1
        qam = qam_mod(ranseq, M);

        % Generate OFDM
        N = 64;
        P =length(qam)/(N/2-1);
        [ofdmSeq] = ofdm_mod(qam,N,P);
        
        % Add noise
        ofdmSeq = awgn(ofdmSeq, SNRs(i));

        % make returned QAM
        [returnedqam] = ofdm_demod(ofdmSeq,N,P);

        % demodulate
        receivedSig = qam_demod(returnedqam,M);
        [numberErr,result(i,j)] = ber(ranseq,receivedSig);
    end
end

surf(Ms, SNRs, result');
xlabel('Ms')
ylabel('SNRs')
zlabel('result')



