clear;

%%%% ----------------------------------
%%%% Training data

train_volt = 'voltage.csv';
train_curr = 'current.csv';
sampling_rate = 5000; % Sampling rate the data was collected at (Hz)
time = 500; % Duration of the training data (msec)
intstep = time / sampling_rate; % in msec
%%%% ----------------------------------

%%%% ----------------------------------
%%%% Fitting parameters to tweak ------

% What to call the file containing optimized parameters when we finish
SAVE_FILENAME = 'evolved_params.csv';

% Parameters that control the fitness function
training_data.delta = 3; % for spike reward / punishment (in msec)
training_data.punish = 2; % how heavily to weight punishment
training_data.reward = 5; % how heavily to weight reward
training_data.nindiv = 100; % number of individuals in each generation

% Parameters that control the evolutionary algorithm behavior
training_data.mutate_prob = 0.5; % probability of a mutation vs breeding
training_data.elite = 0.2; % fraction of population considered elite
training_data.numgen = 200; % number of generations to compete
%%%% ----------------------------------

%%%% Pass function handles for model to optimize and parameter generator
training_data.model = @(par, curr, step)QUADmodel(par, curr, step);
training_data.paramgen = @gen_params;
%%%% ---------------------------------

% Read in training data
data_volt = csvread(train_volt) * 1000; %data was saved in V, move to mV
data_curr = csvread(train_curr); 

% Fill in other data
training_data.intstep = intstep;
training_data.volt = data_volt; % training data voltage
training_data.curr = data_curr; % training data current
training_data.size = length(data_curr);
training_data.spikes = find_spikes(data_volt);
training_data.nspikes = length(training_data.spikes);

% Generate initial population
param_pop = zeros(training_data.nindiv, length(gen_params()));
for i = 1: length(param_pop)
    param_pop(i, :) = gen_params();
end

% Run the optimization program
evolved_param = genetic_optimize(param_pop, training_data);

% Save to file
csvwrite(SAVE_FILENAME, evolved_param);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Plot the final product %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate voltage response from the model using the evolved params
model_volt = QUADmodel(evolved_param, data_curr, intstep);

% X values for plotting
x_vals = intstep:intstep:time;

figure();
subplot(211);
plot(x_vals, model_volt, 'b', 'linewidth', 2); hold on;
plot(x_vals, data_volt, 'k', 'linewidth', 2);
box off;

legend('model', 'data', 'location', 'NorthWest');
ylabel('mem. pot. (mV)');

subplot(212);
plot(x_vals, data_curr, 'k', 'linewidth', 2);
ylabel('current (pA)');
xlabel('time (msec)');
box off;
