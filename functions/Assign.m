function AC = Assign(x, AC)
% will assaign the different design variables to the propperly named
% variables

% Wing planform geometry
AC.Wing.span = x(1);
AC.Wing.c(2) = x(1);
AC.Wing.sweepLE = x(1);
AC.Wing.Taper(2) = x(1);
AC.Wing.twist = [0 0 0]; %[0, -4.5, -9];  % TODO ----------------------- 
 
% Airfoil coefficients input matrix
AC.Wing.Airfoil.CST_up  = [x(1)   x(1)    x(1)    x(1)    x(1)];
AC.Wing.Airfoil.CST_low = [x(1)   x(1)    x(1)    x(1)    x(1)];

% Fuel Tank
AC.fueltank(2) = 0.85; % [-] 

% Structure
AC.Struct.spar_front(2:3) = [x(2), x(3)]; % [-]  
AC.Struct.spar_rear(2:3) = [x(2), x(3)];  % [-] 

% Weights
AC.W.fuel = x(1);        % fuel weight for max range at design payload 

% normal Flight Condition
AC.Mission.dp.alt   = x(1);             % flight altitude (m)
AC.Mission.dp.M     = x(1);                                    % [-] cruise machn number 



end