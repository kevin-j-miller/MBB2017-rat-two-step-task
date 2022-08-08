regions = {'OFC','dH','PL'};
params = {'pop_alphaMBlogit_delta_mean','pop_betaBonus_norm_delta_mean','pop_betaPersev_norm_delta_mean','pop_betaBias_delta_mean'};
param_names = {'Logit(\alpha_{plan})','Norm(\beta_{np})','Norm(\beta_{persev})','\beta_{bias}'};
ctrss = {(0:0.1:4) - 2; (0:0.025:1) - 0.5; (0:0.025:1) - 0.5; (0:0.025:1.5) - 0.75};
ts = [1,0.5,0.5,0.5];
loadstrs = {'fit_logAlpha_OFC_moreSamples.mat','fit_logAlpha_Hippo_moreSamples.mat','fit_logAlpha_PL_moreSamples'};
colors = {mspurple,msorange,dgreen};

%% Make the tradeoff plots
for region_i = 1:2
    

    load(loadstrs{region_i});

    
    ctrs{1} = (0:0.025:1.5) - 0.75; % For later hypothesis testing, it's important that zero be a bin edge, not within a bin
    
    
    samples = cat_stan_samples(fit_inf_extracted);
    nSamples = numel(samples.pop_betaMB_norm_delta_mean);
    
    samples_betaMB = -1*samples.pop_betaMB_norm_delta_mean;
    
    for param_i = 1
        
        samples_alt = getfield(samples,params{param_i});
        ctrs{2} = ctrss{param_i};
        
        
        [h,centers] = hist3([samples_betaMB, samples_alt],ctrs); %[nBins,nBins]);
        fractions = h/nSamples;
        f = figure; hold on
        image(centers{2},centers{1},fractions,'CDataMapping','scaled')
        cb = colorbar('xtick',0:0.005:1,'xticklabel',{'0%','0.05%','0.1%','0.15%','0.2%','0.25%','0.3%','0.35%'});
        line([0,0],[-5,5],'color',[0,0,0])
        line([-5,5],[0,0],'color',[0,0,0])
        
        xlim([centers{2}(1),centers{2}(end)]);
        ylim([centers{1}(1),centers{1}(end)]);
        caxis([0,max(fractions(:))])
        
        ylabel('Effect on Norm(\beta_{plan})','fontsize',30);
        xlabel(['Effect on ',param_names{param_i}],'fontsize',30);
        ylabel(cb,'Posterior Probability','fontsize',30);
        
        t = ts(param_i);
        set(gca,'fontsize',30,'xtick',(0:t:4)-2,'ytick',[-0.5,0,0.5]);
        
        for color_i = 1:100
            mymap(color_i,:) = lighten(colors{region_i},color_i/100);
        end
        
        colormap(mymap)
        
        
        
        
        mean(samples.pop_betaMB_norm_delta_mean < 0)
    end
end




