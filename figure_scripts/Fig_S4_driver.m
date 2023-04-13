% Grab all behavior data
load MBB2017_behavioral_dataset.mat

for rat_i = 1:length(dataset)
    ratdata = dataset{rat_i};
    left_outcome_port_better = ratdata.leftprobs > ratdata.rightprobs;
    went_to_better_outcome_port = (ratdata.sides2 == 'l' & left_outcome_port_better) | ...
                                (ratdata.sides2 == 'r' & ~left_outcome_port_better);
    median_c2s2_better_common(rat_i) = nanmedian(ratdata.c2s2_times(went_to_better_outcome_port & ratdata.trans_common));
    median_c2s2_worse_common(rat_i) = nanmedian(ratdata.c2s2_times(~went_to_better_outcome_port & ratdata.trans_common));
    median_c2s2_better_uncommon(rat_i) = nanmedian(ratdata.c2s2_times(went_to_better_outcome_port & ~ratdata.trans_common));
    median_c2s2_worse_uncommon(rat_i) = nanmedian(ratdata.c2s2_times(~went_to_better_outcome_port & ~ratdata.trans_common));
end

figure; hold on
title('High-Reward Outcome Port')
line([0, 5], [0, 5], 'color', [0.5, 0.5, 0.5])
scatter(median_c2s2_better_common, median_c2s2_better_uncommon, 50, 'x', 'linewidth', 2)
xlim([0.4, 1.2])
ylim([0.4, 1.2])
xlabel('Common Transition')
ylabel('Uncommon Transition')
set(gca,'fontsize',14)

figure; hold on
title('Low-Reward Outcome Port')
line([0, 5], [0, 5], 'color', [0.5, 0.5, 0.5])
scatter(median_c2s2_worse_common, median_c2s2_worse_uncommon, 50, 'x', 'linewidth', 2)
xlim([0.4, 1.2])
ylim([0.4, 1.2])
xlabel('Common Transition')
ylabel('Uncommon Transition')
set(gca,'fontsize',14)