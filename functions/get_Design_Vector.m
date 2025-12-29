function x = get_Design_Vector(AC,fields_active)
if (nargin==2)
x=[];
for i = 1:length(fields_active)
    f = fields_active{i};
    
    switch f
        case 'root_chord'
            if isfield(AC.Wing, 'c')
                x(end+1) = AC.Wing.c(1);
            end
        case 'leadingEdgeSweep'
            if isfield(AC.Wing, 'sweepLE')
                x(end+1) = AC.Wing.sweepLE;
            end
        case 'TaperRatio_Tip_To_Kink'
            if isfield(AC.Wing, 'c') && length(AC.Wing.c) >= 3
                x(end+1) = AC.Wing.c(3)/AC.Wing.c(2);
            end
        case 'span_Tip_To_Kink'
            if isfield(AC.Wing, 'y') && length(AC.Wing.y) >= 3
                x(end+1) = AC.Wing.y(3) - AC.Wing.y(2);
            end
        case 'Mach'
            if isfield(AC.Mission.dp, 'M')
                x(end+1) = AC.Mission.dp.M;
            end
        case 'altitude'
            if isfield(AC.Mission.dp, 'alt')
                x(end+1) = AC.Mission.dp.alt;
            end
        case 'CST_up'
            if isfield(AC.Wing.Airfoil, 'CST_up')
                x = [x, AC.Wing.Airfoil.CST_up]; %#ok<AGROW>
            end
        case 'CST_low'
            if isfield(AC.Wing.Airfoil, 'CST_low')
                x = [x, AC.Wing.Airfoil.CST_low]; %#ok<AGROW>
            end
        otherwise
            error('Unknown design field: %s', f);
    end
end

else
x(1) = AC.Wing.c(1);
x(2) = AC.Wing.sweepLE;
x(3) = AC.Wing.c(3)/AC.Wing.c(2);
x(4) = AC.Wing.y(3) - AC.Wing.y(2);
x(5) = AC.Mission.dp.M;
x(6) = AC.Mission.dp.alt;
x(7:11) = AC.Wing.Airfoil.CST_up;
x(12:16) = AC.Wing.Airfoil.CST_low;
end    




end