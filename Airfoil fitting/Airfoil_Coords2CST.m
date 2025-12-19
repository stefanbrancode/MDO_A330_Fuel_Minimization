clc
clear
% --- Read the file ---
fid = fopen('A330Airfoil.dat','r');
Coor = fscanf(fid,'%g %g',[2 Inf])';
fclose(fid);

% --- Modify the coordinates here ---
% Example modification (replace with your own):
Coor = Coor';


min(Coor(1,:))
max(Coor(1,:))
min(Coor(2,:))

Coor(1,:) = Coor(1,:) - min(Coor(1,:));
max(Coor(1,:))
Coor = Coor./max(Coor(1,:));

% --- Save modified coordinates to a new file ---
fid_out = fopen('A330Airfoil_normalized.dat','w');
fprintf(fid_out, '%g %g\n', Coor);
fclose(fid_out);
disp('Modified file saved as A330Airfoil_modified.dat');

% 
% This script shows the implementation of the CST airfoil-fitting
% optimization of MDO Tutorial 1

M = 10  %Number of CST-coefficients in design-vector x

%Define optimization parameters
x0 = 1*ones(M,1);     %initial value of design vector x(starting vector for search process)
lb = -1*ones(M,1);    %upper bound vector of x
ub = 1*ones(M,1);     %lower bound vector of x

options=optimset('Display','Iter');

[error] = CST_objective(x0)

tic
[x,fval,exitflag] = fmincon(@CST_objective,x0,[],[],[],[],lb,ub,[],options);
t=toc

M_break=M/2;
X_vect = linspace(0,1,99)';      %points for evaluation along x-axis
Aupp_vect=x(1:M_break);
Alow_vect=x(1+M_break:end);
[Xtu,Xtl,C,Thu,Thl,Cm] = D_airfoil2(Aupp_vect,Alow_vect,X_vect);


% Visualisation
% CST data
figure;
hold on
plot(Xtu(:,1),Xtu(:,2),'b');    %plot upper surface coords
plot(Xtl(:,1),Xtl(:,2),'b');    %plot lower surface coords
% real airfoil coords
plot(Coor(1,:),Coor(2,:),'rx')

axis equal      % <-- ensures x and y have the same scale
axis([0,1,-0.5,0.5]);
pbaspect([1 1 1])   % Ensures 1 meter in X looks exactly like 1 meter in Y
grid on
hold off


