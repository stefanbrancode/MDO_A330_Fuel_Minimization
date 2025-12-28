%% Aerodynamic solver setting
clear all
close all
clc
% 

%% Initialize
% REF = load_AC('A330-300.mat');
folders = ["functions", "Q3d", "EMWET 1.5"];
for i = 1:length(folders)
    addpath(genpath(folders{i}));
    disp(['Folder added: ', folders{i}]);
end
%% Inputs
REF.Name = "A330-300";
% Wing planform geometry 
REF.Wing.dihedral = 4.72*pi/180;
REF.Wing.sweepLE = 32 * pi/180;
REF.Wing.sweepTE = [5, 20.56] * pi/180;
REF.Wing.span = 60.3;
REF.Wing.c = [12.0781, 7.69313, 2.2];
REF.Wing.y = [0, 8.15989, REF.Wing.span/2];
REF.Wing.twist = [0 0 0]; %[0, -4.5, -9];  % TODO -----------------------

% Wing incidence angle (degree)
REF.Wing.inc  = 4.5;   
 
% Airfoil coefficients input matrix
REF.Wing.Airfoil_Name = "A330_Airfoil"; 
REF.Wing.Airfoil.CST_up = [0.1459   0.1809    0.1075    0.2600    0.2516];
REF.Wing.Airfoil.CST_low = [-0.2034   0.0091    -0.3087    0.0758    0.0643];
REF.Wing.Airfoileta = [0;1];  % Spanwise location of the airfoil sections

% Engines
REF.Engine.y = 18.74/2;         % [m] Source Airbus APM
REF.Engine.num = 2; 
REF.Engine.Wdry = 6160;           % [kg] Dry engine weight, not including fluids and nacelle EBU
REF.Engine.lft = conv_unit("m", "ft", 7.00);      % [ft] Length of Naccel     %% TODO: confirm data -----------------
REF.Engine.dft = conv_unit("m", "ft", 3.10);      % [ft] diameter of Naccel   %% TODO: confirm data -----------------

% Fuel Tank
REF.fueltank(1) = 0;  % [-] 
REF.fueltank(2) = 0.85; % [-] 

% Structure
REF.Struct.spar_front = [0.20, 0.20, 0.20]; % TODO ------------------
REF.Struct.spar_rear = [0.80, 0.80, 0.80];  % TODO ------------------
REF.Struct.Alu.E = conv_unit("N/mm^2", "N/m^2", 70.10e3);  % [N/m2]
REF.Struct.Alu.rho = 2800;    % [kg/m^3]
REF.Struct.Alu.Ft = conv_unit("N/mm^2", "N/m^2", 295);        % [N/m2] 
REF.Struct.Alu.Fc = conv_unit("N/mm^2", "N/m^2", 295);        % [N/m2]
REF.Struct.eff_factor = 0.96; 
REF.Struct.pitch_rib = 0.5; % [m]

% normal Flight Condition
REF.Mission.dp.n     = conv_unit("nm", "m", 4500);  % Source: Aircraft Table
REF.Mission.dp.alt   = conv_unit("ft", "m", 39000);             % flight altitude (m)  Source: Aircraft Table
REF.Mission.dp.V     = conv_unit("kt", "m/s", 465);              % flight speed (m/s)  Source: Aircraft Table
REF.Mission.dp.n     = 1;                                       % load factor

% extrem load Flight Condition
REF.Mission.MO.alt      = conv_unit("ft", "m", 39000 );             % flight altitude (m)
REF.Mission.MO.M        = 0.86;  
REF.Mission.MO.n        = 2.5;                                       % load factor

% Weights
REF.W.MTOW = 217000;                                        % Max. take-off weight
REF.W.MZFW = 169000;                                        % Max. Zero fuel take-off weight
REF.W.OEW = 118189;                                         % Operational empty weight
REF.W.des_pay = 28025;                                      % Design payload weight

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

% % Engines
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
REF.Mission.MO= get_Mission(REF.Mission.MO, REF.Wing.MAC); 

% Weights
REF.W.fuel = REF.W.MTOW - REF.W.OEW - REF.W.des_pay;        % fuel weight for max range at design payload 
REF.W.ZFW = REF.W.MTOW - REF.W.fuel;                        % Zero-fuel weight	
REF.W.des = sqrt(REF.W.MTOW * (REF.W.MTOW-REF.W.fuel));     % Design load

%% Geometrics
REF = get_Geometry(REF);

%% Aerodynamic Solver
tic
fprintf("start inviscid simulation \n");
REF.Res.invis = get_Q3D(REF, REF.Mission.MO, REF.W.MTOW, "inviscid");
t=toc;
fprintf("Computational time: %f2 s \n", t);

%Run this to get drag at cruise conditions
tic
fprintf("start viscous simulation \n");
REF.Res.vis = get_Q3D(REF, REF.Mission.dp, REF.W.des, "viscous");
t=toc;
fprintf("Computational time: %f2 s \n", t);

%% wing structure Solver
tic
fprintf("start structual optimisation \n");
REF = get_EMWET(REF);
t=toc;
fprintf("Computational time: %f2 s \n", t);
fprintf("Wing weight: %f2 kg\n", REF.W.Wing);

%% Drag
fprintf("Aircraft weight: %f2 kg\n", REF.W.MTOW);

REF.W.ACwoW = REF.W.MTOW - REF.W.fuel - REF.W.Wing     
REF.W = get_Weight(REF.W);

REF.Res.vis.CDwing

REF.L_over_D_aircraft=16;

REF.Mission.CD = REF.Res.vis.CLwing / REF.L_over_D_aircraft;
REF.Mission.CD_woWing = REF.Mission.CD - REF.Res.vis.CDwing;

%% MDA consistency loop
REF = MDAStefan(REF);
%% Volume calculation

Wing_Volume = get_Wing_Volume(REF, 150, 300);

% Assume 80% of the wing volume is usable for fuel
fueltank.Volume = 0.8 * Wing_Volume;
fueltank.FuelDensity = 0.81715*1e3; % kg/m^3  
fueltank.Available_fuel_mass = fueltank.Volume * fueltank.FuelDensity
fprintf('Total wing volume: %.2f m^3\n', Wing_Volume);

%% Visualisation

% print_WingAirfoil(REF,REF);
print_WingPlanfrom(REF, REF);

%% Safe Reference Aircraft File
%  W.ACwoW - Aircraft weight without wing  
REF.W.ACwoW = REF.W.MTOW - REF.W.fuel - REF.W.Wing;           % [kg]
save("A330-300.mat", "REF");   % saves AC data  into a .mat file