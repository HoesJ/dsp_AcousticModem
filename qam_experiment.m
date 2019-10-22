M = 64;
k = log2(M);
ranseq = randi([0,1],1000*k,1);

qam = qam_mod(ranseq, M);

scatterplot(qam);

sig = awgn(qam,25);

bandpower(qam)
bandpower(sig)

demodSig = qam_demod(sig,M);
sum(ranseq-demodSig)
std(ranseq-demodSig)
cd = comm.ConstellationDiagram('ShowReferenceConstellation',false);
step(cd,sig)
[numberErr,ratio] = biterr(ranseq,demodSig)