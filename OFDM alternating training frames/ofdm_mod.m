function [ofdm_seq] = ofdm_mod(qamsig,N,L,trainblock,Lt,Ld)
    
        % Pad qamsig to multiple of lastBin (N/2-1)
        qamsig = [qamsig;zeros(ceil(length(qamsig) / (N/2 - 1)) * (N/2 - 1) - length(qamsig),1)];

        % Define P
        P = length(qamsig) / (N/2 - 1);

        %N is the frame size
        dataframe = reshape(qamsig, [N/2 - 1,P]);
        dataframe = [zeros(1,P);dataframe;zeros(1,P);conj(flip(dataframe))];
        ofdm_data = ifft(dataframe);
        
        %training frames
        trainingframe = [0;trainblock;0;conj(flip(trainblock))];
        ofdm_training = ifft(trainingframe);
        
        %interleaving of data and training
        ofdm_packet = [];
        for i = 1:size(dataframe, 2)
           if (mod(i, Ld))
                ofdm_packet = [ofdm_packet, repmat(ofdm_training, 1, Lt), ofdm_data(:,i:(i+Ld-1))];
           end
        end
        % add cyclic prefix
        ofdm_seq = [ofdm_packet(N-L+1:N,:);ofdm_packet];

        % reshape to long sequence
        ofdm_seq = reshape(ofdm_seq, [(N+L)*P 1]);
end

