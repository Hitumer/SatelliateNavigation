function p = neville(x, f, xdach)
% Aitken- Neville- Algorithm
% 
% usage: p = neville(x, f, xdach)
%
% input: vector x - support x-coordinates
%	       vector f - support y-coordinates
%				 scalar xdach - point to evaluate
%
% output: scalar p - interpolated value at xdach

% Author : Andreas Klimke, Stuttgart University
% Date   : 2-Jun-2002
% Version: 1.0
	
	n = length(x);
	
	for k = n-1:-1:1
		f(1:k) = f(2:k+1) + ...
						 ( xdach - x(n-k+1:n) ) ./ ...
						 ( x(n-k+1:n) - x(1:k) ) .* ...
		         ( f(2:k+1) - f(1:k) );
	end
	p = f(1);
	