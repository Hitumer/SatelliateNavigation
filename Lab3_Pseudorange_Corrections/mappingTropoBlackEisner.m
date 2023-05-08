% The Black and Eisner mapping functions as defined in RTCA DO-229D. 
% 
% Argument:
% el: elevations to the satellites [rad]
%
% Return:
% md: The computed mapping function value for the dry components
% mw: The computed mapping function value for the wet components
function [mw,md] = mappingTropoBlackEisner( el )

md = 1.001./(sqrt(0.002001+sin(el).^2));
mw = md;


end