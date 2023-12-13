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

%% Create a GPR metamodel
% Define input variables
for im=1:nvar
    InputOptsN.Marginals(im).Type = 'Uniform'; % Uniform distribution
    InputOptsN.Marginals(im).Parameters =  [lb(im) ub(im)]; % Distribution parameters
end
myInputN = uq_createInput(InputOptsN); % Create the input structure

XS = uq_getSample(nsamp, 'LHS'); % Latin hypercube sampling
Y = fourbar(XS); % Responses at XS

nval = 1e4;
XVAL= uq_getSample(nval, 'LHS'); % Validation samples
YTRUE = fourbar(XVAL); % Actual responses at validation samples

err_rmse = zeros(1,2); % Initiate RMSE error
err_nrmse = zeros(1,2); % Initiate normalized RMSE error
err_loocv = zeros(1,2); % Initiate LOOCV error

% For Sobol indices analysis
SobolSensOpts.Type = 'Sensitivity';
SobolSensOpts.Method = 'Sobol';
SobolSensOpts.Sobol.Sampling = 'LHS';
SobolSensOpts.Sobol.Order = 2;
SobolSensOpts.Sobol.SampleSize = 1e4;

% Create GPR metamodel for the two responses
for II = 1:2
    MetaGPR.Type = 'Metamodel';
    MetaGPR.ExpDesign.X = XS;
    MetaGPR.ExpDesign.Y = Y(:,II);
    MetaGPR.MetaType = 'Kriging';
    MetaGPR.EstimMethod = 'ML';
    MetaGPR.Optim.Method = 'HCMAES';
    MetaGPR.Optim.HCMAES.nPop= 100;
    MetaGpr.Optim.MaxIter = 5000;
    MetaGPR.Optim.HCMAES.nStall= 100;
    myGPR{II} = uq_createModel(MetaGPR); % Construct GPR

    % Calculate errors
    err_loocv(II) = myGPR{II}.Error.LOO; % LOOCV errors
    ypred(:,II) = uq_evalModel(myGPR{II},XVAL); % Predictions
    err = ypred(:,II)-YTRUE(:,II); % Error
    err_rmse(II) = sqrt(mean(err.^2)); % RMSE
    err_nrmse(II) = err_rmse(II)/iqr(YTRUE(:,II)); % Normalized RMSE

    % Perform Sobol indices analysis
    SobolAnalysis{II} = uq_createAnalysis(SobolSensOpts);
end

% Extract the total Sobol indices
SobTot(:,1) = SobolAnalysis{1}.Results.Total;
SobTot(:,2) = SobolAnalysis{2}.Results.Total;

%% Perform SHAP analysis
nshap = 1e4; % Samples for SHAP calculation
XSHAP = uq_getSample(nshap, 'LHS'); 

% SHAP for the first objective
func = @(x) uq_evalModel(myGPR{1},x);
SHAP_f1 = KERNEL_SHAP(func, XSHAP,x_center);

% SHAP for the second objective
func = @(x) uq_evalModel(myGPR{2},x);
SHAP_f2 = KERNEL_SHAP(func, XSHAP,x_center);


%% Compute the average SHAP values
SHAP_f1_ave = mean(abs(SHAP_f1));
SHAP_f2_ave = mean(abs(SHAP_f2));

%% Plotting
nplot = 100;
% Plot the dependence plot in the normalized input for f1
plotSHAP_normalized(XSHAP,SHAP_f1,lb,ub,varnames,[1:4],100);

% Plot the dependence plot in the normalized input for f2
plotSHAP_normalized(XSHAP,SHAP_f2,lb,ub,varnames,[1:4],100);

% Averaged SHAP bar plot for f1
plotSHAP_main(XSHAP,SHAP_f1, lb,ub,varnames,[1:4],nplot); % Create averaged SHAP bar plot and summary plot

% Averaged SHAP bar plot for f2
plotSHAP_main(XSHAP,SHAP_f2, lb,ub,varnames,[1:4],nplot); % Create averaged SHAP bar plot and summary plot

% Bi-objective SHAP dependence plot for x1
idx = 1; 
plotSHAP_biobjective(SHAP_f1,SHAP_f2,XSHAP,idx,nplot,objlab,varnames,SHAP_f1_ave,SHAP_f2_ave);

% Bi-objective SHAP dependence plot for x3
idx = 3;
plotSHAP_biobjective(SHAP_f1,SHAP_f2,XSHAP,idx,nplot,objlab,varnames,SHAP_f1_ave,SHAP_f2_ave);


% Generate the SHAP correlation matrix
plotSHAP_correlation_matrix(XSHAP, SHAP_f1,SHAP_f2,varnames,SHAP_f1_ave,SHAP_f2_ave,'spearman');
