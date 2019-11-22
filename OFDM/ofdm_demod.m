function [qamsig,H] = ofdm_demod(ofdm_seq,N,L,trainblock,trainbins)
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
    if nargin < 5
        trainbins = 1:(N/2-1);
    end
    H = zeros(N/2-1,1);
    for i = trainbins
        A = transpose(qamsig(i,:));
        b = repmat(trainblock(i), length(A),1);
        H(i) = b\A;
    end
    if nargin > 4 % perform interpolation
        h = ifft([0;H;0;conj(H)]); %%% MIRROR OK?
        h(L+1:end) = 0;
        H = fft(h);
        H = H(2:512);
    end

    % Channel equalisation
    qamsig = diag(H)\qamsig;
    
    % reshape to a line
    qamsig = qamsig(:);    
end
