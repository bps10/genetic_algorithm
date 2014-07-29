function voltage = QUADmodel(param, current, intstep)
    % See Izhikevich 2007 for more info.
    
    % Set up parameters
    u1DOT = 0;
    u2DOT = 0;
    vDOT = 0;
    CAP = 50.0; % capacitance in pF
    vDOT = -70; % V naught in mV - start at resting potential
    vRESTING = -70;
    voltage = zeros(length(current), 1);
    
    a_1 = param(1);
    a_2 = param(2);
    
    b_1 = param(8); 
    b_2 = -param(6); 
    
    d_1 = param(3);
    d_2 = param(4);
   
    vTHR = param(5);
    vRESET = param(9);
    
    % integrate using Euler
    for i = 1:length(current)
    
        if vDOT < vTHR
            k_ = param(7);
        else
            k_ = 2;
        end
        
        % voltage
        vDOT = vDOT + (k_ * (vDOT - vRESTING) * (vDOT - vTHR) - u1DOT - u2DOT + ...
                 current(i)) * intstep / CAP;
             
        % gating variables
        u1DOT = u1DOT + (a_1 * (b_1 * (vDOT - vRESTING) - u1DOT)) * intstep;
        u2DOT = u2DOT + (a_2 * (b_2 * (vDOT - vRESTING) - u2DOT)) * intstep;
    
        if vDOT >= 35 + (0.1 * (u1DOT + u2DOT))
            vDOT = vRESET - (0.1 * (u1DOT + u2DOT));
            u1DOT = u1DOT + d_1;
            u2DOT = u2DOT + d_2;
        
        end
        
        voltage(i) = vDOT;
    end

end