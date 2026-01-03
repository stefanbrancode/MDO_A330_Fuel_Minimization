function AC = get_Drag(AC)
% drag_from_breguet  Computes drag using the Breguet range equation
%
% INPUTS:
%   R   - Range [m]
%   V   - Cruise velocity [m/s]
%   CT  - Thrust specific fuel consumption [1/s]
%   Wi  - Initial aircraft weight [N]
%   Wf  - Final aircraft weight [N]
%   W   - Representative cruise weight [N]
%
% OUTPUT:
%   D   - Aircraft drag force at cruise [N]
%
% ASSUMPTIONS:
%   - Steady, level cruise
%   - Lift = Weight
%   - Jet aircraft Breguet formulation

    % --- Lift-to-drag ratio from Breguet ---
    AC.Performance.L_D = (AC.Performance.R * AC.Engine.CT) / (AC.Mission.dp.V * log(1 / AC.W.cruisefrac));

    % --- total Drag from equilibrium ---
    AC.Performance.CD = AC.Res.vis.CLwing / AC.Performance.L_D;

    % --- Drag without wing (Fuselage, Engine, Empenage, ... ---
    AC.Performance.CD_woWing = AC.Performance.CD - AC.Res.vis.CDwing;

end
