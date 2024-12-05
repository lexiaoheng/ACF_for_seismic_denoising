function mae = calculate_mae(I,J)
    dim = length(size(I));
    M = size(I,1);
    N = size(I,2);
    dif = abs(I - J);
    if dim == 2
        val = sum(sum(dif));
    else
        val = sum(sum(sum(dif)));
    end
    mae = val / (M*N);
end
