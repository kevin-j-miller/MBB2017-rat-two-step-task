function params_by_sess_trimmed = trim_sessions(params_by_sess)
    
    % Subfunction for aaron correlations
    params_by_sess_trimmed = params_by_sess;
    % First remove fits that have elements that are crazy (> +- 100)
    [crazy_xs,~] = find(abs(params_by_sess_trimmed) > 100);
    params_by_sess_trimmed(crazy_xs,:) = [];
    
    % Next remove fits that have elements that are more than five SD away
    zscores = zscore(params_by_sess_trimmed);
    [outlier_xs,~] = find(abs(zscores) >= 5);
    params_by_sess_trimmed(outlier_xs,:) = [];
end