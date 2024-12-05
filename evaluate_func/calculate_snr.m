function snr = calculate_snr(I,J)
   
    dim = length(size(I));
    M = size(I,1);
    N = size(I,2);
    dif = (I - J).^2;
    I_2 = I.^2;
    if dim == 2
        val1 = sum(sum(dif));
        val2 = sum(sum(I_2));
    else 
        val1 = sum(sum(sum(dif)));
        val2 = sum(sum(sum(I_2)));
    end
    snr = 10*log10(val2./val1);
end
