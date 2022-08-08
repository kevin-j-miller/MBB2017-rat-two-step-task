%% Script to do model comparison for MMB2017
%% NOTE: Must be run while Matlab is in same folder as 'multiagent_model_single_xval.stan'
% Each model computes a cross-validated likelihood for each rat, by fitting
% parameters (maximum-likelihood) to the even-numbered sessions and testing
% on the odd-numbered sessions, and vice-versa. These likelihood scores are
% normalized by the number of trials each rat performed, and compared to
% the reference model in a final plot

%% Get data
load MBB2017_behavioral_dataset.mat
nRats = length(dataset);

%% Fit full model
inc = ones(1,8);
for rat_i = 1:nRats
   disp(['Fitting full model, rat #',num2str(rat_i)]);
   normLiks_full(rat_i) = xval_twostep_stan(dataset{rat_i},inc);
end

%% Test reduced model
reduced_inc = [1,0,1,0,0,1,1,0];
for rat_i = 1:nRats
   disp(['Fitting reduced model, rat #',num2str(rat_i)]);
   normLiks_reduced(rat_i) = xval_twostep_stan(dataset{rat_i},reduced_inc);
end

normLik_difference_full = 100* (normLiks_full - normLiks_reduced);


%% Test modifications to reduced model
for mod_i = 1:8
    mod_inc = reduced_inc;
    mod_inc(mod_i) = 1 - mod_inc(mod_i);
    mod_incs(mod_i,:) = mod_inc;
    for rat_i = 1:nRats
        disp(['Fitting Mod #', num2str(mod_i),', rat #',num2str(rat_i)]);
        normLiks_mod(mod_i,rat_i) = xval_twostep_stan(dataset{rat_i},mod_inc);
        normLik_difference_mod(mod_i,rat_i) = 100*(normLiks_mod(mod_i,rat_i) - normLiks_reduced(rat_i));
    end
end

%% Test HMM version;
for rat_i = 1:nRats
        disp(['Fitting HMM: rat #',num2str(rat_i)]);
        normLiks_HMM(rat_i) = xval_twostep_stan_HMM(dataset{rat_i},reduced_inc);
        normLik_difference_HMM(rat_i) = 100*(normLiks_HMM(rat_i) - normLiks_reduced(rat_i));
end
    

%% Load and process glm likelihoods
nBack = 5;
for rat_i = 1:nRats
    [data_even,data_odd] = split_even_odd(dataset{rat_i});
    
    results_even = twostep_glm(data_even,nBack,false);
    results_odd = twostep_glm(data_odd,nBack,false);
    
    results_even_odd = twostep_glm_test(data_odd,results_even);
    results_odd_even = twostep_glm_test(data_even,results_odd);
    
    normLiks_glm(rat_i) = exp(mean([results_even_odd.lls; results_odd_even.lls]));
    
end

normLik_difference_glm = 100*(normLiks_glm(:)' - normLiks_reduced);


%% Make some nice plots
leave_out_inds = [1,3,6,7]; 
add_in_inds = [2,4,5,8];

jitter_width = 0.4;
x_jit = (0:jitter_width/(nRats-1):jitter_width) - jitter_width/2;
xs = repmat((1:7)',[1,nRats]) + repmat(x_jit,[7,1]);

% A lot of padding here to make the errorbar tabs come out uniform. Some
% things about matlab are terrible...
ys_leaveout = [zeros(1,nRats);normLik_difference_mod(leave_out_inds,:);zeros(1,nRats)];
xs_leaveout = [zeros(1,nRats);xs(1:4,:);12*ones(1,nRats)];
ys_addin = [zeros(1,nRats);normLik_difference_mod(add_in_inds,:);normLik_difference_full;zeros(1,nRats)];
xs_addin = [zeros(1,nRats);4 + xs(1:5,:);12*ones(1,nRats)];

xs_hmm = [zeros(1,nRats);9 + xs(1,:);12*ones(1,nRats)];
ys_hmm = [zeros(1,nRats);normLik_difference_HMM;zeros(1,nRats)];

xs_glm = [zeros(1,nRats);10 + xs(1,:);12*ones(1,nRats)];
ys_glm = [zeros(1,nRats);normLik_difference_glm;zeros(1,nRats)];

figure; hold on

line([0,20],[0,0],'color','black');

scatter(xs_leaveout(:),ys_leaveout(:),'x','sizedata',50,'MarkerEdgeColor',lighten(msred,0.5));
scatter(xs_addin(:),ys_addin(:),'x','sizedata',50,'MarkerEdgeColor',lighten(dgreen,0.5));
scatter(xs_hmm(:),ys_hmm(:),'x','sizedata',50,'markeredgecolor',lighten(msblue,0.5))
scatter(xs_glm(:),ys_glm(:),'x','sizedata',50,'markeredgecolor',lighten(msblue,0.5))

errorbar(mean(xs_glm'),mean(ys_glm'),sem(ys_glm'),'.','Color',msblue,'linewidth',3);
errorbar(mean(xs_hmm'),mean(ys_hmm'),sem(ys_hmm'),'.','Color',msblue,'linewidth',3);
errorbar(mean(xs_addin'),mean(ys_addin'),sem(ys_addin'),'.','Color',dgreen,'linewidth',3);
errorbar(mean(xs_leaveout'),mean(ys_leaveout'),sem(ys_leaveout'),'.','Color',msred,'linewidth',3);

set(gca,'fontsize',16,'ytick',[-10,-5,0],'yticklabel',{'-10%','-5%','0%'}); ylim([-12,3]);
set(gca,'xtick',1:11,'xticklabel',{'MB','CS/US','Persev','Bias','MF','wsls: MB','wsls: MF','T-learn','HMM Model','Full Model','GLM'}); xlim([0.5,11.5])
ylabel('Change in Norm. Xval. Likelihood','Fontsize',16);
title('Change in Quality of Fit with Addition of Components','fontsize',20);
set(gcf,'position',[600,200,750,325])

