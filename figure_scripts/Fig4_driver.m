load MBB2017_infusion_dataset
%% MB/MF indices scatter plot 
results = plot_infusion_scatter({dataset.data_hippo, dataset.data_ofc, dataset.data_saline_all},{msorange, mspurple, mslblue}); 

%% Persev plot

nRats = 6;
for rat_i = 1:nRats
    if rat_i ~= 6 % Rat 6 has no saline sessions
    results = twostep_glm(dataset.data_saline_ofc{rat_i},5,0);
    persevs_saline_ofc(rat_i) = results.persev_ind;
    
    results = twostep_glm(dataset.data_saline_hippo{rat_i},5,0);
    persevs_saline_hippo(rat_i) = results.persev_ind;
    else
        persevs_saline_ofc(rat_i) = NaN;
        persevs_saline_hippo(rat_i) = NaN;
        
    end
    

    results = twostep_glm(dataset.data_ofc{rat_i},5,0);
    persevs_ofc(rat_i) = results.persev_ind;
    
    results = twostep_glm(dataset.data_hippo{rat_i},5,0);
    persevs_hippo(rat_i) = results.persev_ind;
end
    

jit = 0.1;
jitter = (0:jit/(nRats-1):jit) - jit/2;
stag = 0.2;

% Persev plots for OFC, dH
ys = [persevs_saline_ofc', persevs_ofc', persevs_saline_hippo', persevs_hippo'];
xs = [repmat(1-stag,[nRats,1]) + jitter', repmat(1+stag,[nRats,1]) + jitter', repmat(2-stag,[nRats,1]) + jitter', repmat(2+stag,[nRats,1]) + jitter'];
colors = {mslblue,mspurple,mslblue,msred};

figure; hold on
plot(xs(:,1:2)',ys(:,1:2)','-','color','k')
plot(xs(:,3:4)',ys(:,3:4)','-','color','k')
for x_i = 1:4
    
scatter(xs(:,x_i),ys(:,x_i),100,'x','markeredgecolor',lighten(colors{x_i},0.5),'linewidth',2.5); 

end
errorbar(mean(xs),nanmean(ys),nansem(ys),'.','color','k','linewidth',4);
ylim([0,1.1*max(ys(:))]);
set(gca,'xtick',1:2,'xticklabels',{'OFC','dH'},'ytick',[0,4,8],'fontsize',16);
xlim([0.5,2.5])




%% Average and Example GLM output
nBack = 5;
example_rat = 1;
for rat_i = 1:6
    all_betas = [];
    
    if rat_i < 6
        results = twostep_glm(dataset.data_saline_all{rat_i},nBack,false); legend off
        betas_saline(rat_i,:) = results.betas;
    else
        betas_saline(rat_i,:) = NaN;
    end
    
    results = twostep_glm(dataset.data_hippo{rat_i},nBack,false); legend off
    betas_hippo(rat_i,:) = results.betas;
    
    results = twostep_glm(dataset.data_ofc{rat_i},nBack,false); legend off
    betas_ofc(rat_i,:) = results.betas;
    
end

ylims = [-1,1.9];
plot_pretty_glms(betas_saline,nBack); title('Saline','fontsize',40); legend off; ylim(ylims);
plot_pretty_glms(betas_hippo,nBack); title('dH','fontsize',40); legend off; ylim(ylims);
plot_pretty_glms(betas_ofc,nBack); title('OFC','fontsize',40); legend off; ylim(ylims);

twostep_glm(dataset.data_saline_all{example_rat},nBack); legend off; ylim(ylims);
twostep_glm(dataset.data_ofc{example_rat},nBack); legend off; ylim(ylims);
twostep_glm(dataset.data_hippo{example_rat},nBack); legend off; ylim(ylims);
