N = 8;
P = 5;
[ofdmSeq] = ofdm_mod(qam,N,P);

[returnedqam] = ofdm_demod(ofdmSeq,N,P);


