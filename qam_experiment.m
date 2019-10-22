M = 64;
k = log2(M);
ranseq = randi([0,1],1000*k,1);

qam = qam_mod(ranseq, M);
sig = awgn(qam,25);

cd = comm.ConstellationDiagram('ShowReferenceConstellation',false);
step(cd,sig)

demodSig = qam_demod(sig,M);
[numberErr,ratio] = ber(ranseq,demodSig)

%% Try different SNR and M's
Ms = 2.^(1:1:10);
SNRs = 5:1:80;

result = zeros(length(Ms),length(SNRs));

for i = 1:length(Ms)
    for j = 1:length(SNRs)
        k = log2(Ms(i));
        ranseq = randi([0,1],1000*k,1);
        qam = qam_mod(ranseq, Ms(i));
        sig = awgn(qam,SNRs(j));
        SNRs(j)
        demodSig = qam_demod(sig,Ms(i));
        [numberErr,result(i,j)] = ber(ranseq,demodSig);   
    end
end
%%
surf(Ms, SNRs, result');
xlabel('Ms')
ylabel('SNRs')
zlabel('result')


