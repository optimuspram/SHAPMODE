function mask = create_mask_arrays(k)
    mask = dec2bin(0:(2^k)-1) - '0';
    mask = mask(~all(mask == 0, 2), :);
    mask = mask(~all(mask == 1, 2), :);
end