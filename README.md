# ACF_for_seismic_denoising
## This version of the code is mainly used for reviewing purposes. 

#### **Environment**

1. Matlab R2024a on Apple Silicon
2. Pytorch for mps device

#### Project Structure

```
filetree 
├── README.md
├── data
│  ├── /line1/  % Results of research Line 1
│  ├── /line2/  % Results of research Line 2
│  ├── /line3/  % Results of research Line 3
│  ├── /line4/  % Results of research Line 4
│  └── /in/     % Raw data of research Lines
├── ./evaluate_func/  % Evaluate functions  
├── ./matlab_func/    % Matlab functions 
├── ./python_code/    % The python code of Adaptive Convolutional Filter 
└── main.m      % Processing data (matlab -> shell -> running python code -> matlab)
```
