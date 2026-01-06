function write_load_file(AC)
% create string filename
filename = AC.Name + ".load";     
% convert to char for fopen
fid = fopen(char(filename), 'w'); 
if fid < 0
    error("Could not open file: %s", filename);
end

% dynamic pressure 
q = 0.5*AC.Mission.MO.rho * AC.Mission.MO.V^2;

y = AC.Res.invis.Wing.Yst;
for i = 1:(length(y))
    if y(i)<=AC.Wing.y(2)
        c(i) = AC.Wing.c(1) + y(i) .* (tan(AC.Wing.sweepTE(1))-tan(AC.Wing.sweepLE));
    else
        c(i) = AC.Wing.c(2) + (y(i) -AC.Wing.y(2)) .* (tan(AC.Wing.sweepTE(2))-tan(AC.Wing.sweepLE));
    end
end
c = c(:);
c = [c(1); c; AC.Wing.c(3)];
b = AC.Wing.span; 
ccl = AC.Res.invis.Wing.ccl(:);
ccl = [ccl(1); ccl; 0];
cm_c4 = AC.Res.invis.Wing.cm_c4(:);
cm_c4 = [cm_c4(1); cm_c4; 0];

y = [0; y; b/2]; 
for i = 1:(length(y)-1)    
    dy(i) = y(i+1) - y(i);
    y_new(i) = (y(i+1) + y(i)) /2;
    l(i) = q * (ccl(i+1)+ccl(i)) / 2 ; %  * dy(i)
    m(i) = q * (cm_c4(i+1)*c(i+1)+cm_c4(i)*c(i)) / 2 ; % * dy(i)
end
dy = dy(:);
y_new = y_new(:);
y_new(1) = 0;
y_new(end) = b/2;
l = l(:);
m = m(:);

eta_new = 2.*y_new/b;

for i = 1:length(eta_new)
    fprintf(fid, '%g %g %g \n', eta_new(i), l(i), m(i));
end
fclose(fid);

%% Test Validity of model
% CLwing  = AC.Res.invis.CLwing(:);
% Sref = AC.Wing.Sref(:);
% 
% % lift comparison
% L = q .* CLwing * Sref
% L = 2 * sum(l)



end