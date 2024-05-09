
% Scales the values by .63(Slightly irrelevant Treissman uses .76 to
% compensate for people judging between area and diameter

for i = 1:1000
data = randn(16,1);
data = data-mean(data);
data = data/std(data);
data = .5*data+2.5;
scale_data = min(data)*exp(.63*data)/min(exp(.63*data));  % Scales the data by a power funtion of .63
sdata = sort(data);
ssdata = sort(scale_data);
d(i) = mean(scale_data)/mean(data);
end
mean(d)


plot(sdata)
hold on
plot(ssdata,'r')
