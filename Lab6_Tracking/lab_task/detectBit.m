% bit = detectBit( Ip )
% Find the navigiation bit, while 20 Inphase-samples are transmitted
% 
% Input:
% Ip...... 20 consecutive Inphase-samples
% 
% Output:
% bit..... +1 / -1

function bit = detectBit( Ip )

    sum_Ip = sum(Ip);
% MVP calculate the bit 
    if sum_Ip >= 0

        bit = 1;
    else
        bit = -1;

    end


end