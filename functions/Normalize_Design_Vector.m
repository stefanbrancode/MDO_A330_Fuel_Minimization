function x_normalized = Normalize_Design_Vector(x,lb,ub)
x_normalized = (x - lb) ./ (ub - lb);
end