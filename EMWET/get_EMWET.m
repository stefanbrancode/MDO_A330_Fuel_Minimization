function AC = get_EMWET(AC)
% Get the current parallel task (if any)
t = getCurrentTask();

% Save current location to return later
origDir = pwd;

% Define where the "Master" EMWET folder is located
masterEMWETDir = fullfile(pwd, 'EMWET');

if isempty(t)
    % SCENARIO A: SERIAL (Normal Mode)
    % Not running in parallel, use the standard folder
    workerDir = masterEMWETDir;
else
    % SCENARIO B: PARALLEL (Worker Mode)
    % Create a unique folder name based on Worker ID
    workerFolderName = sprintf('EMWET_Worker_%d', t.ID);
    workerDir = fullfile(pwd, workerFolderName);
    
    % Create the folder and COPY all EMWET files into it
    if ~exist(workerDir, 'dir')
        mkdir(workerDir);
        % Copy everything (*) from Master EMWET to Worker Folder
        copyfile(fullfile(masterEMWETDir, '*'), workerDir);
    end
end

try
    % Move into the working directory 
    cd(workerDir);

    % Write init file
    write_init_file(AC); 

    % Write load file
    write_load_file(AC);
    
    % Write Airfoil dat file
    write_Airfoil_file(AC);
    
    % Run EMWET
    % We capture the system status to ensure the command actually ran
    cmd = "EMWET " + AC.Name;
    [status, cmdOut] = system(cmd); 
    
    % Retrieve EMWET outputs
    AC = read_weight_file(AC);
    
    % Return to original directory
    cd(origDir);
    
    
catch ME
    % If EMWET crashes, force return to original directory
    cd(origDir);
    
    rethrow(ME);
end

end

