function x_sun = sunpos( year, day, t )

y = year;
doy = day;
fd = t / 86400;
years = y - 1900;
iy4 = mod( mod(y,4), 4 );
yearfrac = (( (4*(doy-1/(iy4+1))-iy4-2)+4*fd ) / 1461 );
time = years + yearfrac;

elm = mod(4.881628+2*pi*yearfrac+0.0001342*time,2*pi);
gamma = 4.90823 + 0.00030005*time;
em = elm - gamma;
eps0 = 0.40931975 - 2.27e-6*time;
e = 0.016751 - 4.2e-7*time;
esq = e^2;
v = em + 2.0*e*sin(em) + 1.25*esq*sin(2.0*em);
elt = v + gamma;
r = (1.0 - esq)/(1.0 + e*cos(v));
elmm = mod((4.72 + 83.9971*time),2*pi);
coselt = cos(elt);
sineps = sin(eps0);
coseps = cos(eps0);
w1 = -r*sin(elt);
selmm = sin(elmm);
celmm = cos(elmm);

MeanEarthMoonBary = 3.12e-5;
AU_CONST = 1.49597870e11;

x_sunCIS = zeros(3,1);
x_sunCIS(1) = (r*coselt+MeanEarthMoonBary*celmm)*AU_CONST;
x_sunCIS(2) = (MeanEarthMoonBary*selmm-w1)*coseps*AU_CONST;
x_sunCIS(3) = (-w1*sineps)*AU_CONST;

ts = ( UTC2SID(year,doy,t)*2*pi/24.0 );

x_sun = zeros(3,1);
x_sun(1) = cos(ts)*x_sunCIS(1) + sin(ts)*x_sunCIS(2);
x_sun(2) = -sin(ts)*x_sunCIS(1) + cos(ts)*x_sunCIS(2);
x_sun(3) = x_sunCIS(3);

end

function sid = UTC2SID( year, doy, t )
h = t/3600;

jd = JD( year, doy, t );

tt = (jd - 2451545)/36525;

sid = 24110.54841 + tt*( (8640184.812866) + tt*( (0.093104) - (6.2e-6*tt)) );
sid = sid/3600 + h;
sid = mod(sid,24);

if sid < 0
    sid = sid + 24;
end
end

function jd = JD( year, doy, t )
dv = datevec(datenum(year,1,1) + doy-1 + t/(24*3600));
jd =greg2julian(year,dv(2),dv(3),dv(4),dv(5),dv(6));
end