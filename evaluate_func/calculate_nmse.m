function nmse = calculate_nmse(I,J)
    
    dim = length(size(I));
    dif = (I - J).^2;
    I_2 = I.^2;
    if dim == 2
        val1 = sum(sum(dif));
        val2 = sum(sum(I_2));
    else
        val1 = sum(sum(sum(dif)));
        val2 = sum(sum(sum(I_2)));
    end
    nmse = val1/val2;
end
