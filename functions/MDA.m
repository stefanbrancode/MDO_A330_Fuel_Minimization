function AC = MDA(AC)
%MDASTEFAN MDA convergence loop
g = 9.81; 

MTOW_hat = AC.W.MTOW; %store old MTOW of aircraft
error=1; % to replace the do while haha
iteration = -1; %for monitoring purposes

while (abs(error)) > 1e-6
    iteration = iteration + 1;
    fprintf("MDA Iteration: %d \n", iteration);
    
    % Q3D inviscid
    AC.Res.invis = get_Q3D(AC, AC.Mission.MO, MTOW_hat, "inviscid"); %Calculate Lift and Moment distributions
    
    % EMWET
    AC = get_EMWET(AC);
    fprintf("Wing weight: %.0f kg\n", AC.W.Wing/g);
    
    % WEIGHT 
    AC.W = get_Weight(AC.W);

    % ERROR
    error = (AC.W.MTOW - MTOW_hat) / MTOW_hat;
   
    % 
    MTOW_hat = AC.W.MTOW;
end

end