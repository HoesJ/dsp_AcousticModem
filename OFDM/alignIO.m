function [out_aligned, sample_number] = alignIO(out,pulseOrThreshold)

% align the input "out" using a pulse or a threshold value. The function return the "out" signal with the pulse cut off. ~
% if the input pulseOrThreshold is a vector, it uses the crosscorrelation
% between out and pulseOrThreshold to return out_aligned.
% if input pulseOrThreshold is a 

    IRtime = 150;
    safetyMargin = 5; %safetymargin as to not cut of any data.
    
if length(pulseOrThreshold) > 1
    
    [xcor, lags] = xcorr(out,pulseOrThreshold);
    xcor = xcor/ max(xcor);
    [~, maxCorrIndex] = max(xcor);
    delay = lags(maxCorrIndex);
%     plot(xcor);
    
    sample_number = delay+ length(pulseOrThreshold)+ IRtime - safetyMargin;
    out_aligned = out(delay+ length(pulseOrThreshold)+ IRtime - safetyMargin:end);
    
else
    sample_number = find(out> pulseOrThreshold,1)+ IRtime - safetyMargin;
    out_aligned = out(find(out> pulseOrThreshold,1)+ IRtime - safetyMargin:end);
    
end

