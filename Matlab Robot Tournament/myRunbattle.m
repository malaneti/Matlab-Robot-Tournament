function [] =myRunbattle(n)
close all
array=zeros(1,n);
for i=1:n
[winner, err, errstr] = battle_v2(@marvin, @RockyBalboBot_v11, 'asym',0, 2);
array(i)=winner(1);
end
hist(array)
xlabel('winner')
ylabel('Number of Occurences')
title('Histogram of battle wins')
end