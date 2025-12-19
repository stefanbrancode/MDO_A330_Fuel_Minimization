function[error] = CST_objective(x)

%Determine upper and lower CST parameters from design-vector
 Au = x(1:length(x)/2);
 Al = x(length(x)/2+1:length(x));

% Define the Airfoil coordinates
% Read-in the Airfoil coordinate file
fid= fopen('A330Airfoil_normalized.dat','r'); % Filename can be changed as required
Coor = fscanf(fid,'%g %g',[2 Inf]) ; 
fclose(fid) ; 

%Transpose to obtain correct format as in the file
Coor = Coor'; 

% Loop to find the transition between upper and lower coordinates
% (When the Y coordinate of upper side = 0)
lim = length(Coor); 
for i=1:lim
    if Coor (i,2) == 0
        k = i ;
        break;
    end
end

% Get the (x,y) coordinates of upper and lower parts of the airfoil:
Coor_up = Coor(1:k,:) ;
Coor_low = Coor((k+1):lim,:) ; 

%Split file input into x and y components
X_u = Coor_up(:,1);
X_l = Coor_low(:,1);
Y_u = Coor_up(:,2);
Y_l = Coor_low(:,2);

%Perform mapping of CST method twice, for both upper (Au) and lower (Al) surface 
%CST parameters; use corresponding upper and lower surface x-ordinates from E553 
[Co_CST_up, Co_discard] = D_airfoil2(Au,Al,X_u);
[Co_discard2, Co_CST_low] = D_airfoil2(Au,Al,X_l);

%upper and lower partial fiting-error vectors
error_up = Y_u - Co_CST_up(:,2);
error_low = Y_l - Co_CST_low(:,2);

%final objective value
error = sum(error_up.^2) + sum(error_low.^2); 


