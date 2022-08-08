load MBB2017_behavioral_dataset.mat

nRats = length(dataset);
%% Prepare standatas
inc = [1,0,1,0,0,1,1,0];
for rat_i = 1:nRats
    ratdata = dataset{rat_i};
    standatas{rat_i} = ratdata2standata(ratdata);
end

%% Fit Reduced Model
inc = [1,0,1,0,0,1,1,0];
for rat_i = 1:length(standatas)
    standatas{rat_i}.inc = inc;
    disp(['Fitting reduced model, rat #',num2str(rat_i)]);
    wd = ['working_folders/',datestr(now,'yyyymmdd_HHMMSSFFF')];
    mkdir(wd);
    fit = stan('file','multiagent_model_single.stan','data',standatas{rat_i},'verbose',false,'method','optimize','working_dir',wd);
    fit.block;
    fits_extracted(rat_i) = extract(fit);
    rmdir(wd,'s');
end


params = {'betaMB_norm','betaBonus_norm','betaPersev_norm','betaBias'};
param_labels = {'MB','CS/US','Persev','Bias'};

param_signs = [1,-1,1,1];
jit = 0.01;
jitter = (0:jit:jit*(nRats-1)) - (jit*nRats/2);
figure; hold on
for param_i = 1:length(params)
    xs = param_i*ones(1,nRats) + jitter;
    param_estimates = [extractfield(fits_extracted,params{param_i})];
    sign = param_signs(param_i);
    scatter(xs,sign*param_estimates,'x','sizedata',50,'markeredgecolor',mslblue);
    errorbar([param_i,4,1],[mean(param_estimates),nan,nan],[sem(param_estimates),nan,nan],'color',msdblue,'linewidth',3);
end
% The silly 7 and 1 dummies are so errorbar plots with uniform length
% horizontal bars
set(gca,'fontsize',14,'xtick',1:7,'xticklabel',param_labels)
ylabel('Normalized Mixture Weight','fontsize',16)