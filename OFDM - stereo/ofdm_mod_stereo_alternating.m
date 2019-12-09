function [ofdm_seq1, ofdm_seq2] = ofdm_mod_stereo_alternating(qamsig1,qamsig2, N,L,trainblock,Lt,Ld,a,b,usedbins)
        
        if (nargin < 10)
            usedbins = 1:(N/2-1);
        end
        num_bins = length(usedbins);
        
        % Pad qamsig to multiple of lastBin*Ld (N/2-1)
        mult = num_bins * Ld;
        qamsig1 = [qamsig1;zeros(ceil(length(qamsig1) / mult) * mult - length(qamsig1),1)];
%         last = qamsig(length(qamsig));
%         qamsig = [qamsig;repmat(last, ceil(length(qamsig) / mult) * mult - length(qamsig),1)];

        % Define P
        P = length(qamsig1) / num_bins;

        % N is the frame size
        dataframe = zeros(N/2-1, P);
        dataframe(usedbins,:) = reshape(qamsig1, [num_bins,P]);
        dataframe = a.*dataframe;
        dataframe = [zeros(1,P);dataframe;zeros(1,P);conj(flipud(dataframe))];
        ofdm_data = ifft(dataframe);
        
        % Training frames
        trainingframe = [0;trainblock;0;conj(flip(trainblock))];
        ofdm_training = ifft(trainingframe);
        
        % Interleaving of data and training
        num_processing_blocks = P/Ld;
        prototype = [ones(1,Lt), zeros(1,Ld)];
        indices = repmat(prototype, 1, num_processing_blocks);
        
        ofdm_packet = zeros(N, num_processing_blocks * (Lt+Ld));
        ofdm_packet(:,indices == 1) = repmat(ofdm_training,1,num_processing_blocks*Lt);
        ofdm_packet(:,indices == 0) = ofdm_data;
        
        % add cyclic prefix
        ofdm_seq1 = [ofdm_packet(N-L+1:N,:);ofdm_packet];

        % reshape to long sequence
        ofdm_seq1 = ofdm_seq1(:);
        
        % do the same for the qamstream2
        
        % Pad qamsig to multiple of lastBin*Ld (N/2-1)
        mult = num_bins * Ld;
        qamsig2 = [qamsig2;zeros(ceil(length(qamsig2) / mult) * mult - length(qamsig2),1)];
%         last = qamsig(length(qamsig));
%         qamsig = [qamsig;repmat(last, ceil(length(qamsig) / mult) * mult - length(qamsig),1)];

        % Define P
        P = length(qamsig2) / num_bins;

        % N is the frame size
        dataframe = zeros(N/2-1, P);
        dataframe(usedbins,:) = reshape(qamsig2, [num_bins,P]);
        dataframe = b.*dataframe;
        dataframe = [zeros(1,P);dataframe;zeros(1,P);conj(flipud(dataframe))];
        ofdm_data = ifft(dataframe);
        
        % Training frames
        trainingframe = [0;trainblock;0;conj(flip(trainblock))];
        ofdm_training = ifft(trainingframe);
        
        % Interleaving of data and training
        num_processing_blocks = P/Ld;
        prototype = [ones(1,Lt), zeros(1,Ld)];
        indices = repmat(prototype, 1, num_processing_blocks);
        
        ofdm_packet = zeros(N, num_processing_blocks * (Lt+Ld));
        ofdm_packet(:,indices == 1) = repmat(ofdm_training,1,num_processing_blocks*Lt);
        ofdm_packet(:,indices == 0) = ofdm_data;
        
        % add cyclic prefix
        ofdm_seq2 = [ofdm_packet(N-L+1:N,:);ofdm_packet];

        % reshape to long sequence
        ofdm_seq2 = ofdm_seq2(:);

end

