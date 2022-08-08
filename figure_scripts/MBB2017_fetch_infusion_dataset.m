%% Script to analyze infusion data
login_kevin

trial_limit = 400;

%% Define Rats and Dates
ratnames = {'M042','M052','M066','M067','M069','M054'};

hippo_dates1 = {'2014-10-06';'2014-10-13'};
nonhippo_dates1 = {'2014-10-05';'2014-10-07';'2014-10-12';'2014-10-14'};

hippo_dates2 =  {'2014-12-01';'2015-01-09';'2015-01-16';'2015-02-08';'2015-02-16'};
nonhippo_dates2 = {'2014-11-31';'2014-12-02';'2015-01-08';'2015-01-10';'2015-01-15';'2015-01-17';'2015-02-07';'2015-02-09';'2015-02-15';'2015-02-17'};
hippo_saline = {'1900-01-01';'2015-01-19';'2015-05-15'}; % The dummy date is in there because the parser treats pairs of dates as a range rather than a list
%
ofc_dates1 = {'2014-11-18';'2014-11-21';'2014-11-24'};
% Data from M054, M067 from the 23rd is bad data
nonofc_dates1 = {'2014-11-17';'2014-11-19';'2014-11-20';'2014-11-22';'2014-11-25'};

ofc_dates2 = {'2014-12-08';'2015-01-05';'2015-02-02'};
nonofc_dates2 = {'2014-12-07';'2014-12-09';'2015-01-04';'2015-01-06';'2015-02-01'};

ofc_dates3 = {'2015-02-27'};
nonofc_dates3 = {'2015-02-26'};
ofc_saline = {'2015-03-23'};
ofc_nonsaline = {'2015-03-22','2015-02-24'};

pl_dates = {'2014-12-05';'2015-01-12';'2015-03-02'};
nonpl_dates = {'2014-12-04';'2014-12-06';'2015-01-11';'2015-01-13';'2015-03-01';'2015-03-04'};
pl_saline = {'2015-05-19'};

all_saline = [hippo_saline;pl_saline;ofc_saline];
all_noninf = [nonhippo_dates1;nonhippo_dates2;nonofc_dates1;nonofc_dates3;nonpl_dates];

%% Gather datasets
data_saline_all = package_twostep_datas(ratnames, all_saline,50,trial_limit);
data_cntrl_all = package_twostep_datas(ratnames, all_noninf,50,trial_limit);

data_ofc = package_twostep_datas(ratnames, [ofc_dates1;ofc_dates3],50,trial_limit);
data_pl = package_twostep_datas(ratnames, pl_dates,50,trial_limit);
data_hippo = package_twostep_datas(ratnames, [hippo_dates1;hippo_dates2],50,trial_limit);

data_cntrl_ofc = package_twostep_datas(ratnames, [nonofc_dates1;nonofc_dates3],50,trial_limit);
data_cntrl_pl = package_twostep_datas(ratnames, nonpl_dates,50,trial_limit);
data_cntrl_hippo = package_twostep_datas(ratnames, [nonhippo_dates1;nonhippo_dates2],50,trial_limit);

data_saline_ofc = package_twostep_datas(ratnames, ofc_saline,50,trial_limit);
data_saline_pl = package_twostep_datas(ratnames, pl_saline,50,trial_limit);
data_saline_hippo = package_twostep_datas(ratnames, hippo_saline,50,trial_limit);

%% Save datasets

data.data_hippo = data_hippo;
data.data_pl = data_pl;
data.data_ofc = data_ofc;
data.data_saline_all = data_saline_all;
data.data_cntrl_all = data_cntrl_all;
data.data_cntrl_hippo = data_cntrl_hippo;
data.data_cntrl_pl = data_cntrl_pl;
data.data_cntrl_ofc = data_cntrl_ofc;
data.data_saline_ofc = data_saline_ofc;
data.data_saline_hippo = data_saline_hippo;
data.data_saline_pl = data_saline_pl;

% Rat #6 has no saline data - give him a blank dataset 
data_blank.task = 'TwoStep';
data_blank.p_congruent = 0.2;
data_blank.sides1 = ['r';'r'];
data_blank.sides2 = ['r';'r'];
data_blank.rewards = [1;0];
data_blank.nTrials = 2;
data.data_saline_all{6} = data_blank;
data.data_saline_ofc{6} = data_blank;
data.data_saline_hippo{6} = data_blank;
data.data_saline_pl{6} = data_blank;



