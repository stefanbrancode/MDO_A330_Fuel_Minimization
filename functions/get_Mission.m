function Mission = get_Mission(Mission, MAC)
%% get_Mission
% Computes atmospheric and flight-condition parameters for a mission
% design point based on altitude, Mach number, and reference length.
%
% INPUTS:
%   Mission.alt  - [m]     Flight altitude
%   Mission.M    - [-]     Mach number
%   MAC          - [m]     Mean aerodynamic chord (reference length)
%
% OUTPUT:
%   Mission      - Updated mission structure with:
%                  .rho  [kg/m^3] Air density
%                  .a    [m/s]    Speed of sound
%                  .mu   [Pa·s]   Dynamic viscosity
%                  .V    [m/s]    True airspeed
%                  .q    [Pa]     Dynamic pressure
%                  .Re   [-]      Reynolds number (based on MAC)

% Atmospheric properties (ISA model)
% get_ISA returns:
%   [T, p, rho, a, mu]
[~, ~, Mission.rho, Mission.a, Mission.mu] = get_ISA(Mission.alt);

% Flight velocity
% True airspeed from Mach number
Mission.V = Mission.M * Mission.a;

% Dynamic pressure
Mission.q = 0.5 * Mission.rho * Mission.V^2;

% Reynolds number (based on MAC)
Mission.Re = Mission.rho * Mission.V * MAC / Mission.mu;

end
