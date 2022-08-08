function modeldata = generative_modelFree(alpha,beta,task)
% Generate simulated data using model-free TD learning, given a set of
% reward probabilities 
% Accepts a learning rate alpha, inverse temp beta, and task structure
% consisting of (at least) a pair of vectors of reward probabilities.

% Check inputs
assert(0 <= alpha && alpha <= 1);
assert(0 <= beta);
assert(isfield(task,'leftprobs'));
assert(isfield(task,'rightprobs'));
assert(length(task.leftprobs) == length(task.rightprobs));

% If the task doesn't specify the transition probability, assume that it's
% 80/20 incongruent
if ~isfield(task,'p_congruent')
    pCong = 0.2;
else
    pCong = task.p_congruent;
end

Q = [0.5,0.5]; % Initialize q-values to 0.5

% Pre-allocate my arrays
nTrials = length(task.leftprobs);
rewards = NaN(nTrials,1);
choices = char(zeros(nTrials,1));
outcomes = char(zeros(nTrials,1));

for trial_i = 1:nTrials
   
    %% Figure out the model's choice given Q-values
    actionProbs = exp(beta*Q) / sum(exp(beta*Q));
    
    if rand <= actionProbs(1) % High actionProbs(1) means a high chance of choosing left
        choice = 'l';
    else
        choice = 'r';
    end
    
    
    %% Calculate transition and reward
    
    outcomeCong = rand < pCong; % Is the outcome congruent with the choice, or not?
    
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
    choice_ind = (choice=='r')+1; % 1 for left, 2 for right
    Q(choice_ind) = Q(choice_ind) + alpha*(reward - Q(choice_ind)); % Rescorla-Wagner Rule
    
    choices(trial_i) = choice;
    outcomes(trial_i) = outcome;
    rewards(trial_i) = reward;
end

modeldata.rewards = rewards;
modeldata.sides1 = choices;
modeldata.sides2 = outcomes;
modeldata.leftprobs = task.leftprobs;
modeldata.rightprobs = task.rightprobs;
modeldata.viols = zeros(size(rewards));
modeldata.p_congruent = task.p_congruent;
modeldata.task = 'twostep';
modeldata.ratname = 'Model-Free TD';

end