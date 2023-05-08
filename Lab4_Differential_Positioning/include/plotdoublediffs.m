cols=['r' 'g' 'b' 'y' 'c' 'm' 'k' 'r' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k'];

figure;
for i=2:size(graphdoublediffs_1,2)
    plot([graphdoublediffs_1{:,1}],extractFullDataset(graphdoublediffs_1,i),[cols(i-1) 'x']);
    hold on;
end
figure;
for i=2:size(graphdoublediffs_3,2)
    plot([graphdoublediffs_3{:,1}],extractFullDataset(graphdoublediffs_3,i),[cols(i-1) 'x']);
    hold on;
end

figure;
for i=2:size(graphdoublediffs_ext,2)
    plot([graphdoublediffs_ext{:,1}],extractFullDataset(graphdoublediffs_ext,i),[cols(i-1) 'x']);
    hold on;
end

clear cols;