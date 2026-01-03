%% Modeling of the Reference Aircraft
clear all
close all
clc

%% Initialize 
% Initialize Aircraft File
% REF = load_AC('A330-300.mat');

% Initialize Folders 
folders = ["functions", "Q3d", "EMWET 1.5"];
for i = 1:length(folders)
    addpath(genpath(folders{i}));
    disp(['Folder added: ', folders{i}]);
end

% Resolution of the graphics
Resolution = 300;  

% Gravity Acceleration 
g = 9.81; % [m/s^2]

%% Aircraft Inputs
REF.Name = "A330-300";

% Wing planform geometry 
REF.Wing.dihedral = 4.72*pi/180;
REF.Wing.sweepLE = 32 * pi/180;
REF.Wing.sweepTE = [5, 20.56] * pi/180;
REF.Wing.span = 60.3;
REF.Wing.c = [12.0781, 7.69313, 2.2];
REF.Wing.y = [0, 8.15989, REF.Wing.span/2];
REF.Wing.twist = [0, -4.5, -9]; % [deg] 

% Wing incidence angle (degree)
REF.Wing.inc  = 4.5;   
 
% Airfoil coefficients input matrix
REF.Wing.Airfoil_Name = "A330_Airfoil"; 
REF.Wing.Airfoil.CST_up = [0.1459   0.1809    0.1075    0.2600    0.2516];
REF.Wing.Airfoil.CST_low = [-0.2034   0.0091    -0.3087    0.0758    0.0643];
REF.Wing.Airfoileta = [0;1];  % Spanwise location of the airfoil sections

% Engines
REF.Engine.y = 18.74/2;         % [m] Source: Airbus A330 APM
REF.Engine.l = 5.639;           % [m] Source: Wikipedia
REF.Engine.d = 2.47;            % [m] Source: Wikipedia
REF.Engine.num = 2; 
REF.Engine.Wdry = 6160;           % [kg] Dry engine weight, not including fluids and nacelle EBU
REF.Engine.lft = conv_unit("m", "ft", 7.00);      % [ft] Length of Naccel     %% TODO: confirm data -----------------
REF.Engine.dft = conv_unit("m", "ft", 3.10);      % [ft] diameter of Naccel   %% TODO: confirm data -----------------
REF.Engine.CT = 0.565/60/60;      % [N/Ns] specific fuel consumption Source: https://web.archive.org/web/20190627155423/http://www.jet-engine.net/civtfspec.html

% Fuel Tank
REF.Fuel_Tank.eta = [0, 0.85];  % [-] 

% Structure
REF.Struct.spar_front = [NaN, 0.20, 0.20]; % [-]
REF.Struct.spar_rear = [NaN, 0.80, 0.80];  % [-]
REF.Struct.Alu.E = conv_unit("N/mm^2", "N/m^2", 70.10e3);  % [N/m2]
REF.Struct.Alu.rho = 2800;    % [kg/m^3]
REF.Struct.Alu.Ft = conv_unit("N/mm^2", "N/m^2", 295);        % [N/m2] 
REF.Struct.Alu.Fc = conv_unit("N/mm^2", "N/m^2", 295);        % [N/m2]
REF.Struct.eff_factor = 0.96; 
REF.Struct.pitch_rib = 0.5; % [m]

% Performance
REF.Performance.R     = conv_unit("nm", "m", 4500);  % Source: Aircraft Table

% normal Flight Condition
REF.Mission.dp.alt   = conv_unit("ft", "m", 39000);             % flight altitude (m)  Source: Aircraft Table
REF.Mission.dp.V     = conv_unit("kt", "m/s", 465);              % flight speed (m/s)  Source: Aircraft Table
REF.Mission.dp.n     = 1;                                       % load factor

% extrem load Flight Condition
REF.Mission.MO.alt      = conv_unit("ft", "m", 39000 );             % flight altitude (m)
REF.Mission.MO.M        = 0.86;  
REF.Mission.MO.n        = 2.5;                                       % load factor

% Weights
REF.W.MTOW = g * 217000;                                        % Max. take-off weight
REF.W.MZFW = g * 169000;                                        % Max. take-off weight
REF.W.OEW = g * 118189;                                         % Operational empty weight
REF.W.des_pay = g * 28025;                                      % Design payload weight

%% 
% Wing planform geometry 
REF.Wing.eta = 2 .* REF.Wing.y ./ REF.Wing.span;
REF.Wing.x = tan(REF.Wing.sweepLE).*REF.Wing.y;
REF.Wing.z = tan(REF.Wing.dihedral).*REF.Wing.y;
REF.Wing.Taper(1) = REF.Wing.c(2)/REF.Wing.c(1);
REF.Wing.Taper(2) = REF.Wing.c(3)/REF.Wing.c(2);
%                x                  y                   z                   chord(m)            twist angle (deg) 
REF.Wing.Geom = [REF.Wing.x(1)      REF.Wing.y(1)       REF.Wing.z(1)       REF.Wing.c(1)       REF.Wing.twist(1) ;   
                 REF.Wing.x(2)      REF.Wing.y(2)       REF.Wing.z(2)       REF.Wing.c(2)       REF.Wing.twist(2) ;
                 REF.Wing.x(3)      REF.Wing.y(3)       REF.Wing.z(3)       REF.Wing.c(3)       REF.Wing.twist(3) ];
% Airfoil
%                    |-> upper curve coeff. <-||-> lower curve coeff. <-| 
REF.Wing.Airfoils   = [REF.Wing.Airfoil.CST_up, REF.Wing.Airfoil.CST_low;
                       REF.Wing.Airfoil.CST_up, REF.Wing.Airfoil.CST_low];
REF = get_Geometry(REF);

% Engines
REF.Engine.eta = 2 .* REF.Engine.y/REF.Wing.span;
REF.Engine.S_Naccelft = pi * REF.Engine.dft * REF.Engine.lft;      % [ft^2] wetted area of Naccel %% TODO: confirm calc -----------------
[~, W_pylongroup] = get_Raymer_Installed_Engine( ...
        REF.Engine.Wdry, 1.18, 1.017, 1.0, ...
        REF.Engine.lft, REF.Engine.dft, REF.Mission.MO.n, REF.Engine.num, REF.Engine.S_Naccelft);
REF.Engine.Winstalled = W_pylongroup / REF.Engine.num;

% normal Flight Condition
[~, ~, REF.Mission.dp.rho, REF.Mission.dp.a, REF.Mission.dp.mu] = get_ISA(REF.Mission.dp.alt);
REF.Mission.dp.M = REF.Mission.dp.V / REF.Mission.dp.a; % flight Mach number
REF.Mission.dp.Re = REF.Mission.dp.rho * REF.Mission.dp.V * REF.Wing.MAC / REF.Mission.dp.mu; % reynolds number (bqased on mean aerodynamic chord)

% extrem load Flight Condition
REF.Mission.MO          = get_Misssion(REF.Mission.MO, REF.Wing.MAC); 

% Weights
REF.W.fuel = REF.W.MTOW - REF.W.OEW - REF.W.des_pay;        % fuel weight for max range at design payload 
REF.W.ZFW = REF.W.MTOW - REF.W.fuel;                        % Zero-fuel weight	
REF.W.des = sqrt(REF.W.MTOW * (REF.W.MTOW-REF.W.fuel));     % Design load

%% Calculate Geometrics
REF = get_Geometry(REF);

%% Aerodynamic Solver
tic
fprintf("start inviscid simulation \n");
REF.Res.invis = get_Q3D(REF, REF.Mission.MO, REF.W.MTOW, "inviscid");
t=toc;
fprintf("Comutational time: %.2f s \n", t);

tic
fprintf("start viscous simulation \n");
REF.Res.vis = get_Q3D(REF, REF.Mission.dp, REF.W.des, "viscous");
t=toc;
fprintf("Comutational time: %.2f s \n", t);

%% wing structure Solver
tic
fprintf("start structual optimisation \n");
REF = get_EMWET(REF);
t=toc;
fprintf("Comutational time: %.2f s \n", t);
fprintf("Wing weight: %.0f kg\n", REF.W.Wing/g);
%  W.ACwoW - Aircraft weight without wing  
REF.W.ACwoW = REF.W.MTOW - REF.W.fuel - REF.W.Wing;
REF.W = get_Weight(REF.W);

%% Lift-to-Drag and Drag 
REF = get_Drag(REF); 
fprintf("Lift to Drag Ratio: %.2f \n", REF.Performance.L_D);
fprintf("Drag coeficient: %f2 \n",  REF.Performance.CD);
fprintf("Drag coeficient without wing: %f2 \n", REF.Performance.CD_woWing);

%% Fuel Tank Volume Calculation
Wing_Volume = get_Wing_Volume(REF, 150, 300);

% Assume 80% of the wing volume is usable for fuel
REF.Fuel_Tank.Volume = 0.93 * Wing_Volume;
REF.Fuel_Tank.FuelDensity = 0.81715*1e3; % kg/m^3  
REF.Fuel_Tank.Available_fuel_mass = REF.Fuel_Tank.Volume * REF.Fuel_Tank.FuelDensity;
fprintf('Total wing volume: %.2f m^3\n', Wing_Volume);

%% MDA consistency check loop
REF = MDAStefan(REF);

%% Visualisation
plot_AeroPerformance(REF, REF, Resolution);
plot_Airfoil(REF, REF, Resolution);
plot_WingPlanfrom(REF, REF, Resolution);
plot_Wing3D(REF, REF, Resolution);

%% Safe Reference Aircraft File
save("A330-300.mat", "REF");   % saves AC data  into a .mat file