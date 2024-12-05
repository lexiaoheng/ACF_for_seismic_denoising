function mse = calculate_mse(I,J)
  
    dim = length(size(I));
    M = size(I,1);
    N = size(I,2);
    dif = (I - J).^2;
    if dim == 2
        val = sum(sum(dif));
    else
        val = sum(sum(sum(dif)));
    end
    mse = val / (M*N);
    
end
