% t0 = findFirstBitTransition( Ip )
% 
% finds the first bit transition in the Inphase-samples Ip
% 
% returned value:
% t0...... the number of the first bit transition sample
function t0 = findFirstBitTransition( Ip )

transitionValues = ones(1,40);
transitionValues(21:end) = -1;

[m,idx] = max( abs(xcorr(Ip,transitionValues)) );
t0 = mod( idx-length(Ip), 20 );