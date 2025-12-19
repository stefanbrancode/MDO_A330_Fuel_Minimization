function AC = read_weight_file(AC)
% create string filename
filename = AC.Name + ".weight";     
% convert to char for fopen
fid = fopen(char(filename), 'r'); 
if fid < 0
    error("Could not open file: %s", filename);
end
data = textscan(fid, '%sg', 'Delimiter', '\n'); %read all data as string
AC.W.Wing = str2num(data{1}{1}(23:end));
fclose(fid);
end