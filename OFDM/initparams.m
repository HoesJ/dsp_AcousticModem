function [simin,nbsecs,fs,pulse]=initparams(toplay,fs)
    simin = zeros(fs*2,1);
    
    % Add synchonisation pulse
    pulseLength =  0.1;
    pulseRep = 1;
    pulseBreak = 200;
    pulse = transpose(sin(2*pi*1800*(0:1/fs:pulseLength)));
    pulseAll = repmat([pulse;zeros(pulseBreak,1)],pulseRep,1);
    
    simin = [simin;pulseAll];
    
    % scale 
    if (max(toplay) ~= min(toplay))
        toplay = 2 * (toplay - min(toplay)) / (max(toplay)-min(toplay)) - 1;
    end
    
    simin = [simin;toplay];
    simin = [simin; zeros(fs,1)];
    nbsecs = length(simin)/fs;
    simin = [simin,simin];
end