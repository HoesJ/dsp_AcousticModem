function [simin,nbsecs,fs]=initparams(toplay,fs)
    simin = zeros(fs*2,1);
    
    % Add synchonisation pulse
    pulseLength = 0.1 *fs;
    simin = [simin; transpose(sinc(-2:4/pulseLength:2).^2);zeros(150,1)];
%     toplay = rescale(toplay, -1,1);
    if (max(toplay) ~= min(toplay))
        toplay = 2 * (toplay - min(toplay)) / (max(toplay)-min(toplay)) - 1;
    end
    simin = [simin;toplay];
    simin = [simin; zeros(fs,1)];
    nbsecs = length(simin)/fs;
    simin = [simin,simin];
end