function AeroResults = get_Q3D(AC_IN, Mission, W, Solver)
% Wing planform geometry 
%                x    y     z   chord(m)    twist angle (deg) 
AC.Wing.Geom = AC_IN.Wing.Geom;

% Wing incidence angle (degree)
AC.Wing.inc  = AC_IN.Wing.inc;   

% Airfoil coefficients input matrix
AC.Wing.Airfoils   = AC_IN.Wing.Airfoils;

AC.Wing.eta = AC_IN.Wing.Airfoileta;  % Spanwise location of the airfoil sections

% Viscous vs inviscid
if strcmpi(Solver,'viscous')  
    AC.Visc  = 1;              % 0 for inviscid and 1 for viscous analysis
elseif strcmpi(Solver,'inviscid')
    AC.Visc  = 0;  
else 
    error('Wrong Aero Solver'); 
end


AC.Aero.MaxIterIndex = 150;    %Maximum number of Iteration for the convergence of viscous calculation
                                
                                
% Flight Condition
AC.Aero.V     = Mission.V;            % flight speed (m/s)
AC.Aero.rho   = Mission.rho;         % air density  (kg/m3)
AC.Aero.alt   = Mission.alt;             % flight altitude (m)
AC.Aero.Re    = Mission.Re;        % reynolds number (bqased on mean aerodynamic chord)
AC.Aero.M     = Mission.M;           % flight Mach number 
AC.Aero.CL    = (9.81*W*Mission.n)  / (0.5 * Mission.rho * Mission.V^2 * AC_IN.Wing.Sref);          % lift coefficient - comment this line to run the code for given alpha% 

%print statement
AC.Aero.CL

%% 
cd 'Q3D'
% AeroResults = Q3D_solver(AC);
try 
    AeroResults = Q3D_solver(AC);
catch error
    AeroResults = inf;
end
cd '..' 
end