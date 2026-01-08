function AeroResults = get_Q3D(AC, Mission, W, Solver)
% SetUp Simulation 
AC.Aero.MaxIterIndex = AC.Sim.Q3D_MAXIter;    %Maximum number of Iteration for the convergence of viscous calculation

% Wing planform geometry 
%                x    y     z   chord(m)    twist angle (deg) 
AC.Wing.Geom = AC.Wing.Geom;

% Wing incidence angle (degree)
AC.Wing.inc  = AC.Wing.inc;   

% Airfoil coefficients input matrix
AC.Wing.Airfoils   = AC.Wing.Airfoils;

AC.Wing.eta = AC.Wing.Airfoileta;  % Spanwise location of the airfoil sections

% Viscous vs inviscid
if strcmpi(Solver,'viscous')  % 0 for inviscid and 1 for viscous analysis
    AC.Visc  = 1;  
    Folder_Name = "Vis";
elseif strcmpi(Solver,'inviscid')
    AC.Visc  = 0;  
    Folder_Name = "Invis";
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


% Get the current parallel task (if any)
t = getCurrentTask();

% Save current location to return later
origDir = pwd;

% Define where the "Master" Q3D folder is located
masterQ3DDir = fullfile(pwd, 'Q3D');

if isempty(t)
    % SCENARIO A: Serial Mode
    % Not running in parallel, use the standard folder
    workerDir = masterQ3DDir;
    
else
    % SCENARIO B: Parallel Mode
    % We are inside a parallel worker. We cannot all use 'Q3D' folder 
    
    % Create a unique directory name for this worker
    workerFolderName = sprintf('Q3D_Worker_%s_%d', Folder_Name, t.ID);
    workerDir = fullfile(pwd, workerFolderName);

    % If folder does not exist yet, create the folder and COPY the Q3D solver files into it
    if ~exist(workerDir, 'dir')
        mkdir(workerDir);
        % Copy ALL contents (*) from Master Q3D to Worker Folder
        copyfile(fullfile(masterQ3DDir, '*'), workerDir);
    end
end  
    
try
    % Move into the unique worker directory
    cd(workerDir);
    
    % Run the solver
    AeroResults = Q3D_solver(AC);
    
    % Return to main directory
    cd(origDir);
    
catch ME
    % If solver crashes, force return to original directory
    AeroResults.CLwing = NaN;
    AeroResults.CDwing = NaN;

    % Return to main directory
    cd(origDir);

    rethrow(ME);
end

if (AC.Visc  == 1) && ~(AeroResults.CDwing <= 5) 
    AeroResults.CLwing = AC.Aero.CL;
    AeroResults.CDwing = 5;
end

end

