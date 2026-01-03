function write_init_file(AC)
%%------ Routine to write the input file for the EMWET procedure --------- %%

% TODO: For loops ----------------------
% create string filename
filename = AC.Name + ".init";     
% convert to char for fopen
fid = fopen(char(filename), 'w');   
if fid < 0
    error("Could not open file: %s", filename);
end

fprintf(fid, '%g %g \n', AC.W.MTOW, AC.W.MZFW);
fprintf(fid, '%g \n', AC.Mission.MO.n);

fprintf(fid, '%g %g %g %g \n', AC.Wing.Sref, AC.Wing.span , 3, 2);

fprintf(fid, '0 %s \n',AC.Wing.Airfoil_Name);
fprintf(fid, '1 %s \n',AC.Wing.Airfoil_Name);
fprintf(fid, '%g %g %g %g %g %g \n', AC.Wing.c(1), AC.Wing.x(1), AC.Wing.y(1), AC.Wing.z(1), AC.Struct.spar_front(1), AC.Struct.spar_rear(1));
fprintf(fid, '%g %g %g %g %g %g \n', AC.Wing.c(2), AC.Wing.x(2), AC.Wing.y(2), AC.Wing.z(2), AC.Struct.spar_front(2), AC.Struct.spar_rear(2));
fprintf(fid, '%g %g %g %g %g %g \n', AC.Wing.c(3), AC.Wing.x(3), AC.Wing.y(3), AC.Wing.z(3), AC.Struct.spar_front(3), AC.Struct.spar_rear(3));

fprintf(fid, '%g %g \n', AC.Fuel_Tank.eta(1), AC.Fuel_Tank.eta(2));

fprintf(fid, '%g \n', AC.Engine.num/2);
fprintf(fid, '%g  %g \n', AC.Engine.eta, AC.Engine.Winstalled);

fprintf(fid, '%g %g %g %g \n', AC.Struct.Alu.E, AC.Struct.Alu.rho, AC.Struct.Alu.Ft, AC.Struct.Alu.Fc);
fprintf(fid, '%g %g %g %g \n', AC.Struct.Alu.E, AC.Struct.Alu.rho, AC.Struct.Alu.Ft, AC.Struct.Alu.Fc);
fprintf(fid, '%g %g %g %g \n', AC.Struct.Alu.E, AC.Struct.Alu.rho, AC.Struct.Alu.Ft, AC.Struct.Alu.Fc);
fprintf(fid, '%g %g %g %g \n', AC.Struct.Alu.E, AC.Struct.Alu.rho, AC.Struct.Alu.Ft, AC.Struct.Alu.Fc);

fprintf(fid,'%g %g \n',AC.Struct.eff_factor,AC.Struct.pitch_rib);
fprintf(fid,'0 \n');
fclose(fid);

end