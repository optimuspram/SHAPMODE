function plotSHAP_dependence_plot(XSHAP,SHAP,ID1,intv,nplot,objlab, varnames,SHAP_ave)
% This function generates a SHAP dependence plot for one variable.
% The dots are colored according to the input value of another variable
% Input: 
%       XSHAP - Samples for plotting the SHAP
%       SHAP  - The corresponding SHAP values for XSHAP
%       ID1 - Index of the variable to plot
%       intv - For depicting the interaction. If a single integer indicates 
%              the index of the other variable. If the class is
%              'uq_analysis' (from UQLab), the other variable with the strongest interaction
%              according to 2nd order Sobol indices is automatically chosen           
%       varnames - Variable names
%       SHAP_ave - Averaged SHAP values

% Check if 'intv' is a single integer or 'uq_analysis'
if isa(intv,'uq_analysis')
    seci = intv.Results.AllOrders{2};
    idxseci = intv.Results.VarIdx{2};
    
    [I,~] = find(sum(idxseci == ID1,2) == 1);
    [~,I2] = max(seci(I));
    idx = idxseci(I(I2),:);
    ID2 = idx(idx~=ID1);
else
    ID2 = intv;
end

%% Generate the scatter plot
figure()
scatter(XSHAP(1:nplot,ID1),SHAP(1:nplot,ID1),[],XSHAP(1:nplot,ID2),'filled'); box on;

tx = varnames{ID1};
xlabel(strcat(['$',varnames{ID1},'$']),'interpreter','latex','FontSize',12);
texts = strcat(['$\phi_{',tx,'}$']);
ylabel(texts,'interpreter','latex','FontSize',14);
set(gcf,'color','w');
set(gcf,'position',[200 300 450 350]);

tx = varnames{ID2};
texts = strcat(['Colored by $',tx,'$']);
title(texts,'FontSize',14,'interpreter','latex','FontSize',14);

grid on
box on

set(gca,'TickLabelInterpreter','latex','FontSize',14);
set(gcf,'color','w');
set(gcf,'position',[200 300 450 350]);
colorbar('Ticks',[min(XSHAP(1:nplot,ID2)), max(XSHAP(1:nplot,ID2))],'TickLabels',{'Low','High'});

%% Calculate correlation coefficients
pcor = corr(XSHAP(:,ID1),SHAP(:,ID1),'Type','Pearson');
texts = strcat('$\rho = ',num2str(pcor,2),'$');
text(0.1,0.9,texts,'FontSize',14,'interpreter','latex','FontSize',14,'Units','normalized');

scor = corr(XSHAP(:,ID1),SHAP(:,ID1),'Type','Spearman');
texts = strcat('$r = ',num2str(scor,2),'$');
text(0.1,0.8,texts,'FontSize',14,'interpreter','latex','FontSize',14,'Units','normalized');

%% Generate Inset figure
axes('Position',[.3 .55 .15 .15])

avgshr1 = SHAP_ave./max(SHAP_ave);
avgr1 = avgshr1(ID1);

b = barh(1,1,'white');
b.EdgeColor = [.63 .08 .18];
b.LineWidth = 2;

hold on
b = barh([1],[avgr1],'blue');
set(gca,'xtick',[])
texts1 = strcat(['$\bar{\phi}_{',varnames{ID1},'}$,$',objlab,'$']);
set(gca,'yticklabels',texts1);
set(gca,'TickLabelInterpreter','latex','FontSize',14);
axis([0 1.1 0.5 1.5]);
set(gcf,'position',[200 300 450 350]);
set(gcf,'color','w');
hold off