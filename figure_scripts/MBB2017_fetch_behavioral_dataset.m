function twostep_datas = fetch_twostep_data


login_kevin;
[ratnames, startdates,enddates] =  bdata('SELECT ratname, startdate, enddate FROM kjmiller.twostep_dataset_10_2');


nRats = length(ratnames);
twostep_datas = cell(1,nRats);


for rat_i = 1:nRats
    
    ratname = ratnames{rat_i};
        startdate = startdates{rat_i};
    if ~isempty(enddates{rat_i})
        enddate = enddates{rat_i};
    else
        enddate = datestr(today,29); % If there is no enddate specified, the rat is still running, and today is the enddate
    end
   
    ratdata = package_twostep(ratname, {startdate; enddate},100); % only take sessions with at least 100 trials
    ratdata.ratname = ratname;
    twostep_datas{rat_i} = ratdata;
    
end

end
