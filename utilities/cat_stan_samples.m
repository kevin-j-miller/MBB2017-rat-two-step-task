function fit_extracted_catted = cat_stan_samples(fit_extracted)

%% Utility function to concatenate samples from different chains in a fit_extracted object

nChains = length(fit_extracted);
fields = fieldnames(fit_extracted);
nFields = length(fields);

for field_i = 1:nFields
    field = fields{field_i};
    vals = [];
    
    for chain_i = 1:nChains
        
    vals = [vals; fit_extracted(chain_i).(field)];    
        
    end
    
    fit_extracted_catted.(field) = vals;
end



end