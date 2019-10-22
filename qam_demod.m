function [demodSig] = qam_demod(qamSig,order)

 demodSig = qamdemod(qamSig,order,'outputtype','bit');
end