function par = gen_params()
    % Generates a set of random parameters.
    
    par =  [randi([1, 1000]) / 10000, ...
            randi([1, 1000]) / 1000, ...
           randi([20, 80]),...
           randi([1, 50]), ...
           randi([-55, -35]), ...
           5 * randi([1, 1000]) / 1000, ...
           randi([1, 100]) / 100, ...
           randi([1, 100]) / 10, ...
           randi([-55, -35])];
end