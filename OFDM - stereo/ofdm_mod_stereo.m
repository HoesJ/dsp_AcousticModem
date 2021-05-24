function [ofdm_seq1, ofdm_seq2] = ofdm_mod_stereo(qamsig1, qamsig2,N,L,trainblock,Lt, a, b, usedbins)
        
        if (nargin < 9)
            usedbins = 1:(N/2-1);
        end
        num_bins = length(usedbins);
        
        % Pad qamsig to multiple of lastBin*Ld (N/2-1)
        mult = num_bins;
        qamsig1 = [qamsig1;zeros(ceil(length(qamsig1) / mult) * mult - length(qamsig1),1)];

        % Define P
        P1 = length(qamsig1) / num_bins;

        % N is the frame size
        dataframe1 = zeros(N/2-1, P1);
        dataframe1(usedbins,:) = reshape(qamsig1, [num_bins,P1]);
        dataframe1 = a.*dataframe1;
        dataframe1 = [zeros(1,P1);dataframe1;zeros(1,P1);conj(flip(dataframe1))];
        ofdm_data1 = ifft(dataframe1);
        
        % Training frames
        trainblock1 = a.*trainblock;
        trainingframe1 = [0;trainblock1;0;conj(flip(trainblock1))];
        ofdm_training1 = ifft(trainingframe1);

        %sending training packet zith Lt training frames
        training_packet1 = repmat(ofdm_training1,1,Lt);
        ofdm_packet1 = [training_packet1, ofdm_data1];
        
        % add cyclic prefix
        ofdm_seq1 = [ofdm_packet1(N-L+1:N,:);ofdm_packet1];

        % reshape to long sequence and multiply with a.
        ofdm_seq1 = ofdm_seq1(:);
        
        %% do the same for the second qamStream
        
        % Pad qamsig to multiple of lastBin*Ld (N/2-1)
        qamsig2 = [qamsig2;zeros(ceil(length(qamsig2) / mult) * mult - length(qamsig2),1)];

        % Define P
        P2 = length(qamsig2) / num_bins;

        % N is the frame size
        dataframe2 = zeros(N/2-1, P2);
        dataframe2(usedbins,:) = reshape(qamsig2, [num_bins,P2]);
        dataframe2 = b.*dataframe2;
        dataframe2 = [zeros(1,P2);dataframe2;zeros(1,P2);conj(flip(dataframe2))];
        ofdm_data2 = ifft(dataframe2);
        
        % Training frames
        trainblock2 = b.*trainblock;
        trainingframe2 = [0;trainblock2;0;conj(flip(trainblock2))];
        ofdm_training2 = ifft(trainingframe2);

        %sending training packet zith Lt training frames
        training_packet = repmat(ofdm_training2,1,Lt);
        ofdm_packet2 = [training_packet, ofdm_data2];
        
        % add cyclic prefix
        ofdm_seq2 = [ofdm_packet2(N-L+1:N,:);ofdm_packet2];

        % reshape to long sequence
        ofdm_seq2 = ofdm_seq2(:);
        
end

