function stop = save_Iterations(x_norm, x0, REF, optimValues, state)
%% save_Iterations
% OutputFcn for fmincon with denormalized design vector logging

%% --- Global plot settings ---
set(groot,'defaultTextInterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

% Save current location to return later
origDir = pwd;

stop = false;
persistent logData

DesignVarNames = { ...
    % Mission design point
    'Mach';                    % [-] Cruise Mach number
    'Alt';                      % [m] Cruise altitude

    % Weights
    'W_Fuel';                     % [kg] Fuel weight

    % Wing planform geometry
    'Span';                       % [m] Wing span
    'Kink Chord';                 % [m] Kink chord
    'LE Sweep';                   % [rad] Leading edge sweep
    'Outer Taper';                % [-] Outer panel taper ratio

    % Fuel tank
    'FTank Eta';              % [-] Spanwise fuel tank extent

    % Wing structure
    'Front Spar';      % [-] Front spar position (outer wing)
    'Rear Spar';       % [-] Rear spar position (outer wing)

    % Airfoil CST coefficients
    'Au CST 1'; ...
    'Au CST 2'; ...
    'Au CST 3'; ...
    'Au CST 4'; ...
    'Au CST 5'; ...

    'Al CST 1'; ...
    'Al CST 2'; ...
    'Al CST 3'; ...
    'Al CST 4'; ...
    'Al CST 5' ...
};


switch state

    % ==============================================================
    % Initialization
    % ==============================================================
    case 'init'

        logData = struct( ...
            'iteration',        [], ...
            'funcCount',        [], ...
            'fval',             [], ...
            'constrviolation',  [], ...
            'stepsize',         [], ...
            'firstorderopt',    [], ...
            'x_norm',           [], ...
            'x_phys',           [], ...
            'c',                [], ...
            'ceq',              [] ...
            );
        
        % Change directory
        cd 'Results'

        % Generate File and Header
        fid = fopen('iterations_log.txt','w');
        fprintf(fid, ...
            'Iter | Func-count | Fval          | Feasibility | Step Length | Norm of step | First-order optimality');
        for i = 1:numel(x_norm)
            fprintf(fid, ' | %-7s ', DesignVarNames{i});
        end
        fprintf(fid, '\n');
        fclose(fid);

    % ==============================================================
    % Iteration logging
    % ==============================================================
    case 'iter'

        % Denormalize design vector
        x = x_norm .* abs(x0); 
        [c, ceq] = Constraints(x_norm, x0, REF);

        % Store numerical data
        logData.iteration(end+1,1)       = optimValues.iteration;
        logData.funcCount(end+1,1)       = optimValues.funccount;
        logData.fval(end+1,1)            = optimValues.fval;
        logData.stepsize(end+1,1)        = optimValues.stepsize;
        logData.constrviolation(end+1,1) = optimValues.constrviolation;
        logData.firstorderopt(end+1,1)   = optimValues.firstorderopt;
        logData.x_norm(end+1,:)          = x_norm(:).';
        logData.x_phys(end+1,:)          = x(:).';
        logData.c{end+1}                 = c(:).';
        logData.ceq{end+1}               = ceq(:).';
        
        % Change directory
        cd 'Results'

        % Append to text log
        fid = fopen('iterations_log.txt','a');

        fprintf(fid, ...
            '%4d |    %7d | %.6e |   %.3e |   %.3e | %.3e | ', ...
            optimValues.iteration, ...
            optimValues.funccount, ...
            optimValues.fval, ...
            optimValues.constrviolation, ...
            optimValues.stepsize, ...
            optimValues.firstorderopt);

        fprintf(fid, ' | %.4f', x);
        fprintf(fid, ' | %.4f', c);
        % fprintf(fid, ' | %.4f', ceq);
        fprintf(fid, '\n');

        fclose(fid);

        % Crash-safe save
        save('iterations_log.mat','logData');
    % ==============================================================
    % Finalization
    % ==============================================================
    case 'done'
    % Change directory
    cd 'Results'
        save('iterations_log.mat','logData');
end
    
cd(origDir);
end
