function [Cineq, Ceq] = Constraints(MOD, REF)
% volume of the fuel must be smaller than the volume of the tank    
% Cineq(1) = AC.FuelTank.VolumeFuel - AC.FuelTank.VolumeTank; 

% wing loading must be at most the maximum of the reference aircraft
Cineq(2) = MOD.W.MTOW/MOD.Wing.Sref - REF.W.MTOW/REF.Wing.Sref;

% fuel volume of the optimized design must be at most the same at the fuel
% volume of the reference aircraft (emissions cap)
% Not nessesarry?
Cineq(3) = MOD.W.fuel - REF.W.fuel;

% Weigth Limits e.g. MTOW for Landing gear Redesign

Ceq = [];
end