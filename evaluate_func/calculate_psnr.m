function psnr = calculate_psnr(I,J)
  
    M = size(I,1);
    N = size(I,2);
    dif = (I - J).^2;
    val = sum(sum(dif));
    mse = val / (M*N);

    psnr = 10*log10(1/mse);
    
end