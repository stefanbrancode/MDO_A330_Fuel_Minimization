function write_load_file_new(AC)

% create string filename
filename = AC.Name + ".load";     
% convert to char for fopen
fid = fopen(char(filename), 'w'); 
if fid < 0
    error("Could not open file: %s", filename);
end

q = 0.5*AC.Mission.MO.rho*AC.Mission.MO.V^2; % dynamic pressure at MO
% Yst= spanwise location of strips   
Res=AC.Res.invis;

if ~(length(Res.Wing.ccl) == length(Res.Wing.Yst) && length(Res.Wing.cm_c4) == length(Res.Wing.Yst))
disp(Res.Wing.ccl/Res.Wing.cl)
disp(Res.Wing.ccl);
disp(Res.Wing.Yst);
disp(Res.Wing.cm_c4);
end

Yst = Res.Wing.Yst;
L_y = Res.Wing.ccl .* q; % compute lift at each strip
M_y = Res.Wing.cm_c4 .* (Res.Wing.ccl ./ Res.Wing.cl) *AC.Wing.MAC* q; % compute moment at each strip


% 2. Normalize
eta_strips = Yst / (AC.Wing.span/2);

% 3. Create Target Vector (0 to 1)
eta_target = [0; eta_strips; 1];

% 4. Interpolate/Extrapolate Loads
L_target = interp1(eta_strips, L_y, eta_target, 'linear', 'extrap');
M_target = interp1(eta_strips, M_y, eta_target, 'linear', 'extrap');

for i = 1:length(eta_target)
    fprintf(fid, '%g %g %g \n', eta_target(i), L_target(i), M_target(i));
end
fclose(fid);
end