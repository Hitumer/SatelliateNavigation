re = 6378000;
rs = re+20200000;
G= 6.6743*1e-11;
M = 5.972*10^24;
delt_t = 0.001
alpha= sqrt(G*M)/rs^(3/2)*delt_t;
h = @(beta)-re*rs*sin(beta)/(sqrt(re^2+rs^2-2*re*rs*cos(beta)))*alpha;
beta0 = [0,pi];
[beta,fval] = fminsearch(h,beta0)
