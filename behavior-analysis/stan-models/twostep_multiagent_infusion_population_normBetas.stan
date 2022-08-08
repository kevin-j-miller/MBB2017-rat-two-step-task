// STAN code for population infusion data for the two-step task

data {
	int<lower=0> nRats;
	
	real<lower=0,upper=1> pCongs[nRats];
	
	int<lower=0> nTrials_cntrl;
	int<lower=0,upper=nRats> rats_cntrl[nTrials_cntrl];
	int<lower=1,upper=2> choices_cntrl[nTrials_cntrl];
	int<lower=1,upper=2> outcomes_cntrl[nTrials_cntrl];
	int<lower=0,upper=1> rewards_cntrl[nTrials_cntrl];

	int<lower=0> nTrials_inf;
	int<lower=0,upper=nRats> rats_inf[nTrials_inf];
	int<lower=1,upper=2> choices_inf[nTrials_inf];
	int<lower=1,upper=2> outcomes_inf[nTrials_inf];
	int<lower=0,upper=1> rewards_inf[nTrials_inf];	
}

transformed data {

int nTrials_tot; 
nTrials_tot <-  nTrials_cntrl + nTrials_inf;

}

parameters {
	
	// Learning Rate
	real<lower=0, upper=1> pop_alphaMB_mean_cntrl;    
	real<lower=0>          pop_alphaMB_ss_cntrl;
	real<lower=0, upper=1> alphaMB_cntrl[nRats];
	
	// Delta Learning Rate
	real pop_alphaMB_delta_mean;    
	real<lower=0>          pop_alphaMB_delta_var;
	
	vector[nRats] alphaMB_delta;
	
	// Un-normalized betas
	vector[nRats] betaMB_cntrl;
	vector[nRats] betaBonus_cntrl;
	vector[nRats] betaPersev_cntrl;
	vector[nRats] betaBias_cntrl;
	
	vector[nRats] betaMB_delta;
	vector[nRats] betaBonus_delta;
	vector[nRats] betaPersev_delta;
	vector[nRats] betaBias_delta;
	
	// Normalized pop betas
	real pop_betaMB_norm_mean_cntrl;
	real<lower=0> pop_betaMB_norm_var_cntrl;
	real pop_betaMB_norm_delta_mean;
	real<lower=0> pop_betaMB_norm_delta_var;
	real pop_betaBonus_norm_mean_cntrl;
	real<lower=0> pop_betaBonus_norm_var_cntrl;
	real pop_betaBonus_norm_delta_mean;
	real<lower=0> pop_betaBonus_norm_delta_var;
	real pop_betaPersev_norm_mean_cntrl;
	real<lower=0> pop_betaPersev_norm_var_cntrl;
	real pop_betaPersev_norm_delta_mean;
	real<lower=0> pop_betaPersev_norm_delta_var;
	
	real pop_betaBias_mean_cntrl;
	real<lower=0> pop_betaBias_var_cntrl;
	real pop_betaBias_delta_mean;
	real<lower=0> pop_betaBias_delta_var;
	
}

transformed parameters {

	// Log Prob
	real log_prob;

    // Transformed learning rate parameters
	real pop_alphaMB_a_cntrl;
	real pop_alphaMB_b_cntrl;
	vector[nRats] alphaMB_inf;
	
	// Transformed betas
	vector[nRats] betaMB_inf;
	vector[nRats] betaBonus_inf;
	vector[nRats] betaPersev_inf;
	vector[nRats] betaBias_inf;
	
	
	// Normalized Betas
	vector[nRats] betaMB_norm_cntrl;
	vector[nRats] betaBonus_norm_cntrl;
	vector[nRats] betaPersev_norm_cntrl;
	vector[nRats] betaMB_norm_inf;
	vector[nRats] betaBonus_norm_inf;
	vector[nRats] betaPersev_norm_inf;
	
	// Transform the parameters
	pop_alphaMB_a_cntrl <- pop_alphaMB_mean_cntrl * pop_alphaMB_ss_cntrl;
	pop_alphaMB_b_cntrl <- pop_alphaMB_ss_cntrl - pop_alphaMB_a_cntrl;
	
	// Fancy transformation - put alpha into the logit space, apply the delta there, bring it back into alpha space
	// STAN is not smart enough to vectorize this. Will have to loop it.
	for (rat_i in 1:nRats){
	alphaMB_inf[rat_i] <- 1 / (1 + exp(-1*(log(alphaMB_cntrl[rat_i]/(1-alphaMB_cntrl[rat_i])) + alphaMB_delta[rat_i]))); 
	}
	
	betaMB_inf <- betaMB_cntrl + betaMB_delta;
	betaBonus_inf <- betaBonus_cntrl + betaBonus_delta;
	betaPersev_inf <- betaPersev_cntrl + betaPersev_delta;
	betaBias_inf <- betaBias_cntrl + betaBias_delta;
	
	// Calculate the value functions
	log_prob <- 0;
	
	// Run the model for CNTRL
{
	// Internal value functions
	row_vector[2] q_eff;
	row_vector[2] q2_mb;
	row_vector[2] q1_mb;
	row_vector[2] q_bonus;
	row_vector[2] q_persev;
	row_vector[2] q_bias;
	
	// Other internal variables (helpers)
	int rat; // index of rat currently under consideration
	real pCong;
	int outcome;
	int nonoutcome;
	int choice;
	int nonchoice;
	int common;
	int nTrials_cntrl_rat[nRats];
	int nTrials_inf_rat[nRats];
	
	// Value function trackers
	real q1_mb_sum_cntrl[nRats];
	real q1_mb_sum_sq_cntrl[nRats];
	real q_bonus_sum_cntrl[nRats];
	real q_bonus_sum_sq_cntrl[nRats];
	real q_persev_sum_cntrl[nRats];
	real q_persev_sum_sq_cntrl[nRats];
	
	real q1_mb_sum_inf[nRats];
	real q1_mb_sum_sq_inf[nRats];
	real q_bonus_sum_inf[nRats];
	real q_bonus_sum_sq_inf[nRats];
	real q_persev_sum_inf[nRats];
	real q_persev_sum_sq_inf[nRats];
	
	q1_mb_sum_cntrl <- rep_array(0,nRats);
	q1_mb_sum_sq_cntrl <- rep_array(0,nRats);
	q_bonus_sum_cntrl <- rep_array(0,nRats);
	q_bonus_sum_sq_cntrl <- rep_array(0,nRats);
	q_persev_sum_cntrl <- rep_array(0,nRats);
	q_persev_sum_sq_cntrl <- rep_array(0,nRats);
	
	q1_mb_sum_inf <- rep_array(0,nRats);
	q1_mb_sum_sq_inf <- rep_array(0,nRats);
	q_bonus_sum_inf <- rep_array(0,nRats);
	q_bonus_sum_sq_inf <- rep_array(0,nRats);
	q_persev_sum_inf <- rep_array(0,nRats);
	q_persev_sum_sq_inf <- rep_array(0,nRats);
	
	nTrials_cntrl_rat  <- rep_array(0,nRats);
	nTrials_inf_rat  <- rep_array(0,nRats);
	
	// Compute the value functions
	rat <- 0;
	for (trial_i in 1:nTrials_cntrl) {
		
		// Check if we need to move to the next rat
		if (rats_cntrl[trial_i] != rat){
		// If we're on a new rat, reinitialize the values
		rat <- rats_cntrl[trial_i];
		pCong <- pCongs[rat];
		q2_mb[1] <- 0.5; 				q2_mb[2] <- 0.5;
		q_bonus[1] <- 0.5;				q_bonus[2] <- 0.5;
		q_persev[1] <- 0.5;				q_persev[2] <- 0.5;
		q_bias[1] <- betaBias_cntrl[rat];	q_bias[2] <- -1*betaBias_cntrl[rat];		
		}
				
		// Probability of choice
		q1_mb[1] <- pCong*q2_mb[1] + (1-pCong)*q2_mb[2];
		q1_mb[2] <- (1-pCong)*q2_mb[1] + pCong*q2_mb[2];
		
		// Update val trackers
		q1_mb_sum_cntrl[rat] <- q1_mb_sum_cntrl[rat] + q1_mb[1];
		q1_mb_sum_sq_cntrl[rat] <- q1_mb_sum_sq_cntrl[rat] + (q1_mb[1])^2;
		q_bonus_sum_cntrl[rat] <- q_bonus_sum_cntrl[rat] + q_bonus[1];
		q_bonus_sum_sq_cntrl[rat] <- q_bonus_sum_sq_cntrl[rat] + (q_bonus[1])^2;
		q_persev_sum_cntrl[rat] <- q_persev_sum_cntrl[rat] + q_persev[1];
		q_persev_sum_sq_cntrl[rat] <- q_persev_sum_sq_cntrl[rat] + (q_persev[1])^2;
		nTrials_cntrl_rat[rat] <- nTrials_cntrl_rat[rat] + 1;
		
		q_eff <- betaMB_cntrl[rat]*q1_mb + betaBonus_cntrl[rat]*q_bonus + betaPersev_cntrl[rat]*q_persev + q_bias;
		log_prob <- log_prob + categorical_log(choices_cntrl[trial_i],softmax(to_vector(q_eff)));
		
		// Set up variables learning will need
		outcome <- outcomes_cntrl[trial_i];
		nonoutcome <- 3 - outcome; // convert 2's into 1's, 1's into 2's 

		choice <- choices_cntrl[trial_i];
		nonchoice <- 3 - choice;
		
		if (pCong > 0.5) {
			if (choice == outcome) {
				common <- 1;
			}
			else {
				common <- 0;
			}
		}
		else {
			if (choice == outcome) {
				common <- 0;
			}
			else {
				common <- 1;
			}
		}
		
		// MB learning
		q2_mb[outcome] <- q2_mb[outcome] + alphaMB_cntrl[rat]*(rewards_cntrl[trial_i] - q2_mb[outcome]);
		q2_mb[nonoutcome] <- q2_mb[nonoutcome] + alphaMB_cntrl[rat]*(1 - rewards_cntrl[trial_i] - q2_mb[nonoutcome]);
		
		// Bonus Learning
		if (common == 1) {
		q_bonus[choice]<- 1;	q_bonus[nonchoice] <- 0;
		}
		else {
		q_bonus[choice]<- 0;	q_bonus[nonchoice] <- 1;
		}
		
		// Persev learning
		q_persev[choice]<- 1;	q_persev[nonchoice] <- 0;
		
		
	}
	
	
	// Run the model for INFUSION
	rat <- 0;
	for (trial_i in 1:nTrials_inf) {
		// Check if we need to move to the next rat
		if (rats_inf[trial_i] != rat){
		// If we're on a new rat, reinitialize the values
		rat <- rats_inf[trial_i];
		pCong <- pCongs[rat];
		q2_mb[1] <- 0.5; 				q2_mb[2] <- 0.5;
		q_bonus[1] <- 0.5;				q_bonus[2] <- 0.5;
		q_persev[1] <- 0.5;				q_persev[2] <- 0.5;
		q_bias[1] <- betaBias_inf[rat];	q_bias[2] <- -1*betaBias_inf[rat];		
		}
				
		// Probability of choice
		q1_mb[1] <- pCong*q2_mb[1] + (1-pCong)*q2_mb[2];
		q1_mb[2] <- (1-pCong)*q2_mb[1] + pCong*q2_mb[2];
		
		// Update val trackers
		q1_mb_sum_inf[rat] <- q1_mb_sum_inf[rat] + q1_mb[1];
		q1_mb_sum_sq_inf[rat] <- q1_mb_sum_sq_inf[rat] + (q1_mb[1])^2;
		q_bonus_sum_inf[rat] <- q_bonus_sum_inf[rat] + q_bonus[1];
		q_bonus_sum_sq_inf[rat] <- q_bonus_sum_sq_inf[rat] + (q_bonus[1])^2;
		q_persev_sum_inf[rat] <- q_persev_sum_inf[rat] + q_persev[1];
		q_persev_sum_sq_inf[rat] <- q_persev_sum_sq_inf[rat] + (q_persev[1])^2;
		nTrials_inf_rat[rat] <- nTrials_inf_rat[rat] + 1;
		
		q_eff <- betaMB_inf[rat]*q1_mb + betaBonus_inf[rat]*q_bonus + betaPersev_inf[rat]*q_persev + q_bias;
		log_prob <- log_prob + categorical_log(choices_inf[trial_i] , softmax(to_vector(q_eff)));
		
		// Set up variables learning will need
		outcome <- outcomes_inf[trial_i];
		nonoutcome <- 3 - outcome; // convert 2's into 1's, 1's into 2's 

		choice <- choices_inf[trial_i];
		nonchoice <- 3 - choice;
		
		if (pCong > 0.5) {
			if (choice == outcome) {
				common <- 1;
			}
			else {
				common <- 0;
			}
		}
		else {
			if (choice == outcome) {
				common <- 0;
			}
			else {
				common <- 1;
			}
		}
		
		// MB learning
		q2_mb[outcome] <- q2_mb[outcome] + alphaMB_inf[rat]*(rewards_inf[trial_i] - q2_mb[outcome]);
		q2_mb[nonoutcome] <- q2_mb[nonoutcome] + alphaMB_inf[rat]*(1 - rewards_inf[trial_i] - q2_mb[nonoutcome]);
		
		// Bonus Learning
		if (common == 1) {
		q_bonus[choice]<- 1;	q_bonus[nonchoice] <- 0;
		}
		else {
		q_bonus[choice]<- 0;	q_bonus[nonchoice] <- 1;
		}
		
		// Persev learning
		q_persev[choice]<- 1;	q_persev[nonchoice] <- 0;
		
		
	}
	
	{
	vector[nRats] qSTD_mb_cntrl;
	vector[nRats] qSTD_bonus_cntrl;
	vector[nRats] qSTD_persev_cntrl;
	vector[nRats] qSTD_mb_inf;
	vector[nRats] qSTD_bonus_inf;
	vector[nRats] qSTD_persev_inf;
	

	// Calculate VAR
	for (rat_i in 1:nRats) {
	qSTD_mb_cntrl[rat_i] <- sqrt((q1_mb_sum_sq_cntrl[rat_i] - q1_mb_sum_cntrl[rat_i]^2/nTrials_cntrl_rat[rat_i])/(nTrials_cntrl_rat[rat_i]-1));
	qSTD_bonus_cntrl[rat_i] <- sqrt((q_bonus_sum_sq_cntrl[rat_i] - q_bonus_sum_cntrl[rat_i]^2/nTrials_cntrl_rat[rat_i])/(nTrials_cntrl_rat[rat_i]-1));
	qSTD_persev_cntrl[rat_i] <- sqrt((q_persev_sum_sq_cntrl[rat_i] - q_persev_sum_cntrl[rat_i]^2/nTrials_cntrl_rat[rat_i])/(nTrials_cntrl_rat[rat_i]-1));
	
	qSTD_mb_inf[rat_i] <- sqrt((q1_mb_sum_sq_inf[rat_i] - q1_mb_sum_inf[rat_i]^2/nTrials_inf_rat[rat_i])/(nTrials_inf_rat[rat_i]-1));
	qSTD_bonus_inf[rat_i] <- sqrt((q_bonus_sum_sq_inf[rat_i] - q_bonus_sum_inf[rat_i]^2/nTrials_inf_rat[rat_i])/(nTrials_inf_rat[rat_i]-1));
	qSTD_persev_inf[rat_i] <- sqrt((q_persev_sum_sq_inf[rat_i] - q_persev_sum_inf[rat_i]^2/nTrials_inf_rat[rat_i])/(nTrials_inf_rat[rat_i]-1));
	}

	// Normalize Betas by Standard Deviation
	betaMB_norm_cntrl <- betaMB_cntrl .* qSTD_mb_cntrl;
	betaBonus_norm_cntrl <- betaBonus_cntrl .* qSTD_bonus_cntrl;
	betaPersev_norm_cntrl <- betaPersev_cntrl .* qSTD_persev_cntrl;
	betaMB_norm_inf <- betaMB_inf .* qSTD_mb_inf;
	betaBonus_norm_inf <- betaBonus_inf .* qSTD_bonus_inf;
	betaPersev_norm_inf <- betaPersev_inf .* qSTD_persev_inf;
	}

	}
}

model {
	
	// Local Params
	vector[nRats] betaMB_norm_delta;
	vector[nRats] betaBonus_norm_delta;
	vector[nRats] betaPersev_norm_delta;
	
	// Priors
	pop_alphaMB_ss_cntrl ~ normal(10,10);
	pop_alphaMB_mean_cntrl ~ beta(1,1);
		
	pop_alphaMB_delta_mean ~ normal(0,5);
	pop_alphaMB_delta_var ~ cauchy(0,2.5);
	
	// Priors on norm params
	pop_betaMB_norm_mean_cntrl ~ normal(0,5);
	pop_betaMB_norm_var_cntrl ~ cauchy(0,2.5);	
	pop_betaBonus_norm_mean_cntrl ~ normal(0,5);
	pop_betaBonus_norm_var_cntrl ~ cauchy(0,2.5);
	pop_betaPersev_norm_mean_cntrl ~ normal(0,5);
	pop_betaPersev_norm_var_cntrl ~ cauchy(0,2.5);
	
	pop_betaMB_norm_delta_mean ~ normal(0,5);
	pop_betaMB_norm_delta_var ~ cauchy(0,2.5);
	pop_betaBonus_norm_delta_mean ~ normal(0,5);
	pop_betaBonus_norm_delta_var ~ cauchy(0,2.5);
	pop_betaPersev_norm_delta_mean ~ normal(0,5);
	pop_betaPersev_norm_delta_var ~ cauchy(0,2.5);

	pop_betaBias_mean_cntrl ~ normal(0,5);
	pop_betaBias_var_cntrl ~ cauchy(0,2.5);
	
	pop_betaBias_delta_mean ~ normal(0,5);
	pop_betaBias_delta_var ~ cauchy(0,2.5);

	// Parameters
	// Learning rate
	alphaMB_cntrl ~ beta(pop_alphaMB_a_cntrl,pop_alphaMB_b_cntrl);
	alphaMB_delta ~ normal(pop_alphaMB_delta_mean,pop_alphaMB_delta_var);
	
	// Normalized betas
	betaMB_norm_delta <- betaMB_norm_cntrl - betaMB_norm_inf;
	betaBonus_norm_delta <- betaBonus_norm_cntrl - betaBonus_norm_inf;
	betaPersev_norm_delta <- betaPersev_norm_cntrl - betaPersev_norm_inf;
	
	betaMB_norm_cntrl      ~ normal(pop_betaMB_norm_mean_cntrl,     pop_betaMB_norm_var_cntrl);
	betaBonus_norm_cntrl   ~ normal(pop_betaBonus_norm_mean_cntrl,  pop_betaBonus_norm_var_cntrl);
	betaPersev_norm_cntrl  ~ normal(pop_betaPersev_norm_mean_cntrl, pop_betaPersev_norm_var_cntrl);
	betaMB_norm_delta ~ normal(pop_betaMB_norm_delta_mean,pop_betaMB_norm_delta_var);
	betaBonus_norm_delta ~ normal(pop_betaBonus_norm_delta_mean,pop_betaBonus_norm_delta_var);
	betaPersev_norm_delta ~ normal(pop_betaPersev_norm_delta_mean,pop_betaPersev_norm_delta_var);
	
	betaBias_cntrl  ~ normal(pop_betaBias_mean_cntrl, pop_betaBias_var_cntrl);
	betaBias_delta ~ normal(pop_betaBias_delta_mean,pop_betaBias_delta_var);
	
	
	increment_log_prob(log_prob);
}	