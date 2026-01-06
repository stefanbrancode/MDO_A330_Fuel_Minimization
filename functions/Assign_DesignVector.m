function AC = Assign_DesignVector(x, AC)
% will assaign the different design variables to the propperly named
% variables

% normal Flight Condition
AC.Mission.dp.M     = x(1);             % [-] cruise machn number 
AC.Mission.dp.alt   = x(2);             % flight altitude (m)

% Weights
AC.W.fuel = x(3);        % fuel weight for max range at design payload

% Wing planform geometry
AC.Wing.span = x(4);
AC.Wing.c(2) = x(5);
AC.Wing.sweepLE = x(6);
AC.Wing.Taper(2) = x(7);  

% Fuel Tank
AC.Fuel_Tank.eta(2) = x(8); % [-] 

% Structure
AC.Struct.spar_front(2:3) = [x(9), x(9)]; % [-]  
AC.Struct.spar_rear(2:3) = [x(10), x(10)];  % [-] 
 
% Airfoil coefficients input matrix
AC.Wing.Airfoil.CST_up  = [x(11)   x(12)    x(13)    x(14)    x(15)];
AC.Wing.Airfoil.CST_low = [x(16)   x(17)    x(18)    x(19)    x(20)];

end