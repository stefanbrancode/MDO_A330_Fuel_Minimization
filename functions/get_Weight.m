function W = get_Weight(W)
%GET_WEIGHT  Compute aircraft weight breakdowns
%
%   This function calculates key aircraft weight quantities based on
%   component weights provided in the input structure W.
%
%   Input / Output:
%       W.ACwoW   - Aircraft weight without wing        [kg]
%       W.fuel    - Fuel weight                         [kg]
%       W.Wing    - Wing structural weight              [kg]
%
%   Computed fields:
%       W.MTOW        - Maximum Take-Off Weight         [kg]
%       W.ZFW         - Zero-Fuel Weight                [kg]
%       W.des         - Design (cruise) weight          [kg]
%       W.cruisefrac  - Cruise weight fraction          [-]

    % Maximum Take-Off Weight (MTOW)
    W.MTOW = W.ACwoW + W.fuel + W.Wing;           % [kg]

    % Zero-Fuel Weight (ZFW)
    W.ZFW  = W.MTOW - W.fuel;                     % [kg]

    % Design weight during cruise (geometric mean of start/end cruise weight)
    W.des  = sqrt( W.MTOW * (W.MTOW - W.fuel) );  % [kg]

    % Cruise weight fraction (including reserve / correction factor)
    W.cruisefrac = (1 / 0.938) * (1 - W.fuel / W.MTOW);  % [-]

end
