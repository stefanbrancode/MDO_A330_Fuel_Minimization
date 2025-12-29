function write_Airfoil_file(AC)
% Each airfoil is defined as set of point coordinates (x ,y normalized with the chord length). 
% The coordinate must be provided from the trailing edge (1,0) toward the leading edge on the upper surface (end point (0,0)) and back to the trailing edge on the lower surface (1,0). 
% No additional comments should be in that file.
% The name of this file should be the same specified in xxx.init. 
% airfoil files must have ".dat" extension.

X = linspace(0, 1, 46)';      % points for evaluation along x-axis
[Xtu, Xtl, ~, ~, ~, ~] = D_airfoil2(AC.Wing.Airfoil.CST_up, AC.Wing.Airfoil.CST_low, X);
% Upper: descending (1 → 0)
Xtu = sortrows(Xtu, -1);

% Lower: ascending (0 → 1)
Xtl = sortrows(Xtl, 1);
    
% create string filename
filename = AC.Name  + ".dat";     
% convert to char for fopen and Open file
fid = fopen(char(filename), 'w');
if fid < 0
    error("Could not open file: %s", filename);
end

% --- Write upper surface (start at TE = 1,0) ---
for i = 1:size(Xtu,1)
    fprintf(fid, '%12.8f  %12.8f\n', Xtu(i,1), Xtu(i,2));
end

% --- Write lower surface (start at LE = 0,0 back to TE = 1,0) ---
for i = 1:size(Xtl,1)
    fprintf(fid, '%12.8f  %12.8f\n', Xtl(i,1), Xtl(i,2));
end

fclose(fid);
end