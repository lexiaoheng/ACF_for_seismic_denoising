function out = calculate_rms(input,output)

noise = input-output;
out = sqrt(mean2(noise.^2));

end