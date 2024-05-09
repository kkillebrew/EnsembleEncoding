% rawdata(n,1) = filter
% rawdata(n,2) = iteration
% rawdata(n,3) = start
% rawdata(n,4) = step value
% rawdata(n,5) = filter order
% rawdata(n,6) = random mean value
% rawdata(n,7) = which was more variable/larger
% rawdata(n,8) = reversal
% rawdata(n,9) = experiment number

clear

ntrials=10;
nfilts=2;
nstarts=2;
nits=2;

load('TEST');

for i=1:length(rawdata)
    if rawdata(i,1)==0
        rawdata(i,1)=1;
    else
        rawdata(i,1)=2;
    end
end

all_list_variance=zeros(ntrials,9,nfilts,nstarts,nits);
all_list_mean=zeros(ntrials,9,nfilts,nstarts,nits);

for i=1:2
    for j=1:2
        for k=1:2
            
            v=1;
            m=1;
            
            for l=1:length(rawdata)
                if rawdata(l,6)==0
                    if rawdata(l,1)==i && rawdata(l,2)==j && rawdata(l,3)==k
                        all_list_variance(v,:,i,j,k)=rawdata(l,:);
                        v=v+1;
                    end
                else
                    if rawdata(l,1)==i && rawdata(l,2)==j && rawdata(l,3)==k
                        all_list_mean(m,:,i,j,k)=rawdata(l,:);
                        m=m+1;
                    end
                end
            end
        end
    end
end

for i=1:2
    for j=1:2
        for k=1:2
            disp(all_list_variance(:,:,i,j,k))
        end
    end
end