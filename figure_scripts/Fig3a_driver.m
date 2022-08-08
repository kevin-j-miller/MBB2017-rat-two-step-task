load MBB2017_behavioral_dataset.mat
example_rats = [17, 2, 13];
nBack = 5;


%% Prepare standatas
inc = [1,0,1,0,0,1,1,0];
for rat_i = 1:length(dataset)
    ratdata = dataset{rat_i};
    standatas{rat_i} = ratdata2standata(ratdata, inc);
end

%% Fit the model
currdir = pwd;
cd behavior-analysis\stan-models
for rat_i = 1:length(example_rats)
    rat_ind = example_rats(rat_i);
    disp(['Fitting reduced model, rat #',num2str(rat_i)]);
    wd = ['working_folders/',datestr(now,'yyyymmdd_HHMMSSFFF')];
    mkdir(wd);
    fit = stan('file', 'multiagent_model_single.stan', 'data', standatas{rat_ind}, 'verbose', false, 'method', 'optimize', 'working_dir', wd);
    fit.block;
    fits_extracted(rat_ind) = extract(fit);
    rmdir(wd,'s');
end
cd(currdir);

%% Get simdata, compare to ratdata

for rat_i = 1:length(example_rats)
    
    rat_ind = example_rats(rat_i);
    p = fits_extracted(rat_ind);
    ratdata = dataset{rat_ind};
    
    params = [p.alphaMB, p.betaMB, p.betaBonus, p.betaPersev, p.betaBias];
    simdata = generate_simulated_data('mb_bonus_persev_bias',params,ratdata);
    
    twostep_glm(ratdata,nBack); legend off
    yl = get(gca,'ylim');
    
    title(['Rat #',num2str(rat_i)],'fontsize',16);
    set(gca,'fontsize',14);
    ylabel({'Same/Other','Regression Weight'},'fontsize',16);
    xlabel('Trials Ago','fontsize',16);
    
    twostep_glm(simdata,nBack); legend off
    title(['Mixture Model Fit to Rat #',num2str(rat_i)],'fontsize',16);
    set(gca,'fontsize',14);
    ylabel({'Same/Other','Regression Weight'},'fontsize',16);
    xlabel('Trials Ago','fontsize',16);
   
end
