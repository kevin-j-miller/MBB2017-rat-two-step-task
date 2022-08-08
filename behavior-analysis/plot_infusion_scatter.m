function results = plot_infusion_scatter(datasets, colors)

figure; hold on; 

for dataset_i = 1:length(datasets)
    
    dataset = datasets{dataset_i};
    for rat_i = 1:length(dataset)
        ratdata = dataset{rat_i};
        if isempty(ratdata)
            mb_raw(rat_i) = NaN;
            mf_raw(rat_i) = NaN;
            continue
        end
        
        
        stats = get_stats(ratdata);
        
        mb_raw(rat_i) = stats.mb_raw;
        mf_raw(rat_i) = stats.mf_raw;
    end
    color = colors{dataset_i};
    light_color = lighten(color,0.5);
    scatter(mb_raw,mf_raw,100,'x','MarkerEdgeColor',light_color,'LineWidth',2.5);
    line([nanmean(mb_raw) - nansem(mb_raw),nanmean(mb_raw) + nansem(mb_raw)],[nanmean(mf_raw),nanmean(mf_raw)],'color',color,'LineWidth',3.5);
    line([nanmean(mb_raw),nanmean(mb_raw)],[nanmean(mf_raw) - nansem(mf_raw),nanmean(mf_raw)+nansem(mf_raw)],'color',color,'LineWidth',3.5);
    mb_raw_all(dataset_i,:) = mb_raw;
    mf_raw_all(dataset_i,:) = mf_raw;
end

results.mb = mb_raw_all;
results.mf = mf_raw_all;

mb_clean = mb_raw_all(:,~any(isnan(mb_raw_all)));
mf_clean = mf_raw_all(:,~any(isnan(mf_raw_all)));

[~,results.p_mb] = ttest2(mb_clean(1,:),mb_clean(end,:));
[results.p_mb_sr,~] = signrank(mb_clean(1,:) - mb_clean(end,:));
[~,results.p_mf] = ttest2(mf_clean(1,:),mf_clean(end,:));

xlim([-1,8]); ylim([-1,8]);
xlabel('Model-Based Index','FontSize',20); ylabel('Model-Free Index','FontSize',20);
line([-10,10],[-10,10],'Color',[0.5,0.5,0.5]);
set(gca,'FontSize',26);


function results = get_stats(ratdata)
        if isempty(ratdata) || length(ratdata.rewards) < 100
            results.mb_norm = NaN;
            results.mb_raw = NaN;
            results.mf_norm = NaN;
            results.mf_raw = NaN;
            results.perf = NaN;
            results.nTrials = NaN;
        else
            glm_results = twostep_glm(ratdata,3,0);
            results.mb_norm = glm_results.mb_ind / sum(abs(glm_results.betas(2:end)));
            results.mb_raw = glm_results.mb_ind;
            results.mf_norm = glm_results.mf_ind / sum(abs(glm_results.betas(2:end)));
            results.mf_raw = glm_results.mf_ind;
            results.perf = nanmean(ratdata.better_choices);
            results.nTrials = length(ratdata.rewards);
        end
end
    
end