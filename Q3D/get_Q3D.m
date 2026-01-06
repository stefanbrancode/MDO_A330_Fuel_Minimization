function AeroResults = get_Q3D(AC, Mission, W, Solver)
% SetUp Simulation 
AC.Aero.MaxIterIndex = 500;    %Maximum number of Iteration for the convergence of viscous calculation

% Wing planform geometry 
%                x    y     z   chord(m)    twist angle (deg) 
AC.Wing.Geom = AC.Wing.Geom;

% Wing incidence angle (degree)
AC.Wing.inc  = AC.Wing.inc;   

% Airfoil coefficients input matrix
AC.Wing.Airfoils   = AC.Wing.Airfoils;

AC.Wing.eta = AC.Wing.Airfoileta;  % Spanwise location of the airfoil sections

% Viscous vs inviscid
if strcmpi(Solver,'viscous')  
    AC.Visc  = 1;              % 0 for inviscid and 1 for viscous analysis
elseif strcmpi(Solver,'inviscid')
    AC.Visc  = 0;  
else 
    error('Wrong Aero Solver'); 
end                            
                     
% Flight Condition
AC.Aero.V     = Mission.V;            % flight speed (m/s)
AC.Aero.rho   = Mission.rho;         % air density  (kg/m3)
AC.Aero.alt   = Mission.alt;             % flight altitude (m)
AC.Aero.Re    = Mission.Re;        % reynolds number (bqased on mean aerodynamic chord)
AC.Aero.M     = Mission.M;           % flight Mach number 
AC.Aero.CL    = (W*Mission.n)  / (Mission.q * AC.Wing.Sref);          % lift coefficient - comment this line to run the code for given alpha% 

% Run Aerodynamic Solver
cd 'Q3D'
try 
    AeroResults = Q3D_solver(AC);
catch error
    fprintf('Error occurred: %s\n', error.message);
    AeroResults.CLwing = AC.Aero.CL;
    AeroResults.CDwing = 5;
end
if (AC.Visc  == 1) && ~(AeroResults.CDwing <= 5) 
    AeroResults.CLwing = AC.Aero.CL;
    AeroResults.CDwing = 5;
end
cd '..' 
end