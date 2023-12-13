function plotSHAP_main(XSHAP,SHAP, lb, ub, varnames,vars,nplot)
% plotSHAP_main creates the SHAP summary plot and the barplot of the averaged SHAP
% Input: 
%       XSHAP - Samples for plotting the SHAP
%       SHAP  - The corresponding SHAP values for XSHAP
%       lb    - Lower bound of the XSHAP for normalization in the plot
%       ub    - Upper bound of the XSHAP for normalization in the plot
%       varnames - Variable names, should follow the original naming
%       vars - Index of variables to display on the plot.
%       nplot - Number of samples to display on the plot.

%% Create the SHAP summary plot
figure()
nvar = size(SHAP,2); % Number of input variables

% Normalizd to [-1,1]
XSHAP_norm = (rescale(XSHAP,"InputMin",lb,"InputMax",ub)-0.5)*2;

% Generate the SHAP summary plot
for ii = 1:length(vars)
    idvar = vars(ii);
    jj = length(vars)+1;
    scatter(SHAP(1:nplot,idvar),ones(nplot,1)*(jj-ii),[],XSHAP_norm(1:nplot,idvar),'filled');
    hold on
end

% For latex interpreter
for ii = 1:nvar
    varnames{ii} = strcat(['$',varnames{ii},'$']); 
end

xlabel('$\phi$','interpreter','latex','FontSize',12);
ylabel('Variable','interpreter','latex','FontSize',12);
set(gcf,'color','w');
set(gcf,'position',[200 300 450 350]);
title('Colored by input values','FontSize',14)
grid on
box on
set(gca,'ytick',[1:length(vars)])
set(gca,'yticklabels',fliplr(varnames(vars)))
colorbar('Ticks',[min(XSHAP_norm(1:nplot)), max(XSHAP_norm(1:nplot))],'TickLabels',{'Low','High'});
set(gca,'TickLabelInterpreter','latex','FontSize',14);
hold off

%% Create the averaged SHAP bar plot
figure()
SHAP_ave = mean(abs(SHAP(:,vars)));
bar(SHAP_ave);

xlabel('Variable','interpreter','latex','FontSize',12);
ylabel('$\bar{\phi}$','interpreter','latex','FontSize',12);
set(gcf,'color','w');
set(gcf,'position',[200 300 450 350]);
grid on
box on
set(gca,'xtick',[1:length(vars)])
set(gca,'xticklabels',varnames(vars))
set(gca,'TickLabelInterpreter','latex','FontSize',14);
axis([0.5,length(vars)+0.5,0,max(SHAP_ave(:))])