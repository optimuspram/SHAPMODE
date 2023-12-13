function weight = calculate_weight(mask_row)
    M = numel(mask_row); % Number of features
    z = sum(mask_row); % Number of masked feature
    
    weight = (M-1) /  (  nchoosek(M,z) * z * (M-z)   );
end
