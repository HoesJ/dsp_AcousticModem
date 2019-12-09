function [a,b, H1and2] = fixed_transmitter_side_beamformer(H1,H2)

    a = conj(H1)./ sqrt(H1.*conj(H1)+H2.*conj(H2));
    b = conj(H2)./ sqrt(H1.*conj(H1)+H2.*conj(H2));
    
    sumAB  = sqrt(a.*conj(a)+ b.*conj(b));
    if(sumAB ~= 1)
        error('a and b do not add up to 1');
    end
    
    H1and2 = sqrt(H1.*conj(H1)+H2.*conj(H2));
end