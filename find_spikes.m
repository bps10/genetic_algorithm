function run_starts = find_spikes(voltage, threshold)
    % This is a very simple function for finding spikes. If you were doing
    % this for real you might want to use more complex methods that involve
    % wavelets etc. Here we just find zero crossing.
    
    if nargin < 2
        threshold = 0;
    end
    
    % threshold at 0
    bits = voltage > threshold;
    
    % make sure all runs of ones are well-bounded
    bounded = [0; bits; 0];
    
    % get 1 at run starts and -1 at run ends
    diffs = diff(bounded);
    
    % find the indices of all 1's
    run_starts = find(diffs > 0);

end