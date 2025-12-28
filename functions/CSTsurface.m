function z = CSTsurface(x, A, N1, N2)
% CSTSURFACE
% Evaluates CST airfoil surface on unit chord

n = length(A) - 1;

% Class function
C = x.^N1 .* (1 - x).^N2;

% Shape function (Bernstein basis)
S = zeros(size(x));
for i = 0:n
    S = S + A(i+1) * nchoosek(n,i) .* x.^i .* (1 - x).^(n - i);
end

z = C .* S;

end
