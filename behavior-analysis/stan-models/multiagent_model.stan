// STAN code for hierarchical version of multiagent model

// Contains:
// 1) Model-Based
//	1.5) Model-Based Learning
// 2) Model-Free
// 3) CS/US Bonus
// 4) WS/LS MB
// 5) WS/LS MF
// 6) Perseveration
// 7) Bias


data {
	int<lower=0> nRats;
	real<lower=0,upper=1> pCongs[nRats];
	
	int<lower=0> nTrials;
	int<lower=0,upper=nRats> rats[nTrials];
	int<lower=1,upper=2> choices[nTrials];
	int<lower=1,upper=2> outcomes[nTrials];
	int<lower=0,upper=1> rewards[nTrials];

	int<lower=0,upper=1> inc[8]; // Use this variable to include or exclude each of the various Q's. 
	
}


parameters {
	
	// 1) Model-Based
	real<lower=0, upper=1> pop_alphaMB_mean;
	real<lower=0>          pop_alphaMB_ss;
	real<lower=0, upper=1> alphaMB[nRats];
	
	real pop_betaMB_norm_mean;
	real<lower=0> pop_betaMB_norm_var;
	vector[nRats] betaMB;
	
	// 1.5) Model-based learning
	real<lower=0, upper=1> pop_alphaT_mean;
	real<lower=0>          pop_alphaT_ss;
	real<lower=0, upper=1> alphaT[nRats];
	
	// 2) Model-Free
	real<lower=0, upper=1> pop_alphaMF_mean;
	real<lower=0>          pop_alphaMF_ss;
	real<lower=0, upper=1> alphaMF[nRats];
	
	real<lower=0, upper=1> pop_lambda_mean;
	real<lower=0>          pop_lambda_ss;
	real<lower=0, upper=1> lambda[nRats];
	
	real pop_betaMF_norm_mean;
	real<lower=0> pop_betaMF_norm_var;
	vector[nRats] betaMF;
	
	// 3) CS/US Bonus
	real pop_betaBonus_norm_mean;
	real<lower=0> pop_betaBonus_norm_var;
	vector[nRats] betaBonus;
	
	// 4) WS/LS MB
	real pop_betaWslsMB_norm_mean;
	real<lower=0> pop_betaWslsMB_norm_var;
	vector[nRats] betaWslsMB;
	
	// 5) WS/LS MF
	real pop_betaWslsMF_norm_mean;
	real<lower=0> pop_betaWslsMF_norm_var;
	vector[nRats] betaWslsMF;
	
	// 6) Perseveration
	real pop_betaPersev_norm_mean;
	real<lower=0> pop_betaPersev_norm_var;
	vector[nRats] betaPersev;
	
	// 7) Bias
	real pop_betaBias_mean;
	real<lower=0> pop_betaBias_var;
	vector[nRats] betaBias;
	
}

transformed parameters {

	real log_probs[nRats];

	// Transformed parameters for each system
		
		// 1) Model-Based
		real pop_alphaMB_a;
		real pop_alphaMB_b;
		vector[nRats] betaMB_norm;
		// 1.5) Model-Based Learning
		real pop_alphaT_a;
		real pop_alphaT_b;
		// 2) Model-Free
		real pop_alphaMF_a;
		real pop_alphaMF_b;
		real pop_lambda_a;
		real pop_lambda_b;
		vector[nRats] betaMF_norm;
		// 3) CS/US Bonus
		vector[nRats] betaBonus_norm;
		// 4) WS/LS MB
		vector[nRats] betaWslsMB_norm;
		// 5) WS/LS MF
		vector[nRats] betaWslsMF_norm;
		// 6) Perseveration
		vector[nRats] betaPersev_norm;
		// 7) Bias
	
	// Transform the learning rates and lambda
	
		pop_alphaMB_a <- pop_alphaMB_mean * pop_alphaMB_ss;
		pop_alphaMB_b <- pop_alphaMB_ss - pop_alphaMB_a;
		pop_alphaT_a <- pop_alphaT_mean * pop_alphaT_ss;
		pop_alphaT_b <- pop_alphaT_ss - pop_alphaT_a;
		pop_alphaMF_a <- pop_alphaMF_mean * pop_alphaMF_ss;
		pop_alphaMF_b <- pop_alphaMF_ss - pop_alphaMF_a;
		pop_lambda_a <- pop_lambda_mean * pop_lambda_ss;
		pop_lambda_b <- pop_lambda_ss - pop_lambda_a;
		
	// Compute the log_prob
		log_probs <- rep_array(0,nRats);

		{
		// Internal value functions
		row_vector[2] q_eff;
		row_vector[2] q2_mb;
		row_vector[2] q1_mb;
		row_vector[2] q2_mf;
		row_vector[2] q1_mf;
		row_vector[2] q_bonus;
		row_vector[2] q_wslsMB;
		row_vector[2] q_wslsMF;
		row_vector[2] q_persev;
		row_vector[2] q_bias;
		matrix[2,2] T;
		
		// Other internal variables (helpers)
		int rat; // index of rat currently under consideration
		real pCong;
		int reward;
		int outcome;
		int nonoutcome;
		int choice;
		int nonchoice;
		int common;
		
		// Value function trackers
		real q1_mb_sum[nRats];
		real q1_mb_sum_sq[nRats];
		real q1_mf_sum[nRats];
		real q1_mf_sum_sq[nRats];
		real q_bonus_sum[nRats];
		real q_bonus_sum_sq[nRats];
		real q_WslsMB_sum[nRats];
		real q_WslsMB_sum_sq[nRats];
		real q_WslsMF_sum[nRats];
		real q_WslsMF_sum_sq[nRats];
		real q_persev_sum[nRats];
		real q_persev_sum_sq[nRats];
		
		int nTrials_rat[nRats];

		
		q1_mb_sum <- rep_array(0,nRats);
		q1_mb_sum_sq <- rep_array(0,nRats);
		q1_mf_sum <- rep_array(0,nRats);
		q1_mf_sum_sq <- rep_array(0,nRats);
		q_bonus_sum <- rep_array(0,nRats);
		q_bonus_sum_sq <- rep_array(0,nRats);
		q_WslsMB_sum <- rep_array(0,nRats);
		q_WslsMB_sum_sq <- rep_array(0,nRats);
		q_WslsMF_sum <- rep_array(0,nRats);
		q_WslsMF_sum_sq <- rep_array(0,nRats);
		q_persev_sum <- rep_array(0,nRats);
		q_persev_sum_sq <- rep_array(0,nRats);
	
		
		nTrials_rat  <- rep_array(0,nRats);
		
		// Compute the value functions
		rat <- 0;
		for (trial_i in 1:nTrials) {
			
			// Check if we need to move to the next rat
			if (rats[trial_i] != rat){
			// If we're on a new rat, reinitialize the values
			rat <- rats[trial_i];
			pCong <- pCongs[rat];
			q2_mb[1] <- 0.5; 				q2_mb[2] <- 0.5;
			q2_mf[1] <- 0.5; 				q2_mf[2] <- 0.5;
			q1_mf[1] <- 0.5; 				q1_mf[2] <- 0.5;
			q_bonus[1] <- 0.5;				q_bonus[2] <- 0.5;
			q_wslsMB[1] <- 0.5; 			q_wslsMB[2] <- 0.5;
			q_wslsMF[1] <- 0.5; 			q_wslsMF[2] <- 0.5;
			q_persev[1] <- 0.5;				q_persev[2] <- 0.5;
			q_bias[1] <- betaBias[rat];		q_bias[2] <- -1*betaBias[rat];		
			T[1,1] <- pCong; 		T[1,2] <- (1-pCong);
			T[2,1] <- (1-pCong); 	T[2,2] <- pCong;
			}
					
			// Compute MB values for step 1
			q1_mb[1] <- T[1,1]*q2_mb[1] + T[1,2]*q2_mb[2];
			q1_mb[2] <- T[2,1]*q2_mb[1] + T[2,2]*q2_mb[2];
			
			// Update var trackers
			q1_mb_sum[rat] <- q1_mb_sum[rat] + (q1_mb[1]);
			q1_mb_sum_sq[rat] <- q1_mb_sum_sq[rat] + (q1_mb[1])^2;
			
			q1_mf_sum[rat] <- q1_mf_sum[rat] + (q1_mf[1]);
			q1_mf_sum_sq[rat] <- q1_mf_sum_sq[rat] + (q1_mf[1])^2;
			
			q_bonus_sum[rat] <- q_bonus_sum[rat] + (q_bonus[1]);
			q_bonus_sum_sq[rat] <- q_bonus_sum_sq[rat] + (q_bonus[1])^2;
			
			q_WslsMB_sum[rat] <- q_WslsMB_sum[rat] + (q_wslsMB[1]);
			q_WslsMB_sum_sq[rat] <- q_WslsMB_sum_sq[rat] + (q_wslsMB[1])^2;
			
			q_WslsMF_sum[rat] <- q_WslsMF_sum[rat] + (q_wslsMF[1]);
			q_WslsMF_sum_sq[rat] <- q_WslsMF_sum_sq[rat] + (q_wslsMF[1])^2;
			
			q_persev_sum[rat] <- q_persev_sum[rat] + (q_persev[1]);
			q_persev_sum_sq[rat] <- q_persev_sum_sq[rat] + (q_persev[1])^2;
		
			nTrials_rat[rat] <- nTrials_rat[rat] + 1;
		
			// Compute log_prob for this trial
			q_eff <- betaMB[rat]*q1_mb*inc[1] + betaMF[rat]*q1_mf*inc[2] + betaBonus[rat]*q_bonus*inc[3] + betaWslsMB[rat]*q_wslsMB*inc[4] + betaWslsMF[rat]*q_wslsMF*inc[5] + betaPersev[rat]*q_persev*inc[6] + q_bias*inc[7];
			log_probs[rat] <- log_probs[rat] + categorical_log(choices[trial_i] , softmax(to_vector(q_eff)));
			
			// Do the learning
			outcome <- outcomes[trial_i];
			nonoutcome <- 3 - outcome; // convert 2's into 1's, 1's into 2's 

			choice <- choices[trial_i];
			nonchoice <- 3 - choice;
			
			reward <- rewards[trial_i];
			
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
			q2_mb[outcome] <- q2_mb[outcome] + alphaMB[rat]*(reward - q2_mb[outcome]);
			q2_mb[nonoutcome] <- q2_mb[nonoutcome] + alphaMB[rat]*(1 - reward - q2_mb[nonoutcome]);
			
			// T learning
			
			if (inc[8] == 1){
			T[choice,outcome] <- T[choice,outcome]*(1-alphaT[rat]) + alphaT[rat];
			T[choice,nonoutcome] <- T[choice,nonoutcome]*(1-alphaT[rat]);
			}
			
			// MF Learning
			q2_mf[outcome] <- q2_mf[outcome] + alphaMF[rat]*(reward - q2_mf[outcome]);
			q2_mf[nonoutcome] <- q2_mf[nonoutcome] + alphaMF[rat]*(1 - reward - q2_mf[nonoutcome]);
			
			q1_mf[outcome] <- q1_mf[outcome] + alphaMF[rat]*(q2_mf[outcome] - q1_mf[outcome]) + alphaMF[rat]*lambda[rat]*(reward - q2_mf[outcome]);
			
			// Bonus Learning
			if (common == 1) {
			q_bonus[choice]<- 1;	q_bonus[nonchoice] <- 0;
			}
			else {
			q_bonus[choice]<- 0;	q_bonus[nonchoice] <- 1;
			}
			
			// WSLS learning
			if (reward==1) {
				q_wslsMF[choice] <- 1;  q_wslsMF[nonchoice] <- 0;
				if (common==1) {
					q_wslsMB[choice] <- 1;  q_wslsMB[nonchoice] <- 0;
				}
				else {
					q_wslsMB[choice] <- 0;  q_wslsMB[nonchoice] <- 1;
				}				
			}
			else {
				q_wslsMF[choice] <- 0;  q_wslsMF[nonchoice] <- 1;
				if (common==1) {
					q_wslsMB[choice] <- 0;  q_wslsMB[nonchoice] <- 1;
				}
				else {
					q_wslsMB[choice] <- 1;  q_wslsMB[nonchoice] <- 0;
				}
			}
			
			// Persev learning
			q_persev[choice]<- 1;	q_persev[nonchoice] <- 0;
			
		}
		
		// Calculate VAR

		{
			vector[nRats] qSTD_mb;
			vector[nRats] qSTD_mf;
			vector[nRats] qSTD_bonus;
			vector[nRats] qSTD_WslsMB;
			vector[nRats] qSTD_WslsMF;
			vector[nRats] qSTD_persev;
			
			for (rat_i in 1:nRats) {
			qSTD_mb[rat_i] <- sqrt((q1_mb_sum_sq[rat_i] - q1_mb_sum[rat_i]^2/nTrials_rat[rat_i])/(nTrials_rat[rat_i]-1));
			qSTD_mf[rat_i] <- sqrt((q1_mf_sum_sq[rat_i] - q1_mf_sum[rat_i]^2/nTrials_rat[rat_i])/(nTrials_rat[rat_i]-1));
			qSTD_bonus[rat_i] <- sqrt((q_bonus_sum_sq[rat_i] - q_bonus_sum[rat_i]^2/nTrials_rat[rat_i])/(nTrials_rat[rat_i]-1));
			qSTD_WslsMB[rat_i] <- sqrt((q_WslsMB_sum_sq[rat_i] - q_WslsMB_sum[rat_i]^2/nTrials_rat[rat_i])/(nTrials_rat[rat_i]-1));
			qSTD_WslsMF[rat_i] <- sqrt((q_WslsMF_sum_sq[rat_i] - q_WslsMF_sum[rat_i]^2/nTrials_rat[rat_i])/(nTrials_rat[rat_i]-1));
			qSTD_persev[rat_i] <- sqrt((q_persev_sum_sq[rat_i] - q_persev_sum[rat_i]^2/nTrials_rat[rat_i])/(nTrials_rat[rat_i]-1));
			}

		// Normalize Betas by Standard Deviation
		betaMB_norm <- betaMB .* qSTD_mb;
		betaMF_norm <- betaMF .* qSTD_mf;
		betaBonus_norm <- betaBonus .* qSTD_bonus;
		betaWslsMB_norm <- betaWslsMB .* qSTD_WslsMB;
		betaWslsMF_norm <- betaWslsMF .* qSTD_WslsMF;
		betaPersev_norm <- betaPersev .* qSTD_persev;
		}
}
}

model {

	// Population priors
		// 1) Model-Based
		pop_alphaMB_mean ~ beta(3,3);
		pop_alphaMB_ss ~ normal(10,10);
		alphaMB ~ beta(3,3);
		
		pop_betaMB_norm_mean ~ normal(0,5);
		pop_betaMB_norm_var ~ cauchy(0,2.5);			
		
		// 1.5) MB T learning
		pop_alphaT_mean ~ beta(1,1);
		pop_alphaT_ss ~ normal(10,10);
		
		// 2) Model-Free
		pop_alphaMF_mean ~ beta(3,3);
		pop_alphaMF_ss ~ normal(10,10);
		alphaMF ~ beta(3,3);
		
		pop_lambda_mean ~ beta(3,3);
		pop_lambda_ss ~ normal(10,10);
		lambda ~ beta(3,3);
		
		pop_betaMF_norm_mean ~ normal(0,5);
		pop_betaMF_norm_var ~ cauchy(0,2.5);
		
		// 3) CS/US Bonus
		pop_betaBonus_norm_mean ~ normal(0,5);
		pop_betaBonus_norm_var ~ cauchy(0,2.5);
		
		// 4) WS/LS MB
		pop_betaWslsMB_norm_mean ~ normal(0,5);
		pop_betaWslsMB_norm_var ~ cauchy(0,2.5);
		
		// 5) WS/LS MF
		pop_betaWslsMF_norm_mean ~ normal(0,5);
		pop_betaWslsMF_norm_var ~ cauchy(0,2.5);
		
		// 6) Perseveration
		pop_betaPersev_norm_mean ~ normal(0,5);
		pop_betaPersev_norm_var ~ cauchy(0,2.5);
		
		// 7) Bias
		pop_betaBias_mean ~ normal(0,5);
		pop_betaBias_var ~ cauchy(0,2.5);
		
	// Draw subject parameters
		// 1) Model-Based
		alphaMB ~ beta(pop_alphaMB_a,pop_alphaMB_b);
		alphaT ~ beta(pop_alphaT_a,pop_alphaT_b);
		betaMB_norm ~ normal(pop_betaMB_norm_mean, pop_betaMB_norm_var);
		// 2) Model-Free
		alphaMF ~ beta(pop_alphaMF_a,pop_alphaMF_b);
		lambda ~ beta(pop_lambda_a,pop_lambda_b);
		betaMF_norm ~ normal(pop_betaMF_norm_mean, pop_betaMF_norm_var);
		// 3) CS/US Bonus
		betaBonus_norm ~ normal(pop_betaBonus_norm_mean, pop_betaBonus_norm_var);
		// 4) WS/LS MB
		betaWslsMB_norm ~ normal(pop_betaWslsMB_norm_mean, pop_betaWslsMB_norm_var);
		// 5) WS/LS MF
		betaWslsMF_norm ~ normal(pop_betaWslsMF_norm_mean, pop_betaWslsMF_norm_var);
		// 6) Perseveration
		betaPersev_norm ~ normal(pop_betaPersev_norm_mean, pop_betaPersev_norm_var);
		// 7) Bias
		betaBias ~ normal(pop_betaBias_mean, pop_betaBias_var);
		
	// Data likelihood
	increment_log_prob(sum(log_probs));
	

}