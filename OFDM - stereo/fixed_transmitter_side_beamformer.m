function [a,b, H1and2] = fixed_transmitter_side_beamformer(h1,h2)

    H1 = fft(h1);
    H2 = fft(h2);

    a = conj(H1)./ sqrt(H1.*conj(H1)+H2.*conj(H2));
    b = conj(H2)./ sqrt(H1.*conj(H1)+H2.*conj(H2));
    
    sumAB  = sqrt(a.*conj(a)+ b.*conj(b));
    if(sumAB ~= 1)
        error('a and b do not add up to 1');
    end
    
    H1and2 = sqrt(H1.*conj(H1)+H2.*conj(H2));
    h1and2 = ifft(H1and2);
    h1and2 = h1and2(1:round(length(h1and2)/2),1);
    H1and2 = 2*fft(h1and2, length(H1and2));
end

%%code that did not do the job

%     a = zeros(fBins,1);
%     b = zeros(fBins,1);
%     for k = 1:fBins
%         a(k,1) = conj(H1(k,1))/ sqrt(H1(k,1)*conj(H1(k,1)+H2(k,1)*conj(H2(k,1))));
%         b(k,1) = conj(H2(k,1))/ sqrt(H1(k,1)*conj(H1(k,1)+H2(k,1)*conj(H2(k,1))));
% 
% 
%         sumAB  = sqrt(a(k,1)*conj(a(k,1))+ b(k,1)*conj(b(k,1)));
%         if(sumAB ~= 1)
%             error('a and b do not add up to 1');
%         end
%     end