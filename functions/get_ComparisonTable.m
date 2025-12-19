function T = get_ComparisonTable(Ref, optimized)
% designComparisonTable  Build a comparison table (initial vs optimized).
%
% T = designComparisonTable(initial, optimized)
%
% Inputs (structs) — any field not present will be treated as missing (NaN)
%   Common (recommended) fields (units in parentheses):
%     .objective             - objective function value (unitless or as used)
%     .designVars            - vector or struct of design variables [z1,z2,x1] (kg/m etc)
%     .constraints           - vector with constraint values (user-defined sign)
%     .Wfuel                 - fuel weight (kg)
%     .WTO_max               - maximum takeoff weight (kg)
%     .Wstr_wing             - wing structure weight (kg)
%     .WCO2                  - mass of CO2 emitted during mission (kg)
%     .Vtank                 - wing tank capacity (m^3)
%     .S                     - wing area (m^2)
%     .MAC                   - mean aerodynamic chord (m)
%     .AR                    - aspect ratio (dimensionless)
%     .LE_sweep              - leading-edge sweep (deg) or vector per panel
%     .chords                - vector of chord lengths per panel (m)
%     .span                  - wing span (m)
%     .V                     - flight speed at design point (m/s)
%     .h                     - altitude at design point (m)
%     .Mach                  - Mach number at design point
%     .rho                   - air density at design point (kg/m^3)
%     .mu                    - dynamic viscosity at design point (Pa*s)
%     .c_ref                 - reference chord for Re (m) (if missing MAC used)
%     .CT                    - specific fuel consumption (1/s or 1/hr, user unit)
%     .eta                   - propulsion efficiency (0..1)
%     .CL                    - lift coefficient at design point
%     .alpha                 - angle of attack (deg)
%     .CD0_wing              - zero-lift (parasite) wing CD
%     .CD_AW                 - aircraft-without-wing drag coeff (dimensionless)
%     .WAW                   - aircraft-less-wing-and-fuel weight (kg)
%
% Notes:
%  - We assume weights are in kg. If your weights are in Newtons, convert them first.
%  - Fuel density used to compute Vfuel default is rho_fuel = 804 kg/m^3
%  - Induced drag uses CDi = CL^2/(pi*AR*e). If e is not provided defaults to 0.85.
%
% Output:
%   T - table with rows for each metric and two columns: Initial, Optimized
%
% Example:
%  init.Wfuel = 2000; init.S = 50; init.AR = 9; init.CL=0.5; init.V=230;
%  init.rho = 0.38; init.mu = 1.46e-5; init.MAC = 2.5; init.CD0_wing=0.02;
%  opt = init; opt.Wfuel = 1800; opt.CL = 0.48;
%  T = designComparisonTable(init,opt); disp(T)
%

% --- constants & helpers ---
rho_fuel_default = 804;     % kg/m^3 typical Jet-A density
g = 9.80665;                % m/s^2
e_default = 0.85;           % Oswald efficiency factor default
nanify = @(x) (isempty(x) && ~isnumeric(x)) || (~exist('x','var')) * NaN;

% local helper: get struct field or NaN
    function val = gf(s, field)
        if isstruct(s) && isfield(s, field)
            val = s.(field);
            if isempty(val), val = NaN; end
        else
            val = NaN;
        end
    end

% compute derived quantities given a design struct
    function out = computeDerived(s)
        out = struct();
        % basic fields
        out.objective = gf(s,'objective');
        out.designVars = gf(s,'designVars'); % vector or struct
        out.constraints = gf(s,'constraints');
        out.Wfuel = gf(s,'Wfuel');          % kg
        out.WTO_max = gf(s,'WTO_max');      % kg
        out.Wstr_wing = gf(s,'Wstr_wing');  % kg
        out.WCO2 = gf(s,'WCO2');            % kg
        out.Vtank = gf(s,'Vtank');          % m^3 (wing tank capacity)
        out.S = gf(s,'S');                  % m^2
        out.MAC = gf(s,'MAC');              % m
        out.AR = gf(s,'AR');                % -
        out.LE_sweep = gf(s,'LE_sweep');
        out.chords = gf(s,'chords');
        out.span = gf(s,'span');
        % design point
        out.V = gf(s,'V');                  % m/s
        out.h = gf(s,'h');                  % m
        out.Mach = gf(s,'Mach');
        out.rho = gf(s,'rho');
        out.mu = gf(s,'mu');
        out.c_ref = gf(s,'c_ref');
        out.CT = gf(s,'CT');                % specific fuel consumption (user)
        out.eta = gf(s,'eta');              % propulsion efficiency
        out.CL = gf(s,'CL');
        out.alpha = gf(s,'alpha');          % deg
        out.CD0_wing = gf(s,'CD0_wing');
        out.CD_AW = gf(s,'CD_AW');          % aircraft-without-wing CD
        out.WAW = gf(s,'WAW');              % aircraft-less-wing-and-fuel weight (kg)
        out.e = gf(s,'e');
        if isnan(out.e), out.e = e_default; end

        % set defaults / fallback
        if isnan(out.c_ref)
            if ~isnan(out.MAC), out.c_ref = out.MAC; end
        end

        % Vfuel (m^3) from Wfuel (kg)
        if ~isnan(out.Wfuel)
            rho_f = gf(s,'rho_fuel');
            if isnan(rho_f), rho_f = rho_fuel_default; end
            % assume Wfuel given in kg; if Wfuel input in N user must adjust
            out.Vfuel = out.Wfuel ./ rho_f;
        else
            out.Vfuel = NaN;
        end

        % aerodynamic baseline: compute CDi_wing, CD_wing if possible
        if ~isnan(out.CL) && ~isnan(out.AR) && ~isnan(out.e)
            out.CDi_wing = out.CL.^2 ./ (pi .* out.AR .* out.e);
        else
            out.CDi_wing = NaN;
        end
        if ~isnan(out.CD0_wing)
            out.CD_wing = out.CD0_wing + out.CDi_wing;
        else
            out.CD_wing = NaN;
        end

        % CL/CD if possible
        if ~isnan(out.CL) && ~isnan(out.CD_wing)
            out.CL_over_CD = out.CL ./ out.CD_wing;
        else
            out.CL_over_CD = NaN;
        end

        % dynamic pressure q = 0.5*rho*V^2
        if ~isnan(out.rho) && ~isnan(out.V)
            out.q = 0.5 * out.rho .* out.V.^2;
        else
            out.q = NaN;
        end

        % Reynolds number Re = rho*V*c/mu (use c_ref)
        if ~isnan(out.rho) && ~isnan(out.V) && ~isnan(out.c_ref) && ~isnan(out.mu)
            out.Re = out.rho .* out.V .* out.c_ref ./ out.mu;
        else
            out.Re = NaN;
        end

        % Drag force D_AW = q * S * CD_AW (aircraft-less-wing drag force)
        if ~isnan(out.q) && ~isnan(out.S) && ~isnan(out.CD_AW)
            out.D_AW = out.q .* out.S .* out.CD_AW;
            % non-dimensional coefficient again for consistency:
            out.CD_AW = out.CD_AW; % pass-through
        else
            out.D_AW = NaN;
        end

        % WA-W (aircraft-less-wing-and-fuel weight) if not given attempt compute:
        if isnan(out.WAW)
            % if WTO_max and Wstr_wing and Wfuel known, attempt estimate
            if ~isnan(out.WTO_max) && ~isnan(out.Wstr_wing) && ~isnan(out.Wfuel)
                out.WAW = out.WTO_max - out.Wstr_wing - out.Wfuel;
            else
                out.WAW = NaN;
            end
        end

        % WTO_max/S (wing loading)
        if ~isnan(out.WTO_max) && ~isnan(out.S)
            out.WTO_div_S = out.WTO_max ./ out.S;
        else
            out.WTO_div_S = NaN;
        end

        % wing geometry summary: if chords/span/LE_sweep vectors available, pass through or compute
        out.geometrySummary = struct('S',out.S,'MAC',out.MAC,'WTO_div_S',out.WTO_div_S,...
            'AR',out.AR,'LE_sweep',out.LE_sweep,'chords',out.chords,'span',out.span);
    end

% compute for both designs
A = computeDerived(Ref);
B = computeDerived(optimized);

% build table rows (order following user's list)
rowNames = {
    'Objective function value'
    'Design variables'
    'All constraints'
    'Wfuel (kg)'
    'WMTO (kg)'
    'Wstr_wing (kg)'
    'WCO2 (kg)'
    'Vfuel (m^3)'
    'Vtank (m^3)'
    'V (m/s)'
    'h (m)'
    'Mach'
    'dynamic pressure q (Pa)'
    'Reynolds number (Re)'
    'CT (SFC)'
    'eta (propulsion efficiency)'
    'CL'
    'alpha (deg)'
    'CD_wing (total)'
    'CDi_wing (induced)'
    'CL/CD'
    'D_A-W (N)'
    'CD_A-W'
    'WA-W (kg)'
    'S (m^2)'
    'MAC (m)'
    'WTO_max/S (kg/m^2)'
    'AR'
    'LE sweep (deg)'
    'chords (m)'
    'span (m)'
    };

% extract cell values
getCell = @(x) { ...
    x.objective; ...
    x.designVars; ...
    x.constraints; ...
    x.Wfuel; ...
    x.WTO_max; ...
    x.Wstr_wing; ...
    x.WCO2; ...
    x.Vfuel; ...
    x.Vtank; ...
    x.V; ...
    x.h; ...
    x.Mach; ...
    x.q; ...
    x.Re; ...
    x.CT; ...
    x.eta; ...
    x.CL; ...
    x.alpha; ...
    x.CD_wing; ...
    x.CDi_wing; ...
    x.CL_over_CD; ...
    x.D_AW; ...
    x.CD_AW; ...
    x.WAW; ...
    x.S; ...
    x.MAC; ...
    x.WTO_div_S; ...
    x.AR; ...
    x.LE_sweep; ...
    x.chords; ...
    x.span; ...
    };

colA = getCell(A);
colB = getCell(B);

% build displayable table: convert non-scalar values to strings for table readability
n = numel(rowNames);
colA_disp = cell(n,1);
colB_disp = cell(n,1);
for i=1:n
    colA_disp{i} = scalarOrString(colA{i});
    colB_disp{i} = scalarOrString(colB{i});
end

T = table(colA_disp, colB_disp, 'RowNames', rowNames, ...
    'VariableNames', {'Initial','Optimized'});

% optionally display
disp(T)

end

% ------- helper function for pretty scalar/string conversion -------
function out = scalarOrString(x)
if isempty(x) || (isnumeric(x) && all(isnan(x(:))))
    out = "<missing>";
elseif isnumeric(x) && isscalar(x)
    out = x;
elseif ischar(x)
    out = string(x);
elseif isstring(x)
    out = string(x);
elseif iscell(x)
    % cell -> convert to numeric string or JSON-like
    try
        out = jsonencode(x);
    catch
        out = "<cell>";
    end
elseif isstruct(x)
    % summarise struct fields
    fn = fieldnames(x);
    s = cellfun(@(f) sprintf('%s: %g', f, tryGetScalar(x.(f))), fn, 'UniformOutput', false);
    out = string(strjoin(s, ', '));
else
    % numeric vector or array: show as string
    if isnumeric(x)
        out = ['[', num2str(x(:).', ' %.4g'), ']'];
    else
        out = "<value>";
    end
end
end

function v = tryGetScalar(x)
if isnumeric(x) && isscalar(x)
    v = x;
else
    v = NaN;
end
end
