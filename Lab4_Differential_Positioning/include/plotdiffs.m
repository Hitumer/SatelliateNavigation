cols=['r' 'g' 'b' 'y' 'c' 'm' 'k' 'r' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k' 'g' 'b' 'y' 'c' 'm' 'k'];

figure;
for i=2:size(graphdifferences_1,2)
    plot([graphdifferences_1{:,1}],extractFullDataset(graphdifferences_1,i),[cols(i-1) 'x']);
    hold on;
end
figure;
for i=2:size(graphdifferences_3,2)
    plot([graphdifferences_3{:,1}],extractFullDataset(graphdifferences_3,i),[cols(i-1) 'x']);
    hold on;
end

figure;
for i=2:size(graphdifferences_ext,2)
    plot([graphdifferences_ext{:,1}],extractFullDataset(graphdifferences_ext,i),[cols(i-1) 'x']);
    hold on;
end

clear cols;