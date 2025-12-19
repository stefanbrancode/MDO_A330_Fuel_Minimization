function Geo = get_Geometry(Geo)
%% Assaign Values 
Geo.y = [0 , Ref.ykink, b]; 
Geo.Gamma = Ref.Gamma; 
lamda(2) = Ref.lamda(2);  


%% Calulate Values
Geo.x = sin(Geo.Lambda_LE)*Geo.y; 
Geo.z = sin(Geo.Gamma)*Geo.y; 
Geo.c = [ckink + y(2)*(sin(Geo.Lambda_LE)-sin(Geo.Lambda_TE)), ...
    ckink ,...
    lamda(2)*ckink]; 
lamda(1) = c(2)/c(1); 
for i = 1:2 % Reference Area using the trapeziod Formula
     S(i) = 1/2 * (c(i) + c(i+1)) / (y(i+1) - y(i));
     MAC_(i) = 2/3* (1 + lamda(i) + lamda(i)^2) / (1 + lamda(i));
end
Geo.Sref = sum(S);
Geo.MAC = sum(MAC_(i).*S) / Geo.Sref; 
Geo.AR = b^2/S_ref;
end