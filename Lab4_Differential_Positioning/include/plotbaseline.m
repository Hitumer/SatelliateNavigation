X=[b_hatext{:,7}];
for i=1:size(X,2)
    m(i)=norm(X(:,i));
end
baseline=mean (m);

k=[0:720];

figure;
plot(k*30/3600,m,'bx-');
hold on;
plot([0 6],[baseline baseline],'r');