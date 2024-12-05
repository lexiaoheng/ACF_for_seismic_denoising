function  data = iteration(indata,scale)

fprintf('processing origin scale: 1/2 \n');
indata = single_process(indata,0);
%%
for i=1:1:scale-1
    fprintf('processing downsampling %dx scale. \n',2^i);
    indata = down_sampling(indata,'downsmp');
    indata = single_process(indata,1);
end

for i=1:1:scale-1
    if i<scale-1
        fprintf('processing upsampling %dx scale. \n',2^(scale-i-1));
        indata = down_sampling(indata,'reverse');
    else
        indata = down_sampling(indata,'reverse');
    end
end

%%
fprintf('processing origin scale: 2/2\n');
data=single_process(indata,0);
% data = indata;
delete('./config.mat');
delete('./python_code/in/*.mat');
delete('./python_code/out/*.mat');
end
% function  [data, dataset_label] = iteration(indata,num)
% 
% [h, w]=size(indata);
% fprintf('Building dataset. \n');
% dataset_label = single_process(indata,0);
% Noise_level = sqrt(NoiseEstimate(indata)^2-NoiseEstimate(dataset_label)^2);
% %%
% fprintf('Processing on dataset. \n');
% dataset = zeros([num+1,h,w]);
% dataset(1,:,:) = indata;
% for i=2:1:num+1
%     dataset(i,:,:) = dataset_label + Noise_level*randn([h,w]);
% end
% indata = single_process(dataset,1);
% %%
% data = reshape(sum(indata,1)./(num+1),[h,w]);
% delete('./config.mat');
% delete('./python_code/in/*.mat');
% delete('./python_code/out/*.mat');
% end