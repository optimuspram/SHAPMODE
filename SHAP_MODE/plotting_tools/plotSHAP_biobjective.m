function plotSHAP_biobjective(SHAP_f1,SHAP_f2,XSHAP,ID1,nplot,objlab,varnames,SHAP_f1_ave,SHAP_f2_ave)
% plotSHAP_biobjective generates the bi-objective SHAP dependence plot for
% an input variable
% Input : 
%       XSHAP - Samples for plotting the SHAP
%       SHAP_f1  - The corresponding SHAP values for XSHAP, first output
%       SHAP_f2  - The corresponding SHAP values for XSHAP, second output
%       ID1 - Index of the input variable to be plotted
%       varnames - Variable names, should follow the original naming
%       SHAP_f1_ave - Averaged SHAP values for the first output
%       SHAP_f1_ave - Averaged SHAP values for the second output
%       vars - Index of variables to display on the plot.
%       nplot - Number of samples to display on the plot.

%% Plot the SHAP values
figure()
scatter(SHAP_f1(1:nplot,ID1),SHAP_f2(1:nplot,ID1),[],XSHAP(1:nplot,ID1),'filled'); box on;

% Labelling
texts1 = strcat(['$\phi_{',varnames{ID1},'},',objlab{1},'$']);
xlabel(texts1,'interpreter','latex','FontSize',12);

texts2 = strcat(['$\phi_{',varnames{ID1},'},',objlab{2},'$']);
ylabel(texts2,'interpreter','latex','FontSize',12);

set(gcf,'color','w');
set(gcf,'position',[200 300 450 350]);
texts = strcat(['Colored by $',varnames{ID1},'$']);
title(texts,'FontSize',14,'interpreter','latex','FontSize',12)
grid on
box on
colorbar('Ticks',[min(XSHAP(1:nplot,ID1)), max(XSHAP(1:nplot,ID1))],'TickLabels',{'Low','High'});
set(gca,'TickLabelInterpreter','latex','FontSize',14);

%% Show the correlation values
pcor = corr(SHAP_f1(:,ID1),SHAP_f2(:,ID1),'Type','Pearson');
texts = strcat('$\rho = ',num2str(pcor,2),'$');
text(0.1,0.9,texts,'FontSize',14,'interpreter','latex','FontSize',14,'Units','normalized');

scor = corr(SHAP_f1(:,ID1),SHAP_f2(:,ID1),'Type','Spearman');
texts = strcat('$r = ',num2str(scor,2),'$');
text(0.1,0.8,texts,'FontSize',14,'interpreter','latex','FontSize',14,'Units','normalized');

%% Create the inset figure for the averaged SHAP relative magnitude
axes('Position',[.3 .55 .15 .15])

avgshr1 = SHAP_f1_ave./max(SHAP_f1_ave);
avgshr2 = SHAP_f2_ave./max(SHAP_f2_ave);

avgr1 = avgshr1(ID1);
avgr2 = avgshr2(ID1);

b = barh([1,2],[1,1],'white');
b.EdgeColor = [.63 .08 .18];
b.LineWidth = 2;

hold on
b = barh([1,2],[avgr1,avgr2],'blue');
set(gca,'xtick',[])
set(gca,'yticklabels',{texts1,texts2})
set(gca,'TickLabelInterpreter','latex','FontSize',14);
axis([0 1.1 0.5 2.5]);
set(gcf,'position',[200 300 450 350]);
set(gcf,'color','w');
hold off