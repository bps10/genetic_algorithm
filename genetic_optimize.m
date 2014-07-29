function winner = genetic_optimize(population, train)
    
    % set some parameters
    mutation_probability = train.mutate_prob;
    elite = train.elite;
    generations = train.numgen;
    
    % How many winners from each generation?
    original_pop_size = size(population);
    top_elite = round(elite * original_pop_size(1));
    
    % Main loop
    for i = 1:generations
        % setup a data container for our results
        individual_scores = zeros(original_pop_size(1), ...
            original_pop_size(2) + 1);
        
        % here is where we assess (score) each individual
        for p = 1:length(population)
            params = population(p, :);
            individual_scores(p, 1) = fitness(params, train);
            individual_scores(p, 2:end) = params;
        end
        
        % sort individuals by best score (lower is better)
        individual_scores = sortrows(individual_scores, 1);
        
        % discard scores, keep ranking order
        ranked_individuals = individual_scores(:, 2:end);

        % Start a new population
        population = zeros(original_pop_size(1), original_pop_size(2));
        
        % Seed with the winners from last generation, discard losers
        population(1:top_elite, :) = ranked_individuals(1:top_elite, :);
        
        % Add mutated and bred forms of the winners to fill out population
        j = top_elite;
        while j < original_pop_size(1)
                
            % select two individuals from elite
            indiv1 = randi(top_elite, 1);
            indiv2 = randi(top_elite, 1);

            % make sure we have 2 different individuals to mate
            if indiv1 == indiv2 
                indiv2 = indiv2 + 1;
            end

            % mate them
            new_indiv = mate_individuals(ranked_individuals(indiv1, :), ...
                ranked_individuals(indiv2, :));
                
              % Dedide whether to mutate
            if randi(100, 1) < mutation_probability * 100 % Mutate
                
                % choose which elite individual to duplicate
                c = randi(top_elite);
                
                % create newly mutated individual
                new_indiv = mutate_individual(ranked_individuals(c, :), ...
                    @train.paramgen);              
            end
            
            % add the new individual to the population
            population(j, :) = new_indiv;
            j = j + 1;
        end
    end
    winner = ranked_individuals(1, :);
    
end

%%%%%%%%%%%%%%%%%%%%%
%%%% Subroutines %%%%
%%%%%%%%%%%%%%%%%%%%%

function individual = mutate_individual(individual, paramgen)
    % index of single point mutation
    ipos = randi(length(individual));
    
    % generate a new indiv for selecting the mutated gene
    temp_indiv = paramgen();
    
    % select a single gene to mutate
    mutation = temp_indiv(ipos); 
    
    % cut out the old gene and put in mutation
    individual = [individual(1:ipos - 1), mutation, individual(ipos + 1:end)];
end

function individual = mate_individuals(p1, p2)
    % create a crossover event
    ipos = randi(length(p1));
    
    % merge the two individuals at the specified index
    individual = [p1(1:ipos), p2(ipos + 1:end)];
end

function [spike_reward, spike_punishment] = spike_reward_value(Model_mV, train)

    % find the spike locations in the model
    Model_Spikes = find_spikes(Model_mV);
    
    % get spike N for reward/punishment assessment
    total_spikes = length(Model_Spikes);
    
    % start with no reward
    spike_reward = 0;
    if total_spikes >= 1

        interval = train.delta / train.intstep;
        counter = 1; % start with first data spike
        spike_test = 1; % start with first model spike
        
        % see if each model spike falls near a data spike (w/in interval)
        while spike_test < total_spikes && counter < train.nspikes
            
            if ( Model_Spikes(spike_test) >= (train.spikes(counter) - interval) && ...
                 Model_Spikes(spike_test) <= (train.spikes(counter) + interval) )
                
                spike_reward = spike_reward + 1; % reward the model
                counter = counter + 1; % don't use data spike more than once
                spike_test = spike_test + 1; % move to next model spike
                
            elseif Model_Spikes(spike_test) < train.spikes(counter) - interval
                spike_test = spike_test + 1; % move to next model spike
                
            elseif Model_Spikes(spike_test) > train.spikes(counter) + interval
                counter = counter + 1; % move to next data spike
               
            end
        end
    end
    % compute spike punishment
    spike_punishment = total_spikes - spike_reward;

end 

function error = fitness(param, train)
    
    % simulate the model with the parameters specified
    model_volt = train.model(param, train.curr, train.intstep);
    
    % make sure there are no NaNs
    if any(isnan(model_volt))
        error = 1e20; % set error extremely high if so and return
        return
    end
    
    N = train.size; % number of samples in data.
    
    % compute RMS error
    sumsqr = sqrt(sum((train.volt - model_volt) .^ 2) / N);
    
    % compute RMS error on dVdt
    model_dVdt = model_volt - fliplr(model_volt);
    data_dVdt = train.volt - fliplr(train.volt);
    dVdt_ERR = sqrt(sum((model_dVdt - data_dVdt) .^ 2) / N);
    
    % compute spike reward and punishment
    [spike_reward, spike_punishment] = spike_reward_value(model_volt, train);
    
    % compute final error score
    error = sumsqr + dVdt_ERR + train.punish * spike_punishment - ...
        train.reward * spike_reward;

end
