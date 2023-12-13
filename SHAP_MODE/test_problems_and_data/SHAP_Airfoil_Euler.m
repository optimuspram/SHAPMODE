clc;
clear all;
close all;

uqlab % Initialize UQlab

load Airfoil_Euler_data X ff % Load data

nsamp = size(X,1); % Number of samples
nvar = size(X,2); % Number of variables

% Lower and upper bounds
lb = [0.0065 0.3466 0.0503 -0.5094 0.2894 -0.0707 0.5655 -0.1351 0.1317];
ub = [0.0092 0.5198 0.0755 -0.3396 0.4342 -0.0471 0.8483 -0.0901 0.1975];

varnames = {'r_{LE}','x_{up}','y_{up}','y_{xx_{up}}','x_{lo}','y_{lo}'...
    ,'y_{xx_{lo}}','\alpha_{TE}','\beta_{TE}'};
 objlab = {'C_{l}','C_{d}'}; % Objective labels

% Normalize X into [-1,1], the normalized space is used to build the GPR
% metamodel
X_norm   =  (rescale(X,"InputMin",lb,"InputMax",ub)-0.5)*2;

%% Create a GPR metamodel
% Define input variables (normalize to [-1,1] first), for this problem, the
% GPR model is constructed in this normalized space
lb_n = ones(1,nvar)*-1; % Normalized lower bounds
ub_n = ones(1,nvar)*1; % Normalize upper bounds

for im=1:nvar
    InputOptsN.Marginals(im).Type = 'Uniform'; % Uniform distribution
    InputOptsN.Marginals(im).Parameters =  [lb_n(im), ub_n(im)]; % Distribution parameters
end
myInputN = uq_createInput(InputOptsN);

err_rmse = zeros(1,2); % Initiate RMSE error
err_nrmse = zeros(1,2); % Initiate normalized RMSE error
err_loocv = zeros(1,2); % Initiate LOOCV error

% For Sobol indices analysis
SobolSensOpts.Type = 'Sensitivity';
SobolSensOpts.Method = 'Sobol';
SobolSensOpts.Sobol.Sampling = 'Sobol';
SobolSensOpts.Sobol.Order = 2;
SobolSensOpts.Sobol.SampleSize = 1e3;

% Create GPR metamodel for the two responses
for II = 1:2
    MetaGPR.Type = 'Metamodel';
    MetaGPR.ExpDesign.X = X_norm;
    MetaGPR.ExpDesign.Y = ff(:,II);
    MetaGPR.MetaType = 'Kriging';
    MetaGPR.EstimMethod = 'ML';
    MetaGPR.Regression.SigmaNSQ = 'auto';
    MetaGPR.Optim.Method = 'HCMAES';
    MetaGPR.Optim.HCMAES.nPop= 100;
    MetaGpr.Optim.MaxIter = 5000;
    MetaGPR.Optim.HCMAES.nStall= 100;
    myGPR{II} = uq_createModel(MetaGPR);

    % Calculate LOOCV error
    err_loocv(II) = myGPR{II}.Error.LOO;

    % Perform Sobol indices analysis
    SobolAnalysis{II} = uq_createAnalysis(SobolSensOpts);
end

% Extract the total Sobol indices
SobTot(:,1) = SobolAnalysis{1}.Results.Total;
SobTot(:,2) = SobolAnalysis{2}.Results.Total;

%% Perform SHAP analysis
nshap = 500; % Samples for SHAP calculation
XSHAP = uq_getSample(nshap, 'Sobol');; % Take samples from validation samples

% Center of the input space (for SHAP calculation)
x_center = zeros(1,nvar);

% Calculate SHAP for CL using KERNEL_SHAP
func = @(x) uq_evalModel(myGPR{1},x);
SHAP_f1 = KERNEL_SHAP(func, XSHAP,x_center);

% Calculate SHAP for CD using KERNEL_SHAP
func = @(x) uq_evalModel(myGPR{2},x);
SHAP_f2 = KERNEL_SHAP(func, XSHAP,x_center);

%% Compute the average SHAP values
SHAP_f1_ave = mean(abs(SHAP_f1));
SHAP_f2_ave = mean(abs(SHAP_f2));

%% Plotting
% Create averaged SHAP bar plot and summary plot for f1
plotSHAP_main(XSHAP,SHAP_f1, lb_n,ub_n,varnames,[1:9],100);

% Create averaged SHAP bar plot and summary plot for f2
plotSHAP_main(XSHAP,SHAP_f2, lb_n,ub_n,varnames,[1:9],100);

% SHAP dependence plot for y_up (Cl and Cd)
idx = 3; % yup
idx2 = 2; % For interaction with xup
nplot = 400; % Number of samples to plot
plotSHAP_dependence_plot(XSHAP,SHAP_f1,idx,idx2,nplot,objlab{1},varnames,SHAP_f1_ave);
plotSHAP_dependence_plot(XSHAP,SHAP_f2,idx,idx2,nplot,objlab{2},varnames,SHAP_f2_ave);
plotSHAP_biobjective(SHAP_f1,SHAP_f2,XSHAP,idx,nplot,objlab,varnames,SHAP_f1_ave,SHAP_f2_ave);

% Note: You can change 'idx' for trying other variables.