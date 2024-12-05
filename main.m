clc;
clear all;
addpath('matlab_func/'); % matlab functions
addpath('data/'); % survey lines data
addpath('evaluate_func/'); % matlab functions used to evaluation
addpath('matlab_func/slanCM/'); %colorbar files

%%
linename = 'line1';  % line1, line2, line3
load(strcat('data/in/',linename,'.mat')); %load in data
origin = data;

%% 
mi = min(min(data));
ma = max(max(data));
data = (data-mi)./(ma-mi);

scale = 2;
tic
data = iteration(data,scale); % processing data with python code
toc
data = data*(ma-mi)+mi;

% evaluation
data_loc = localsimi(data,origin-data,[5,5,1],20,0,0);
fprintf('ACF output average local similarity: %f \n',mean2(data_loc));
fprintf('ACF output rms:  %f \n',calculate_rms(origin, data));

%%
c = [-32000 32000];
n = [-10000 10000];
l = [0 1];

subplot(1, 4, 1);
imagesc(origin);
clim(c);
colormap(slanCM('seismic'));

subplot(1, 4, 2);
imagesc(data);
clim(c);
colormap(slanCM('seismic'));

subplot(1, 4, 3);
imagesc(origin-data);
clim(n);
colormap(slanCM('seismic'));

h=subplot(1, 4, 4);
data_loc = localsimi(data,origin-data,[5,5,1],20,0,0);
imagesc(data_loc);
clim(l);
colormap(h,'parula');

%%
delete('./loss.mat');

