function out = single_process(data,d)
if d == 1 
    device = 'mps';
    [c,h,w]=size(data);
    sigma=0;
    for i=1:1:c
       sigma = sigma+NoiseEstimate(reshape(data(i,:,:),[h,w]))^2;
    end 
    sigma = sigma/c;
    downsample = 1;
    save('./config.mat','device','downsample','sigma'); % save configs
else 
    if d == 0
        device = 'mps';
        sigma = NoiseEstimate(data)^2;
        downsample = 0;
        save('./config.mat','device','downsample','sigma'); % save configs
    end
end

save('./python_code/in/1.mat','data'); 
system('cd ./python_code/ & /opt/anaconda3/envs/deeplearning/bin/python ./python_code/matlab_api.py');
load python_code/out/1.mat;

out = data;

end