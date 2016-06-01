%% initialize
%clear all
%close all
%clc

%% load simulation data
disp('loading data ...')
% uiload

time=1500;
current=2.3;
voltage=3.3;
temp=33;

tsim=3600*3;
t_sample=1;

%[B,A]=butter(4,0.00022);
%temperature=filtfilt(B,A,temp);

%temperature=temperature-temperature(1)-15;

%% load battery model parameters
% battery parameters are generated from the single temperature coefficients
% remember the log relationships
disp('loading battery model parameters ...')
load MT_lookup_table_coefs.mat % loads in coef_fit_log and partitions 

T_tab=[-15 -10 -5 0 5 15 25 35 45];
load coef_part.txt;
SOC_tab=coef_part;

R0c_tab=coef_cell{1}; % log(1000*resistance))
R0d_tab=coef_cell{2}; % log(1000*resistance))
A1c_tab=coef_cell{3}; % log(capacitance)
A2c_tab=coef_cell{4}; % log(capacitance)
A1d_tab=coef_cell{5}; % log(capacitance)
A2d_tab=coef_cell{6}; % log(capacitance)
B1c_tab=coef_cell{7}; % log(1000*resistance))
B2c_tab=coef_cell{8}; % log(1000*resistance))
B1d_tab=coef_cell{9}; % log(1000*resistance))
B2d_tab=coef_cell{10}; % log(1000*resistance))

V0_tab=ocv_coef_mat(:,1);
alpha_tab=ocv_coef_mat(:,2);
beta_tab=ocv_coef_mat(:,3);
gamma_tab=ocv_coef_mat(:,4);
zeta_tab=ocv_coef_mat(:,5);
epsilon_tab=ocv_coef_mat(:,6);

% plot these coefficients
plotit=0;
if plotit
    for i=1:10
        figure(i);
        mesh(SOC_tab, T_tab, coef_cell{i}');
        xlabel('SOC')
        ylabel('Temperature')
    end
    
    for j=1:6
        figure(i+j)
        plot(T_tab, ocv_coef_mat(:,j));
        xlabel('Temperature')
    end
end        

%% load set-to-85 dataset to find the initial state of charge
% also load the battery capacity information
disp('setting other battery parameters and initial conditions ...')
disp('loading set to 85% data ...')
% uiload

current_setto85=2.12;
chg_segment=current_setto85(current_setto85>1);
init_cap=polyval(cap_coef, temp);
init_ah=init_cap-sum(chg_segment*0.1/3600);
init_soc= 0.15;

%% define initial conditions
init_v1=0.0;
init_v2=0.0;
current_thresh=0.5;
disp('done')

%% simulate the model
%sim('mt_batt_model')
