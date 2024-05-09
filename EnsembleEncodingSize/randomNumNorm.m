dotSize=[];
dotSize=randn(1,12);
ave=50;
stdev=10;

dotSize=dotSize-mean(dotSize);
dotSize=dotSize*(std(dotSize));

dotSize=dotSize*stdev;
dotSize=dotSize+ave;