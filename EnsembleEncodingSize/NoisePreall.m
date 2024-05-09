
datafile='noiseFilter';

[w,rect]=Screen('OpenWindow', 0,[0 0 0]);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

% Preallocating the noise filter for each trial
noiseMatrix=[];
for i=1:1440
    for j=1:2560
        n=randi(2);
        if n==1
            noiseMatrix(i,j)=255;
        else
            noiseMatrix(i,j)=0;
        end
    end
end
destRect = [0,0,rect(3),rect(4)];

save(datafile,'noiseMatrix','destRect');

Screen('Close',w);