clc;
clear all;
close all;

uqlab % Initialize uqlab

load Airfoil_Viscous_data X ff % Load data

nvar = 20; % Number of variables
nsamp = size(X,1); % Number of samples
lb = -0.003*(ones(1,nvar)); % Lower bound
ub = 0.003*(ones(1,nvar)); % Upper bound
lb_n = ones(1,nvar)*-1; % Normalized lower bound (to [-1,1]^{nvar})
ub_n = ones(1,nvar)*1; % Normalized upper bound (to [-1,1]^{nvar})

% Variable names
for ii = 1:nvar
    var = strcat(['x_{',num2str(ii),'}']);
    varnames{ii} = var;
end

% Objective names
objlab = {'C_{d}','|C_{m}|'};

% Normalize X into [-1,1], the normalized space is used to build the GPR
% metamodel
X_norm   =  (rescale(X,"InputMin",lb,"InputMax",ub)-0.5)*2;
x_center = zeros(1,nvar); % Center of the input space (for SHAP calculation)

%% Define input
for im=1:nvar
    InputOptsN.Marginals(im).Type = 'Uniform'; % Kernel density
    InputOptsN.Marginals(im).Parameters =  [lb_n(im) ub_n(im)]; % Samples for density estimation
end
myInputN = uq_createInput(InputOptsN);

err_loocv = zeros(1,2); % Initiate LOOCV error

% For Sobol indices analysis
SobolSensOpts.Type = 'Sensitivity';
SobolSensOpts.Method = 'Sobol';
SobolSensOpts.Sobol.Sampling = 'LHS';
SobolSensOpts.Sobol.Order = 2;
SobolSensOpts.Sobol.SampleSize = 1e4;

%% PC KRIG
for II = 1:2
    MetaPCKrig.Type = 'Metamodel';
    MetaPCKrig.MetaType = 'PCK';
    MetaPCKrig.ExpDesign.X = X_norm;
    MetaPCKrig.ExpDesign.Y = ff(:,II);
    MetaPCKrig.Kriging.EstimMethod = 'ML';
    MetaPCKrig.Optim.Method = 'HCMAES';
    MetaPCKrig.Mode = 'optimal';
    MetaPCKrig.Optim.HCMAES.nPop= 100;
    MetaPCKrig.Optim.HCMAES.nStall= 100;
    MetaPCKrig.PCE.Degree = [1:2];
    MetaPCKrig.PCE.TruncOptions.qNorm = [1];

    myPCKrig{II} = uq_createModel(MetaPCKrig);

     % Calculate LOOCV error
    err_loocv(II) = myPCKrig{II}.Error.LOO;
    SobolAnalysis{II} = uq_createAnalysis(SobolSensOpts);
end

% Extract the total Sobol indices
SobTot(:,1) = SobolAnalysis{1}.Results.Total;
SobTot(:,2) = SobolAnalysis{2}.Results.Total;


%% Perform SHAP analysis
nshap = 1e3; % Samples for SHAP calculation
XSHAP = uq_getSample(nshap,'Sobol'); % Generate samples for SHAP

SHAP_f1 = zeros(nshap,nvar);
SHAP_f2 = zeros(nshap,nvar);

% SHAP calculation
% Note: Using 'KERNEL_SHAP.m' is too expensive, which is why we use
% MATLAB's 'shapley.m' to estimate the Shapley values
func = @(x) uq_evalModel(myPCKrig{1},x);
for ii = 1:nshap
    explainer = shapley(func,X,'QueryPoint',XSHAP(ii,:));
    SHAP_f1(ii,:) = (table2array(explainer.ShapleyValues(:,2)))';
end

func = @(x) uq_evalModel(myPCKrig{2},x);
for ii = 1:nshap
    explainer = shapley(func,X,'QueryPoint',XSHAP(ii,:));
    SHAP_f2(ii,:) = (table2array(explainer.ShapleyValues(:,2)))';
end

%% Compute the average SHAP values
SHAP_f1_ave = mean(abs(SHAP_f1));
SHAP_f2_ave = mean(abs(SHAP_f2));

%% Plotting
% Create averaged SHAP bar plot and summary plot for f1
plotSHAP_main(XSHAP,SHAP_f1, lb_n,ub_n,varnames,[1:nvar],100);

% Create averaged SHAP bar plot and summary plot for f2
plotSHAP_main(XSHAP,SHAP_f2, lb_n,ub_n,varnames,[1:nvar],100)

% SHAP dependence plot for x4, CL
idx = 4;
nplot = 100; % Number of samples for plotting
plotSHAP_dependence_plot(XSHAP,SHAP_f1,idx,SobolAnalysis{1},nplot,objlab{1},varnames,SHAP_f1_ave);
% for CD
plotSHAP_dependence_plot(XSHAP,SHAP_f2,idx,SobolAnalysis{2},nplot,objlab{2},varnames,SHAP_f2_ave);
% Bi-objective plot
plotSHAP_biobjective(SHAP_f1,SHAP_f2,XSHAP,idx,nplot,objlab,varnames,SHAP_f1_ave,SHAP_f2_ave);

% Note: The function above takes the index with the strongest interaction
% from 'SobolAnalysis'. You can change it to the index of the other
% variable.

% Plot SHAP correlation matrix
 plotSHAP_correlation_matrix(XSHAP, SHAP_f1,SHAP_f2,varnames,SHAP_f1_ave,SHAP_f2_ave,'spearman');