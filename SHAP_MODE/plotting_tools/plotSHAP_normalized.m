function plotSHAP_normalized(XSHAP,SHAP,lb,ub,varnames,vars,nplot)
% plotSHAP_normalized generates the single-output SHAP dependence plots for
% all variables in the normalized input space
% Input : 
%       XSHAP - Samples for plotting the SHAP
%       SHAP - The corresponding SHAP values for XSHAP
%       lb - Lower bounds of the input variables
%       ub - Upper bounds of the input variables
%       varnames - Variable names, should follow the original naming
%       vars - Index of variables to display on the plot.
%       nplot - Number of samples to display on the plot.

nvar = size(XSHAP,2); % Number of variables

% Normalize to [-1,1]
XSHAP_norm = (rescale(XSHAP,"InputMin",lb,"InputMax",ub)-0.5)*2; 

%% Colors, markers, linestyles
% The colors only up to seven variables, please change according to your
% needs and if you more than seven variables
colors = {'b','g','r','k','c','m','y'};
markers = {'o','+','*','s','d','v','>','h'};

%% Plot
figure()
for ii = 1:length(vars)
    idvar = vars(ii);
    scatter(XSHAP_norm(1:nplot,idvar),SHAP(1:nplot,idvar),'MarkerEdgeColor', colors{ii}, 'Marker', markers{ii});
    hold on
end
hold off

for ii = 1:nvar
    varnames{ii} = strcat(['$',varnames{ii},'$']); % For latex interpreter
end
legend(varnames(vars),'interpreter','latex','FontSize',14);
set(gcf,'color','w');
set(gcf,'position',[200 300 400 300]);
xlabel('$x$ (normalized)','interpreter','latex','FontSize',14);
ylabel('$\phi$','interpreter','latex','FontSize',14);
set(gca,'TickLabelInterpreter','latex','FontSize',14);
grid on
box on
