clear all
close all

% Mock curve fit data

% Curve fit for mean
xAxisMean = [.75 .8 .85 .9 .95 1 1.05 1.1 1.15 1.2 1.25];
mockDataMeanNoise = [100 95 90 80 70 50 25 15 10 5 0];
mockDataMeanNoNoise = [100 97 92 82 72 50 23 13 7 3 0];

figure(1)
plot(xAxisMean,mockDataMeanNoise);
hold on
plot(xAxisMean, mockDataMeanNoNoise);

% Curve fit for var
xAxisVar = [.1 .12 .14 .16 .18 .2 .22 .24 .26 .28 .3];
mockDataVarNoise = [100 95 90 80 70 50 25 15 10 5 0];
mockDataVarNoNoise = [100 97 97 91 85 80 75 50 30 15 0];

figure(2)
plot(xAxisVar,mockDataVarNoise);
hold on
plot(xAxisVar, mockDataVarNoNoise);

% Mock bar graph data

% Graph for variance
varNoNoiseBar = .2;
varNoiseBar = .3;

figure(3)
bar([varNoNoiseBar,varNoiseBar]);
hold on
errorbar([varNoNoiseBar,varNoiseBar],[.01,.01],'.k', 'linewidth', 2)
str = {'Variablity appears smaller under conditions of uncertainty'}; % cell-array method
title(str,'FontSize',15,'FontWeight','bold')
% xlabel('Ratio','FontSize',15);
ylabel('Variance Level','FontSize',15);
set(gca,'XTickLabel',{'No Noise', 'Noise'});
set(gca,'ylim',[0,.35]);
% set(gca,'xlim',[.1,.3]);


% Graph for mean JND
meanNoNoiseBar = .1;
meanNoiseBar = .1;

figure(4)
bar([meanNoNoiseBar,meanNoiseBar]);
hold on
errorbar([meanNoNoiseBar,meanNoiseBar],[.01,.01],'.k', 'linewidth', 2)
str = {'Variablity appears smaller under conditions of uncertainty'}; % cell-array method
title(str,'FontSize',15,'FontWeight','bold')
% xlabel('Ratio','FontSize',15);
ylabel('Variance Level','FontSize',15);
set(gca,'XTickLabel',{'No Noise', 'Noise'});
set(gca,'ylim',[0,.15]);
% set(gca,'xlim',[.1,.3]);


