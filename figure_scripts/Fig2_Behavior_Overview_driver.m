%% Driver script to generate the behavior overview figures. There are four panels here
% Grab all behavior data
load MBB2017_behavioral_dataset.mat
% Set nBack for the glms
nBack = 5;
% Set params for the simulations
alpha = 0.6;
betaMB = 2;
betaMF = 1.2;

%% Panels 1&2: Theory plots for MF and MB
% Generate simulated data
task = dataset{1};
simdata_mb = generate_simulated_data('mb',[alpha,betaMB],task);
simdata_mf = generate_simulated_data('mf',[alpha,betaMF],task);

results_mb = twostep_glm(simdata_mb,nBack); title('');
legend off; set(gca,'ytick',[-1,0,1],'fontsize',20); ylim([-1,1])
set(gca,'FontSize',25);

results_mf = twostep_glm(simdata_mf,nBack); title('');
legend off; set(gca,'ytick',[-1,0,1],'fontsize',20); ylim([-1,1])
set(gca,'FontSize',25);

%% Panel 3: Behavior Example
% Plot the example rat
example_ind = 17;

results_example = twostep_glm(dataset{example_ind},nBack); title('');
set(gca,'FontSize',25);
legend off; ylim([-0.5,1.2])

%% Panel 4: Behavior Scatter
for rat_i = 1:length(dataset)
    
    results = twostep_glm(dataset{rat_i},nBack,false);
    mb_inds(rat_i) = results.mb_ind;
    mf_inds(rat_i) = results.mf_ind;
    
end


figure; hold on;
scatter(mb_inds, mf_inds,40,'x','linewidth',1.5,'MarkerEdgeColor',mslblue);
scatter(results_example.mb_ind,results_example.mf_ind,40,'x','linewidth',1.5,'MarkerEdgeColor',msdblue);
set(gca,'FontSize',25);

line([-10,10],[-10,10],'Color',[0.5,0.5,0.5]);
max_ind = max(max([mb_inds,mf_inds]));
min_ind = min(min([mb_inds,mf_inds,0.2]));

ylim([min_ind - 0.2,max_ind + 0.2])
xlim([min_ind - 0.2,max_ind + 0.2])

