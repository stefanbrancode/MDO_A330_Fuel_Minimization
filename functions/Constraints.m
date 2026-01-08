function [c, ceq] = Constraints(x_norm, MOD, REF)

% volume of the fuel must be smaller than the volume of the tank 
MOD.Fuel_Tank.VolumeFuel = MOD.W.fuel / 9.81 / MOD.Fuel_Tank.FuelDensity;
% normailzed with initial design point
Cineq(1) = (MOD.Fuel_Tank.VolumeFuel - MOD.Fuel_Tank.VolumeTank) / REF.Fuel_Tank.VolumeTank; 

% wing loading must be at most the maximum of the reference aircraft
MOD.Performance.W_S = MOD.W.MTOW/MOD.Wing.Sref;
Cineq(2) = MOD.Performance.W_S / REF.Performance.W_S - 1;

% Weigth Limits e.g. MTOW for Landing gear Redesign?

c = [Cineq(1), Cineq(2)];
ceq = [];
end