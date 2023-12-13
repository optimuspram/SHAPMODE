function [SHAP,y_c] = KERNEL_SHAP(func, XQ,x_center)

% Input:
% func - ML / surrogate model of interest, the model should takes only the
%        input variables and output the response
% XQ   - Samples for the SHAP to be calculated
% x_center - Center of the design space

% Outputs:
% SHAP - Computed SHAP values from KernelSHAP

nsamp = size(XQ,1); % Number of prediction samples
nvar = size(XQ,2); % Number of variables

mask = create_mask_arrays(nvar); % Create mask
y_c = func(x_center); % Prediction at the center
X = mask; % For weighted least squares

% Calculate weight
for ii = 1:size(mask,1)
    weight(ii,:) = calculate_weight(mask(ii,:));
end


%% Loop over samples
for ns = 1:size(XQ,1)
    xin = XQ(ns,:);

    S_with_zero = mask.*xin;
    % Create full S
    S_full = (S_with_zero == 0).*repmat(x_center,size(S_with_zero,1),1) + S_with_zero;

    % Implement matrix solution
    y = func(S_full);

    W = diag(weight);
    y = y-y_c;

    % Calculate SHAP
    SHAP(ns,:) = (X.' * W * X) \ (X.' * W * y);
end


