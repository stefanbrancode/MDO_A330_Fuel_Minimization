function x = Denormalize_Design_Vector(x_normalized, lb, ub)
    x = lb + x_normalized .* (ub - lb);
end
