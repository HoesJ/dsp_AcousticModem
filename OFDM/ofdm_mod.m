function [ofdm_seq] = ofdm_mod(qamsig,N,L)
    % Pad qamsig to multiple of N/2 - 1
    qamsig = [qamsig;zeros(ceil(length(qamsig) / (N/2-1)) * (N/2-1) - length(qamsig),1)];
    
    % Define P
    P = length(qamsig) / (N / 2 - 1);
        
    %N is the frame size
    matrix = [zeros(1,P);reshape(qamsig, [N/2-1,P]);zeros(1,P);conj(flip(reshape(qamsig, [N/2-1,P])))];
    ofdm_seq = ifft(matrix);
    
    % add cyclic prefix
    ofdm_seq = [ofdm_seq(N-L+1:N,:);ofdm_seq];
    
    % reshape to long sequence
    ofdm_seq = reshape(ofdm_seq, [(N+L)*P 1]);
   
end

