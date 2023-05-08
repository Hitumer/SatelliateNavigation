% m2 = findSecondmax( Cm )
%
% returns the second maximum of the matrix Cm, spaced at least Tc 
% from the first maximum of Cm in the tau-direction
% 
% Cm......the correlation matrix (rows=frequencies, columns=code phases)
% 
function m2 = findSecondMax( Cm )

% Vector of all the searched taus
dtau = 1023/size(Cm,2);
tauVector = 0:dtau:1023-dtau;

% Find the first maximum
[m11,i11] = max( Cm );
[m1,i12] = max( m11 );

% Extract the Codephase-Delay part for the found maximum
Cmtau = Cm( i11(i12), : );

% Look for the second maximum, spaced >Tc from the first
m2 = max(Cmtau( [1:i12-ceil(1/dtau) i12+ceil(1/dtau):end] ));
