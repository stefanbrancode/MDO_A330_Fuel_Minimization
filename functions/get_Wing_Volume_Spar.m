function V = get_Wing_Volume_Spar(REF, Ny, Nx)
% Computes wing box volume (between spars) from root to 85% of half-span
% Single function: No sub-functions required.

%% --- 1. Setup Parameters ---
Au = REF.Wing.Airfoil.CST_up;
Al = REF.Wing.Airfoil.CST_low;
N1 = 0.5;
N2 = 1.0;

% Spar positions (fraction of chord)
spar_front = 0.20; 
spar_rear  = 0.80; 

%% --- 2. Calculate Normalized Spar Box Area (Chord = 1) ---
% We calculate the area of the profile between spars *once* here.
psi = linspace(spar_front, spar_rear, Nx);

% Class Function C(psi)
C = (psi.^N1) .* ((1 - psi).^N2);

% -- Upper Surface Shape --
Su = zeros(size(psi));
Nu = length(Au) - 1; 
for k = 0:Nu
    % Bernstein Polynomial: nCk * psi^k * (1-psi)^(n-k)
    bk = nchoosek(Nu, k) .* (psi.^k) .* ((1 - psi).^(Nu - k));
    Su = Su + Au(k+1) .* bk;
end
y_norm_u = C .* Su;

% -- Lower Surface Shape --
Sl = zeros(size(psi));
Nl = length(Al) - 1; 
for k = 0:Nl
    bk = nchoosek(Nl, k) .* (psi.^k) .* ((1 - psi).^(Nl - k));
    Sl = Sl + Al(k+1) .* bk;
end
y_norm_l = C .* Sl;

% Integrate normalized Area (Unit Chord)
% Area = Integral(Upper - Lower)
Area_norm = trapz(psi, y_norm_u - y_norm_l);


%% --- 3. Loop over Wing Span ---
yStations = REF.Wing.y;        % [0 y_mid b/2]
cStations = REF.Wing.c;        % [c_root c_mid c_tip]
b_half = REF.Wing.span / 2;
y_cut  = 0.85 * b_half;        % <-- spanwise cutoff
V_half = 0;

for i = 1:length(yStations)-1
    y0 = yStations(i);
    y1 = yStations(i+1);
    
    % Check cutoff
    if y0 >= y_cut
        break;
    end
    y1_eff = min(y1, y_cut);
    
    c0 = cStations(i);
    c1 = cStations(i+1);
    
    % Spanwise discretization
    y = linspace(y0, y1_eff, Ny);
    
    % Linear chord interpolation
    c = c0 + (c1 - c0) .* (y - y0) ./ (y1 - y0);
    
    % Scale Area by chord squared
    % (Area scales with Length^2)
    A_section = Area_norm .* (c.^2);
    
    % Integrate Volume for this segment
    V_half = V_half + trapz(y, A_section);
end

% Symmetry (Left + Right wing)
V = 2 * V_half;

end