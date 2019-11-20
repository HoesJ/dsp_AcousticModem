function [out_aligned] = alignIO(out,pulseOrThreshold)

% align the input "out" using a pulse or a threshold value. The function return the "out" signal with the pulse cut off. ~
% if the input pulseOrThreshold is a vector, it uses the crosscorrelation
% between out and pulseOrThreshold to return out_aligned.
% if input pulseOrThreshold is a 

    IRtime = 150;
    safetyMargin = 20; %safetymargin as to not cut of any data.
    
if length(pulseOrThreshold) > 1
    
    [xcor, lags] = xcorr(out,pulseOrThreshold);
    xcor = xcor/ max(xcor);
    [~, maxCorrIndex] = max(xcor);
    delay = lags(maxCorrIndex);
    
    out_aligned = out(delay+ length(pulseOrThreshold)+ IRtime - safetyMargin:end);
    
else
    out_aligned = out(find(out> pulseOrThreshold,1)+ IRtime - safetyMargin:end);
   
end

