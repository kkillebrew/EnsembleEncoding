clear
close all

dotAmount=20;
u=50;
o=1;

x=u-(4*o):u+(4*o);

bot1=o*sqrt(2*pi);
bot2=(2*o^2);

for i=1:length(x)
    top=(-1*((x(i)-u)^2));
    y(i)=(1/bot1)*exp(top/bot2);
end

y=y*dotAmount;
y=round(y);
dotAmount=sum(y);

plot(x,y)


y=y*dotAmount;
y=round(y);
newDotAmount=sum(y);

dotSizes=[];
z=1;
for i=1:length(y)
    if y(i)~=0
        dotSizes(z:z+y(i)-1)=x(i);
        z=z+y(i);
    end
end
