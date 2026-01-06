function MOD = get_Performance(MOD, REF)
%% Performance
% Computes aircraft-level performance metrics for the modified aircraft
% based on aerodynamic results and mission conditions.
%
% INPUTS:
%   MOD - Modified aircraft data structure (updated in-place)
%   REF - Reference aircraft data structure (used for comparison)
%
% OUTPUT:
%   MOD - Modified aircraft structure with updated performance fields

%% ------------------------------------------------------------------------
% Total aircraft drag coefficient
% -------------------------------------------------------------------------
% Total CD consists of:
%   - Wingless aircraft drag (assumed unchanged)
%   - Wing drag from Q3D viscous analysis
MOD.Performance.CD_woWing_MOD = REF.Performance.CD_woWing * REF.Mission.dp.q / MOD.Mission.dp.q * REF.Wing.Sref / MOD.Wing.Sref ; 
MOD.Performance.CD = MOD.Performance.CD_woWing_MOD + MOD.Res.vis.CDwing;

%% ------------------------------------------------------------------------
% Lift-to-drag ratio
% -------------------------------------------------------------------------
% L/D based on wing lift coefficient and total aircraft drag coefficient
MOD.Performance.L_D = ...
    MOD.Res.vis.CLwing / MOD.Performance.CD;

%% ------------------------------------------------------------------------
% Engine efficiency correction factor
% -------------------------------------------------------------------------
% Penalizes engine efficiency if cruise speed or altitude deviates from
% the reference aircraft design point.
%
% Gaussian decay:
%   - Velocity sensitivity:  sigma = 70 m/s
%   - Altitude sensitivity:  sigma = 2500 m
MOD.Performance.eta_eng = exp( ...
    - (MOD.Mission.dp.V   - REF.Mission.dp.V  ).^2 / (2 * 70^2) ...
    - (MOD.Mission.dp.alt - REF.Mission.dp.alt).^2 / (2 * 2500^2) );

%% ------------------------------------------------------------------------
% Correct engine thrust-specific fuel consumption
% -------------------------------------------------------------------------
% Lower efficiency -> higher effective CT
MOD.Engine.CT = REF.Engine.CT / MOD.Performance.eta_eng;

%% ------------------------------------------------------------------------
% Breguet-type range calculation
% -------------------------------------------------------------------------
% R = (V / CT) * (L/D) * ln(W_initial / W_final)
% Here, W.cruisefrac represents the weight fraction after cruise
MOD.Performance.R = ...
    (MOD.Mission.dp.V / MOD.Engine.CT) * ...
    MOD.Performance.L_D * ...
    log(1 / MOD.W.cruisefrac);

end
