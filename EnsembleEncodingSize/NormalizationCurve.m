clear
close all

u=50;
o=1;

x=u-(4*o):.00001:u+(4*o);

bot1=o*sqrt(2*pi);
bot2=(2*o^2);

for i=1:length(x)
    top=(-1*((x(i)-u)^2));
    y(i)=(1/bot1)*exp(top/bot2);
end

plot(x,y)