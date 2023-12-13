clc;
clear all;
close all;

uqlab % Initialize uqlab

%% Initialization
F = 10; % load
E = 2e5; % Elastic modulus
L = 200; % Length of a truss section
sig = 10; % Characteristic stress
Fbs = F/sig; % To determine lower and upper bounds

lb = [Fbs sqrt(2)*Fbs sqrt(2)*Fbs Fbs]; % Lower bound
ub = [3*Fbs 3*Fbs 3*Fbs 3*Fbs]; % Upper bound
nvar = 4; % Number of variables
nsamp = 200; % Number of samples

x_center = (ub+lb)/2; % Center of the input space (for SHAP calculation)
varnames = {'x_{1}','x_{2}','x_{3}','x_{4}'};
objlab = {'f_{1}','f_{2}'};

%% Perform SHAP analysis
nshap = 1e4; % Samples for SHAP calculation
XSHAP = rand(nshap,nvar);

XSHAP_scaled = rescale(XSHAP,lb,ub);

% SHAP for the first objective
func = @(x) fourbar_f1(x);
SHAP_f1 = KERNEL_SHAP(func, XSHAP_scaled,x_center);

% SHAP for the second objective
func = @(x) fourbar_f2(x);
SHAP_f2 = KERNEL_SHAP(func, XSHAP_scaled,x_center);

%% Compute the average SHAP values
SHAP_f1_ave = mean(abs(SHAP_f1));
SHAP_f2_ave = mean(abs(SHAP_f2));

%% Plotting
nplot = 100;
% Plot the dependence plot in the normalized input for f1
plotSHAP_normalized(XSHAP_scaled,SHAP_f1,lb,ub,varnames,[1:4],100);

% Plot the dependence plot in the normalized input for f2
plotSHAP_normalized(XSHAP_scaled,SHAP_f2,lb,ub,varnames,[1:4],100);

% Averaged SHAP bar plot for f1
plotSHAP_main(XSHAP_scaled,SHAP_f1, lb,ub,varnames,[1:4],nplot); % Create averaged SHAP bar plot and summary plot

% Averaged SHAP bar plot for f2
plotSHAP_main(XSHAP_scaled,SHAP_f2, lb,ub,varnames,[1:4],nplot); % Create averaged SHAP bar plot and summary plot

% Bi-objective SHAP dependence plot for x1
idx = 1; 
plotSHAP_biobjective(SHAP_f1,SHAP_f2,XSHAP_scaled,idx,nplot,objlab,varnames,SHAP_f1_ave,SHAP_f2_ave);

% Bi-objective SHAP dependence plot for x3
idx = 3;
plotSHAP_biobjective(SHAP_f1,SHAP_f2,XSHAP_scaled,idx,nplot,objlab,varnames,SHAP_f1_ave,SHAP_f2_ave);

% Generate the SHAP correlation matrix
plotSHAP_correlation_matrix(XSHAP_scaled, SHAP_f1,SHAP_f2,varnames,SHAP_f1_ave,SHAP_f2_ave,'spearman');
