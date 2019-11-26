function [qamsig,H] = ofdm_demod(ofdm_seq,N,L,trainblock,Lt,Ld)
    % Padd  signal
    ofdm_seq = [ofdm_seq;zeros(ceil(length(ofdm_seq) / (N+L)) * (N+L) - length(ofdm_seq),1)];

    % reshape ofdm_sig
    qamsig = reshape(ofdm_seq, N+L, []);
    
    % throw away cyclic prefix
    qamsig = qamsig(L+1:end,:);
    
    % fft
    qamsig = fft(qamsig);
        
    % throw away copies
    qamsig = qamsig(2:N/2,:);
    
    % Channel estimation
    num_processing_blocks = size(qamsig,2)/(Lt+Ld);
    H = zeros(N/2-1, num_processing_blocks);
    for i = 1:num_processing_blocks
        for j = 1:length(trainblock)
            A = transpose(qamsig(i,(i*(Lt+Ld)+1):(i*(Lt+Ld)+1+L) ));
            b = repmat(trainblock(count), length(A),1);
            H(i) = b\A;
            count = count + 1;
        end
    end

    % Channel equalisation
    qamsig = diag(H)\qamsig;
    
    % Extract data signal
    if nargin > 4
        databins = 1:(N/2-1);
        databins(trainbins) = 0;
        databins = databins(databins ~= 0);
        qamsig = qamsig(databins,:);
    end
    
    % reshape to a line
    qamsig = qamsig(:);    
end
