function [qamsig,H] = ofdm_demod(ofdm_seq,N,L,trainblock,Lt,Ld)
    % Padd  signal to buckets
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
    num_processing_blocks = floor(size(qamsig,2)/(Lt+Ld)); % POSSIBLE POINT OF ERRORS
    H = zeros(N/2-1, num_processing_blocks);
    for i = 1:num_processing_blocks
        for j = 1:length(trainblock)
            A = transpose(qamsig(j,((i-1)*(Lt+Ld)+1):((i-1)*(Lt+Ld)+Lt) ));
            b = repmat(trainblock(j), size(A,1),1);
            H(j,i) = b\A;
        end
        disp(i);
    end

    % Channel equalisation and data extraction
    datasig = zeros(N/2-1,num_processing_blocks*Ld);
    for i = 1:num_processing_blocks
        extractrange = ((i-1)*(Lt+Ld)+Lt+1):((i-1)*(Lt+Ld)+Lt+Ld);
        storerange = ((i-1)*Ld+1):(i*Ld);
        datasig(:,storerange) = diag(H(:,i))\qamsig(:,extractrange);
    end
    
    % reshape to a line
    qamsig = datasig(:);    
end
