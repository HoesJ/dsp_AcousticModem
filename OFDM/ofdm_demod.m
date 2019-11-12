function [qamsig,H] = ofdm_demod(ofdm_seq,N,L,trainblock)
    lastBin = N/2-1;

    % Define P
    P = length(ofdm_seq) / (N + L);
    
    % reshape ofdm_sig
    qamsig = reshape(ofdm_seq, [N+L P]);
    
    % throw away cyclic prefix
    qamsig = qamsig(L+1:end,:);
    
    % fft
    qamsig = fft(qamsig);
        
    % throw away copies
    qamsig = qamsig(2:lastBin+1,:);
    
    % Channel equalisation
    H = zeros(N/2-1,1);
    for i = 1:length(H)
        A = transpose(qamsig(i,:));
        b = repmat(trainblock(i), length(A),1);
        H(i) = b\A;
    end
    qamsig = diag(H)\qamsig;
    
    % reshape to a line
    qamsig = reshape(qamsig, [lastBin*P 1]);    
end
