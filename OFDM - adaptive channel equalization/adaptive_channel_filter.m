function [W, filteredOutput] = adaptive_channel_filter(u,initialW,mu,alpha,qam_order)

    W = zeros(size(u,1),size(u,2)+1);
    filteredOutput = zeros(size(u));
    D = zeros(size(u));
    W(:,1)= initialW;
    for L = 1:size(u,2)
        D(:,L) = decision_device(conj(W(:,L)).* u(:,L), qam_order);
        for t = 1:size(u,1)
%             D(t,L) = decision_device(conj(W(t,L))*u(t,L),qam_order);
            W(t,L+1) = W(t,L) + mu/(alpha+conj(u(t,L))*u(t,L)) *u(t,L)*conj(D(t,L)-conj(W(t,L))*u(t,L));
            filteredOutput(t,L) = conj(W(t,L+1))*u(t,L);
        end
    end
    
end

