function [T, p, rho, a, mu] = get_ISA(H, dT)
%% International Standard Atmosphere Calculator
% Calculates the temperature, pressure, density, speed of sound, and dynamic viscosity
% for a given altitude (H) and temperature deviation from standard (dT).

% Inputs:
% H     [m]    Height
% dT    [degC] optional temperature offset

% Outputs:
% T     [K]
% p     [Pa]
% rho   [kg/m^3]
% a     [m/s]
% mu    [m^2/s]

if nargin<2, dT=0; end

% Constants
T_0 = 288.15;           % [K] Standard sea level temperature
p_0 = 1.013250e5;       % [Pa] Standard sea level pressure
rho_0 = 1.2250;         % [kg/m^3] Standard sea level density
mu_0 = 1.7894e-5;       % [m^2/s] Standard sea level dynamic viscosity
g_0 = 9.80665;          % [m/s^2] Acceleration due to gravity

T_S = 110;              % [K] Sutherland's constant for air
kap = 1.405;            % [-] Ratio of specific heats for air
n = 1.235;              % [-] Polytropic exponent for troposphere
R = 287.05287;          % [J/kg/K] Specific gas constant for air

H_Trop = 11e3;          % [m] Height of the tropopause
T_Trop = 216.65;        % [K] Temperature at the tropopause

H_Strat = 20000;        % [m] Maximum height handled by this function

% Initialize output arrays
T = zeros(size(H));
p = zeros(size(H));

% Calculate conditions in the troposphere
if H < 0, H = 0; end
inTrop = H <= H_Trop;
T(inTrop) = T_0 - g_0*(n-1)/(n*R)*H(inTrop) + dT(inTrop);
p(inTrop) = p_0 * (1 - g_0*(n-1)/(n*R) * H(inTrop) / T_0) .^ (n/(n-1));

% Calculate conditions in the stratosphere
inStrat = H > H_Trop & H <= H_Strat;
T(inStrat) = T_Trop + dT(inStrat);  % ToDo
p_tropopause = p_0 * (1 - g_0*(n-1)/(n*R) * H_Trop / T_0) .^ (n/(n-1));
p(inStrat) = p_tropopause * exp(-g_0/(R*T_Trop) * (H(inStrat) - H_Trop));

% Assign NaN to areas above the defined range
aboveStrat = H > H_Strat;
T(aboveStrat) = NaN; % Indicating undefined or unsupported values
p(aboveStrat) = NaN;

% Adjust temperature with deviation and calculate other properties
rho = p ./ (R .* T);
a = sqrt(kap * R .* T);
mu = mu_0 * (T/T_0) .^ (3/2) .* ((T_0+T_S) ./ (T+T_S)); % Sutherland's formula for viscosity

end
