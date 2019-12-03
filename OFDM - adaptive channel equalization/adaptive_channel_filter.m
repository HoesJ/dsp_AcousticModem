function [W, filteredOutput] = adaptive_channel_filter(u,D, initialW, mu, alpha)

    W = zeros(size(u,1),size(u,2)+1);
    filteredOutput = zeros(size(u));
    W(:,1)= initialW;
    for L = 1:size(u,2)
        for t = 1:size(u,1)
        W(t,L+1) = W(t,L) + mu/(alpha+conj(u(t,L))*u(t,L))*u(t,L)*conj(D(t,L)-conj(W(t,L))*u(t,L));
        filteredOutput(t,L) = conj(W(t,L+1))*u(t,L);
        end
    end
    
end

