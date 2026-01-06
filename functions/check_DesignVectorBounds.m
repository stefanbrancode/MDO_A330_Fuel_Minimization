function check_DesignVectorBounds(x0, lb, ub, varargin)
%% checkDesignVectorBounds
% Checks whether the initial design vector x0 lies within the bounds [lb, ub].
%
% USAGE:
%   check_DesignVectorBounds(x0, lb, ub)
%   check_DesignVectorBounds(x0, lb, ub, 'mode', 'warn')
%   check_DesignVectorBounds(x0, lb, ub, 'mode', 'error')
%   check_DesignVectorBounds(x0, lb, ub, 'mode', 'pause')
%
% INPUTS:
%   x0  - Initial design vector
%   lb  - Lower bounds
%   ub  - Upper bounds
%
% OPTIONAL PARAMETERS:
%   'mode' : 'warn'  (default)
%            'pause' (keyboard)
%            'error' (throws error)

%% ------------------------------------------------------------------------
% Parse inputs
% -------------------------------------------------------------------------
p = inputParser;
addParameter(p, 'mode', 'warn', @(s)ischar(s) || isstring(s));
parse(p, varargin{:});

mode = lower(string(p.Results.mode));

%% ------------------------------------------------------------------------
% Safety checks
% -------------------------------------------------------------------------
assert(numel(x0) == numel(lb) && numel(x0) == numel(ub), ...
    'x0, lb and ub must have the same length');

x0 = x0(:);
lb = lb(:);
ub = ub(:);

%% ------------------------------------------------------------------------
% Find bound violations
% -------------------------------------------------------------------------
idxLow  = find(x0 < lb);
idxHigh = find(x0 > ub);
idxBad  = unique([idxLow; idxHigh]);

if isempty(idxBad)
    fprintf('✓ All %d design variables are within bounds.\n', numel(x0));
    return
end

%% ------------------------------------------------------------------------
% Report violations
% -------------------------------------------------------------------------
fprintf('\n⚠️  Design vector bound violations detected:\n');
fprintf('Idx\tValue\t\tLower bound\tUpper bound\n');
fprintf('----------------------------------------------------\n');

for i = idxBad'
    fprintf('%3d\t% .4e\t% .4e\t% .4e\n', ...
        i, x0(i), lb(i), ub(i));
end

%% ------------------------------------------------------------------------
% Handle violation
% -------------------------------------------------------------------------
switch mode
    case "warn"
        warning('DesignVector:OutOfBounds', ...
            '%d design variables are outside bounds.', numel(idxBad));

    case "pause"
        warning('DesignVector:OutOfBounds', ...
            '%d design variables are outside bounds. Execution paused.', ...
            numel(idxBad));
        keyboard

    case "error"
        error('DesignVector:OutOfBounds', ...
            '%d design variables are outside bounds.', numel(idxBad));

    otherwise
        error('Unknown mode "%s". Use warn, pause, or error.', mode);
end
end
