function ratdata_truncated = truncate_ratdata(ratdata, trial_limit)
% Takes the ratdata in ratdata, removes all but the first trial_limit
% trials

nTrials = length(ratdata.rewards);

if nTrials <= trial_limit
    ratdata.nTrials = nTrials;
    ratdata_truncated = ratdata;
    return
else

% Get a list of the field names
fnames = fieldnames(ratdata);
nFields = length(fnames);
ratdata_truncated = struct;
% Fieldnames
    for field_i = 1:nFields
        field_name = fnames{field_i};
        field_data = getfield(ratdata,field_name);
        
        if length(field_data) == nTrials % This is a field we should divide           field_data_sub = field_data(sess_inds);
            ratdata_truncated = setfield(ratdata_truncated,field_name,field_data(1:trial_limit));
        else % This field does not contain trial-by-trial data - just copy it
            ratdata_truncated = setfield(ratdata_truncated,field_name,field_data);
        end
        
    end
    
    % Now let's handle the nTrials field
    ratdata_truncated = setfield(ratdata_truncated,'nTrials',trial_limit);
end

end