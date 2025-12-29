function x_struct = Design_Vector_To_Struct(x_full, fields_active)
% Takes FULL ordered design vector and extracts ONLY fields_active
% Canonical order:
% 1  root_chord
% 2  leadingEdgeSweep
% 3  TaperRatio_Tip_To_Kink
% 4  span_Tip_To_Kink
% 5  Mach
% 6  altitude
% 7–11  CST_up
% 12–16 CST_low

x_struct = struct();

for i = 1:length(fields_active)
    f = fields_active{i};

    switch f
        case 'root_chord'
            x_struct.root_chord = x_full(1);

        case 'leadingEdgeSweep'
            x_struct.leadingEdgeSweep = x_full(2);

        case 'TaperRatio_Tip_To_Kink'
            x_struct.TaperRatio_Tip_To_Kink = x_full(3);

        case 'span_Tip_To_Kink'
            x_struct.span_Tip_To_Kink = x_full(4);

        case 'Mach'
            x_struct.Mach = x_full(5);

        case 'altitude'
            x_struct.altitude = x_full(6);

        case 'CST_up'
            x_struct.CST_up = x_full(7:11);

        case 'CST_low'
            x_struct.CST_low = x_full(12:16);

        otherwise
            error('Unknown design field: %s', f);
    end
end

end
