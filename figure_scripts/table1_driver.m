load MBB2017_infusion_dataset

data_saline = dataset.data_saline_all;
data_ofc = dataset.data_ofc;
data_hippo = dataset.data_hippo;
data_cntrl_ofc = dataset.data_cntrl_ofc;
data_cntrl_hippo = dataset.data_cntrl_hippo;

nRats = 6;

data_names = {'Hippo','OFC'};
data_infs = {data_hippo,data_ofc};
data_cntrls = {data_saline, data_saline};


for data_i = 1:2
    
    data_inf = data_infs{data_i};
    data_cntrl = data_cntrls{data_i};

nTrials_cntrl = 0;
nTrials_inf = 0;
choices_cntrl = [];
rewards_cntrl = [];
outcomes_cntrl = [];
rats_cntrl = [];
choices_inf = [];
rewards_inf = [];
outcomes_inf = [];
rats_inf = [];

for rat_i = 1:nRats
    
    data_cntrl_rat = data_cntrl{rat_i};
    data_inf_rat = data_inf{rat_i};
   
    pCong = 0.6*round(data_inf_rat.p_congruent) + 0.2; % Round to exactly 0.2 or 0.8
    pCongs(rat_i) = pCong;

    nTrials_cntrl_rat = data_cntrl_rat.nTrials;
    nTrials_inf_rat = data_inf_rat.nTrials;
    
    nTrials_cntrl = nTrials_cntrl + nTrials_cntrl_rat;
    nTrials_inf = nTrials_inf + nTrials_inf_rat;
    
    choices_cntrl = [choices_cntrl;(data_cntrl_rat.sides1=='l')+1];
    outcomes_cntrl = [outcomes_cntrl;(data_cntrl_rat.sides2=='l')+1];
    rewards_cntrl = [rewards_cntrl;data_cntrl_rat.rewards];
    rats_cntrl = [rats_cntrl;rat_i*ones(nTrials_cntrl_rat,1)];
    
    choices_inf = [choices_inf;(data_inf_rat.sides1=='l')+1];
    outcomes_inf = [outcomes_inf;(data_inf_rat.sides2=='l')+1];
    rewards_inf = [rewards_inf;data_inf_rat.rewards];
    rats_inf = [rats_inf;rat_i*ones(nTrials_inf_rat,1)];
    
    
end    
    

standata.nRats = nRats;
standata.pCongs = pCongs;

standata.choices_cntrl = choices_cntrl;
standata.rewards_cntrl = rewards_cntrl;
standata.outcomes_cntrl = outcomes_cntrl;
standata.rats_cntrl = rats_cntrl;
standata.nTrials_cntrl = nTrials_cntrl;

standata.choices_inf = choices_inf;
standata.rewards_inf = rewards_inf;
standata.outcomes_inf = outcomes_inf;
standata.rats_inf = rats_inf;
standata.nTrials_inf = nTrials_inf;

fit_inf = stan('file','twostep_multiagent_infusion_population_normBetas_logAlpha.stan','data',standata,'verbose',true,'chains',5,'warmup',1000,'iter',600); 
fit_inf.block();
fit_inf_extracted = extract(fit_inf);
fit_inf_printed = print(fit_inf);

save(['fit_logAlpha_',data_names{data_i},'_moreSamples'],'fit_inf_extracted','fit_inf_printed','standata');

end