function AC = load_AC(filename)
% loadAC loads an aircraft struct saved earlier
%
% Usage:
%   AC = load_AC('A330_REF_data.mat');

    if nargin < 1
        filename = 'AC_data.mat';   % default file
    end

    if ~isfile(filename)
        error('File "%s" not found.', filename);
    end

    data = load(filename, 'AC');   % load only variable AC

    if ~isfield(data, 'AC')
        error('Variable "AC" not found in "%s".', filename);
    end

    AC = data.AC;
end
