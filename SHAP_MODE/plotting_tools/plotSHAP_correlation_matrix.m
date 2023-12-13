function plotSHAP_correlation_matrix(XSHAP, SHAP_f1,SHAP_f2,varnames,SHAP_f1_ave,SHAP_f2_ave,cortype)

nvar = size(XSHAP,2);
%% Calculate correlation matrix
PEA = zeros(nvar,3); % Initialize Pearson correlation matrix 
SPE = zeros(nvar,3); % Initialize Spearman correlation matrix 

% Generate correlation matrix
for ii = 1:nvar
    PEA(ii,1) = corr(XSHAP(:,ii),SHAP_f1(:,ii),'type','pearson');
    SPE(ii,1) = corr(XSHAP(:,ii),SHAP_f1(:,ii),'type','spearman');
    PEA(ii,2) = corr(XSHAP(:,ii),SHAP_f2(:,ii),'type','pearson');
    SPE(ii,2) = corr(XSHAP(:,ii),SHAP_f2(:,ii),'type','spearman');
    PEA(ii,3) = corr(SHAP_f1(:,ii),SHAP_f2(:,ii),'type','pearson');
    SPE(ii,3) = corr(SHAP_f1(:,ii),SHAP_f2(:,ii),'type','spearman');
end

if strcmp(cortype,'pearson');
    corval = PEA;
elseif strcmp(cortype,'spearman');
    corval = SPE;
end
% For latex interpreter
for ii = 1:nvar
    varnames{ii} = strcat(['$',varnames{ii},'$']); 
end

%% Generate correlation matrix plot
figure()
%% Correlation between inputs and SHAP for f1
subplot(1,6,1);
n = size(corval,1);
r = (rescale(corval(:,1),"InputMin",[-1]',"InputMax",[1]')-0.5)*2;
I = imagesc(r);

hold on;
for i = 1:n+1
   plot([.5,n+0.5],[i-.5,i-.5],'k-');
   plot([i-.5,i-.5],[.5,n+0.5],'k-');
end

set(gca,'TickLabelInterpreter','latex','FontSize',8);

if strcmp(cortype,'pearson');
   title('$\rho_{x,\phi(f_{1})}$','interpreter','Latex','FontSize',14);
elseif strcmp(cortype,'spearman');
   title('$r_{x,\phi(f_{1})}$','interpreter','Latex','FontSize',14);
end



set(gca,'ytick',[1:n],'FontSize',14);
set(gca,'xtick',[]);
set(gca,'YTickLabels',varnames);

pl = linspace(0,1,n+1);
ssize = (pl(2)-pl(1))/2;
SPT = flipud(corval);
for ii = 1:n
    txt = num2str(SPT(ii,1),'%+2.2f');
    if SPT(ii,1) > 0
        text(0.1,pl(ii)+ssize,txt,'Units','Normalized','interpreter','latex','color','black');
    else
        text(0.1,pl(ii)+ssize,txt,'Units','Normalized','interpreter','latex','color','white')
    end
end
set(gca,'TickLength',[0 .01]);
clim([-1 1]);
%% Barplot of the averaged SHAP for f1
subplot(1,6,2);
b = barh(([1:n]),fliplr([SHAP_f1_ave]),'blue');
axis([0 max(SHAP_f1_ave) 0.5 n+0.5])

set(gca,'ytick',[1:n]);
set(gca,'TickLabelInterpreter','latex','FontSize',8);
title('$\bar{\phi}(f_{1})$','interpreter','Latex','FontSize',14);
set(gca,'ytick',[]);
grid on
%% %% Correlation between inputs and SHAP for f2
subplot(1,6,3)
r = (rescale(corval(:,2),"InputMin",[-1]',"InputMax",[1]')-0.5)*2;

imagesc(r);

hold on;
for i = 1:n+1
   plot([.5,n+0.5],[i-.5,i-.5],'k-');
   plot([i-.5,i-.5],[.5,n+0.5],'k-');
end
set(gca,'ytick',[1:n]);
set(gca,'xtick',[]);
set(gca,'TickLabelInterpreter','latex','FontSize',8);

if strcmp(cortype,'pearson');
   title('$\rho_{x,\phi(f_{2})}$','interpreter','Latex','FontSize',14);
elseif strcmp(cortype,'spearman');
   title('$r_{x,\phi(f_{2})}$','interpreter','Latex','FontSize',14);
end


set(gca,'ytick',[])

pl = linspace(0,1,n+1);
ssize = (pl(2)-pl(1))/2;
for ii = 1:n
    txt = num2str(SPT(ii,2),'%+2.2f');
    if SPT(ii,2) > 0
        text(0.1,pl(ii)+ssize,txt,'Units','Normalized','interpreter','latex','color','black');
    else
        text(0.1,pl(ii)+ssize,txt,'Units','Normalized','interpreter','latex','color','white')
    end
end
%% %% Barplot of the averaged SHAP for f2
subplot(1,6,4);
b = barh(([1:n]),fliplr([SHAP_f2_ave]),'blue');
axis([0 max(SHAP_f2_ave) 0.5 n+0.5])

title('$\phi,f_{2}$','interpreter','Latex','FontSize',16);
 set(gca,'ytick',[])
set(gca,'TickLabelInterpreter','latex','FontSize',8);
title('$\bar{\phi}(f_{2})$','interpreter','Latex','FontSize',14);
grid on
%% Correlation between SHAP values for f1 and SHAP values for f2
subplot(1,6,5:6);
r = (rescale(corval(:,3),"InputMin",[-1]',"InputMax",[1]')-0.5)*2;

imagesc(r);

hold on;
for i = 1:n+1
   plot([.5,n+0.5],[i-.5,i-.5],'k-');
   plot([i-.5,i-.5],[.5,n+0.5],'k-');
end
set(gca,'ytick',[1:n]);
set(gca,'xtick',[]);
 set(gca,'ytick',[])
set(gcf,'color','w');

if strcmp(cortype,'pearson');
   title('$\rho_{\phi(f_{1}),\phi(f_{2})}$','interpreter','Latex','FontSize',14);
elseif strcmp(cortype,'spearman');
  title('$r_{\phi(f_{1}),\phi(f_{2})}$','interpreter','Latex','FontSize',14);
end



pl = linspace(0,1,n+1);
ssize = (pl(2)-pl(1))/2;
for ii = 1:n
    txt = num2str(SPT(ii,3),'%+2.2f');
        if SPT(ii,3) > 0
        text(0.1,pl(ii)+ssize,txt,'Units','Normalized','interpreter','latex','color','black');
    else
        text(0.1,pl(ii)+ssize,txt,'Units','Normalized','interpreter','latex','color','white')
    end
end

colorbar