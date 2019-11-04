M = 64;
k = log2(M);
ranseq = randi([0,1],1000*k,1);

qam = qam_mod(ranseq, M);
sig = awgn(qam,25);

cd = comm.ConstellationDiagram('ShowReferenceConstellation',false);
step(cd,sig)

demodSig = qam_demod(sig,M);
[numberErr,ratio] = ber(ranseq,demodSig);

%% Try different SNR and M's
Ms = 2.^(1:1:10);
SNRs = 5:1:40;

result = zeros(length(Ms),length(SNRs));

for i = 1:length(Ms)
    for j = 1:length(SNRs)
        k = log2(Ms(i));
        ranseq = randi([0,1],1000*k,1);
        qam = qam_mod(ranseq, Ms(i));
        sig = awgn(qam,SNRs(j));
        demodSig = qam_demod(sig,Ms(i));
        [numberErr,result(i,j)] = ber(ranseq,demodSig);   
    end
end
%%
figure
imagesc('XData',SNRs,'YData',Ms,'CData',result);
title('BER (QAM)');
xlabel('SNR');
ylabel('M');

figure
hold on
plot(Ms, result(:,6));
plot(Ms, result(:,11));
plot(Ms, result(:,16));
plot(Ms, result(:,26));
plot(Ms, result(:,36));
xlabel('M');
ylabel('BER');
legend('10 SNR', '15 SNR', '20 SNR', '30 SNR', '40 SNR');
hold off