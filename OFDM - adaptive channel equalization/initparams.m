function [simin,nbsecs,fs,pulse]=initparams(toplay,fs,L,silence)
    if (nargin < 4)
        silence = 2;
    end
    simin = zeros(fs*silence,1);
    
    % Add synchonisation pulse
    pulseLength =  0.3;
    pulseRep = 1;
    pulseBreak = L;
    pulse = transpose(sin(2*pi*1800*(0:1/fs:pulseLength)));
    pulse = repmat([pulse;zeros(pulseBreak,1)],pulseRep,1);
    
    simin = [simin;pulse];
    
    % scale 
    if (max(toplay) ~= min(toplay))
        toplay = 2 * (toplay - min(toplay)) / (max(toplay)-min(toplay)) - 1;
    end
    
    simin = [simin;toplay];
    simin = [simin; zeros(silence*fs,1)];
    nbsecs = length(simin)/fs;
    simin = [simin,simin];
end