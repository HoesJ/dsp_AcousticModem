function [qamsig] = ofdm_demod(ofdm_seq,N,P)
   %N is the frame size
   qamstep = N/2-1;
   qamsig = [];
   
for i = 1:P
    frame = fft(ofdm_seq(:,i));
    qamsig = [qamsig;frame(2:qamstep+1,1)];
    
end
    
end
