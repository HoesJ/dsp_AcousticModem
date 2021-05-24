function [simin,nbsecs,fs,pulse]=initparams_stereo(toplayleft,toplayright,fs,L,silence)
    if (nargin < 5)
        silence = 2;
    end
    simin = zeros(fs*silence,2);
    
    % Add synchonisation pulse
    pulseLength =  0.3;
    pulseRep = 1;
    pulseBreak = L;
    pulse = transpose(sin(2*pi*1800*(0:1/fs:pulseLength)));
    pulse = repmat([pulse;zeros(pulseBreak,1)],pulseRep,1);
    pulse = [pulse,pulse];
    
    simin = [simin;pulse];
    
    % scale 
    if (max(toplayleft) ~= min(toplayleft))
        toplayleft = 2 * (toplayleft - min(toplayleft)) / (max(toplayleft)-min(toplayleft)) - 1;
    end

    if (max(toplayright) ~= min(toplayright))
        toplayright = 2 * (toplayright - min(toplayright)) / (max(toplayright)-min(toplayright)) - 1;
    end
    
    toplay = [toplayleft,toplayright];
    
    simin = [simin;toplay];
    simin = [simin; zeros(silence*fs,2)];
    nbsecs = length(simin)/fs;
%     simin = [simin,simin];

    pulse = pulse(:,1);
end