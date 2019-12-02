function visualize_demod(qamsig,H, refreshRate, Ld, bitStream, imageData, colorMap, imageSize, bitsPerPixel)
    Ld*(N/2-1)*log1
    for i = 1: :size(H)
        subplot(2,2,1); plot(ifft(H(:,i)));
        subplot(2,2,2); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
        subplot(2,2,3); plot(abs(H));
        subplot(2,2,4); plot(bitstreamtoimage(qamsig(1:i*Ld), imageSize, bitsPerPixel));
        
        pause(1/refreshRate);
    end
end

