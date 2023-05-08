% Compute the geometry-preserving, ionosphere-free linear combination
%
% Arguments:
% PR1: Pseudorange observation received with the signal1(f1)
% PR2: Pseudorange observation received with the signal2(f2)
%
% Return:
% p_if: Ionoshere-free pseudorange observation 
function p_if = buildIFCombination(PR1, PR2)

f1 = 154.0*10.23e6;
f2 = 120.0*10.23e6;
Alpha_Matrix = [1,0]*inv([1,1;1,(f1/f2)^2]);
Alpha_1 = Alpha_Matrix(1);
Alpha_2 = Alpha_Matrix(2);
p_if = PR1*Alpha_1+PR2*Alpha_2;
end