function [ofdm_seq] = ofdm_mod(qamsig,N,L,lastBin)
    if (nargin < 4)
        lastBin = N/2 - 1;
    end

    % Pad qamsig to multiple of lastBin (N/2-1)
    qamsig = [qamsig;zeros(ceil(length(qamsig) / (lastBin)) * (lastBin) - length(qamsig),1)];
    
    % Define P
    P = length(qamsig) / lastBin;
        
    %N is the frame size
    frame = [reshape(qamsig, [lastBin,P]);zeros(N/2-1-lastBin,P)];
    frame = [zeros(1,P);frame;zeros(1,P);conj(flip(frame))];
    ofdm_seq = ifft(frame);
    
    % add cyclic prefix
    ofdm_seq = [ofdm_seq(N-L+1:N,:);ofdm_seq];
    
    % reshape to long sequence
    ofdm_seq = reshape(ofdm_seq, [(N+L)*P 1]);
   

end

