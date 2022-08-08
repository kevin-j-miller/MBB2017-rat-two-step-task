function modeldata = generative_modelBased(alpha,beta,task)

if ~isfield(task,'transition_prob')
    pCong = 0.2;
    pIncong = 0.8;
else
    pCong = task.p_congruent;
    pIncong = 1-pCong;
end

% Generate simulated data using TD learning and model-based decision criteria given a set of
% reward probabilities 

Q2 = [0.5,0.5]; % Initialize q-values to 0.5.  These are *second-step* Q-values
nTrials = length(task.leftprobs);
rewards = NaN(nTrials,1);

for trial_i = 1:nTrials
   
    %% Figure out the model's choice given Q-values
    Q1(1) = pCong*Q2(1) + pIncong*Q2(2);
    Q1(2) = pCong*Q2(2) + pIncong*Q2(1);
    actionProbs = exp(beta*Q1) / sum(exp(beta*Q1));
    
    if rand <= actionProbs(1)
        choice = 'l';
    else
        choice = 'r';
    end
    
    
    %% Calculate transition and reward
    % Reward probabilitiy given a choice is SUM(p(trans)*p(reward|trans))
    outcomeCong = rand < pCong;
    Pl = task.leftprobs(trial_i);
    Pr = task.rightprobs(trial_i);
    if choice == 'l'
        if outcomeCong
            outcome = 'l';
            rewardProb = Pl;
        else
            outcome = 'r';
            rewardProb = Pr;
        end
    elseif choice == 'r'
        if outcomeCong
            outcome = 'r';
            rewardProb = Pr;
        else
            outcome = 'l';
            rewardProb = Pl;
        end
    else
        error('invalid choice');
    end
    
    % Determine reward
    reward = rand <= rewardProb;
        
    %% Do the learning
    outcome_ind = (outcome=='r')+1; % 1 for left, 2 for right
    Q2(outcome_ind) = Q2(outcome_ind) + alpha*(reward - Q2(outcome_ind)); % Rescorla-Wagner Rule
    
    choices(trial_i) = choice;
    outcomes(trial_i) = outcome;
    rewards(trial_i) = reward;
end

modeldata.rewards = rewards;
modeldata.sides1 = choices';
modeldata.sides2 = outcomes';
modeldata.leftprobs = task.leftprobs;
modeldata.rightprobs = task.rightprobs;
modeldata.viols = zeros(size(rewards));
modeldata.p_congruent = task.p_congruent;
modeldata.trans_common = (modeldata.p_congruent > 0.5 & modeldata.sides1 == modeldata.sides2) | (modeldata.p_congruent < 0.5 & modeldata.sides1 ~= modeldata.sides2);
modeldata.task = 'twostep';
modeldata.ratname = 'Model-Based TD';

end