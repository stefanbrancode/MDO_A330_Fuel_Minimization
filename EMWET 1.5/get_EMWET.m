function AC = get_EMWET(AC)
% Store the original directory BEFORE changing folders
origDir = pwd;
% Switch to EMWET 1.5 folder
cd('EMWET 1.5')

write_init_file(AC); 
write_load_file_new(AC);
write_Airfoil_file(AC);
try 
    EMWET A330-300
    AC = read_weight_file(AC);
catch error
    AC.W.Wing = inf;
end
% return to original directory
cd(origDir);
end