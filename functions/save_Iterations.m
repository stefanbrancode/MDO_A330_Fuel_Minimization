function stop = save_Iterations(x_norm, lb, ub, optimValues, state)
%% save_Iterations
% OutputFcn for fmincon with denormalized design vector logging

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
            'stepsize',         [], ...
            'firstorderopt',    [], ...
            'constrviolation',  [], ...
            'x_norm',           [], ...
            'x_phys',           [] );

        fid = fopen('iterations_log.txt','w');
        fprintf(fid, ...
            'Iter | Func-count | Fval        | Feasibility | Step Length | Norm of step | First-order optimality | ');
        for i = 1:numel(x_norm)
            fprintf(fid, '%-7s | ', DesignVarNames{i});
        end
        fprintf(fid, '\n');
        fclose(fid);

    % ==============================================================
    % Iteration logging
    % ==============================================================
    case 'iter'

        % Denormalize design vector
        x = Denormalize_Design_Vector(x_norm, lb, ub);

        % Store numerical data
        logData.iteration(end+1,1)       = optimValues.iteration;
        logData.funcCount(end+1,1)       = optimValues.funccount;
        logData.fval(end+1,1)            = optimValues.fval;
        logData.stepsize(end+1,1)        = optimValues.stepsize;
        logData.firstorderopt(end+1,1)   = optimValues.firstorderopt;
        logData.constrviolation(end+1,1) = optimValues.constrviolation;
        logData.x_norm(end+1,:)          = x_norm(:).';
        logData.x_phys(end+1,:)          = x(:).';

        % Append to text log
        fid = fopen('iterations_log.txt','a');

        fprintf(fid, ...
            '%4d | %7d | %.6e | %.3e | %.3e | %.3e | ', ...
            optimValues.iteration, ...
            optimValues.funccount, ...
            optimValues.fval, ...
            optimValues.stepsize, ...
            optimValues.firstorderopt, ...
            optimValues.constrviolation);

        fprintf(fid, '%.4f | ', x);
        fprintf(fid, '\n');

        fclose(fid);

        % Crash-safe save
        save('iterations_log.mat','logData');

    % ==============================================================
    % Finalization
    % ==============================================================
    case 'done'
        save('iterations_log.mat','logData');
end
end
