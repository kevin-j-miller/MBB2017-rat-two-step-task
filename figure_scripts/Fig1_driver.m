load MBB2017_behavioral_dataset.mat

%% Plot behavior example
plot_smoothed_ts(dataset{5},15);
set(gca,'FontSize',20,'YTick',[0,0.5,1],'xtick',[0,150,300])
xlim([0,381]); % 381 trials in first session from this rat
legend off

%% Plot learning curves
nRats = length(dataset);
for rat_i = 1:nRats

    results = plot_learning_curve(dataset{rat_i}, false);
    learning_curves(rat_i,:) = results.learning_curve;

end

figure; hold on
plot(learning_curves','color',lighten(msgreen,0.7));
plot(mean(learning_curves),'color',msgreen,'linewidth',3);
set(gca,'fontsize',20,'ytick',[0,0.5,1]); xlim([1,15]); ylim([0,1])