function Y = fourbar_f2(X)
% Use this function to evaluate the fourbar function
% The response is the displacement of the system
% Input:  X - Sampling points
% Output: Y - Responses

n = size(X,1); % Number of samples
Y = zeros(n,1); % Initiate responses

F = 10; % load
E = 2e5; % Elastic modulus
L = 200; % Length of a truss section
sig = 10; % Characteristic stress

% Evaluate the responses
for ii = 1:n
    x = X(ii,:); x1 = x(1); x2 = x(2); x3 = x(3); x4 = x(4);
    Y(ii,1) = (F*L/E)*((2/x1)+(2*sqrt(2)/x2)-(2*sqrt(2)/x3)+(2/x4));
end


