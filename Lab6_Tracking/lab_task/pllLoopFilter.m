% [y,h] = pllLoopFilter( x, h )
% The loop filter for the PLL with the current input x and the previously returned
% vector h
% 
% Inputs:
% x..... The current input of the filter
% h..... The vector containing the previous input and output of the filter (dimension 1x4)
%        -> h(1) = x_{k-1}: previous input
%        -> h(2) = y_{k-1}: previous output
%        -> h(3) = h(4) = 0 
% 
% Outputs:
% y..... The current output of the filter
% h..... The vector containing the current input and output of the filter (dimension 1x4)
%        -> h(1) = x_{k}: current input
%        -> h(2) = y_{k}: current output
%        -> h(3) = h(4) = 0 

function [y,h] = pllLoopFilter( x, h )

zeta = 1.3;
wn   = 8*15*zeta/(4*zeta^2+1);
Ti   = 1e-3;

% Implement the 2nd order loop filter
   y = 2*zeta*wn*x +(wn^2*Ti - 2*zeta*wn)*h(1) + h(2);
        h(1) = x;
        h(2) = y;
        h(3) = 0;
        h(4) = 0;
end