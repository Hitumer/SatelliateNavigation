% [mw,md,mw_dot,md_dot] = mopsMappingFunc( el [, el_dot] )
% 
% Returns the MOPS mapping functions as defined in RTCA DO-229D. 
% 
% el......... elevations to the satellites [rad]
% el_dot..... (optional) derivative of the elevation [rad/s]
%             (only used for the computation of the mapp. f. derivative)
function [mw,md,mw_dot,md_dot] = mopsMappingFunc( el, el_dot )

md = 1.001./sqrt( .002001+sin(el).^2 );

if el*180/pi < 4
    md = md.*( 1 + .015*max([0, 4*pi/180-el]).^2 );
end

mw = md;

if nargout > 2
    mw_dot = -(( 1.001*sin(2*el) )./( 2*(.002001+sin(el).^2).^(3/2) )).*el_dot;
    md_dot = mw_dot;
end