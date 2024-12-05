function delta=NoiseEstimate(data,d)

% An Efficient Statistical Method for Image Noise Level Estimation
% Guangyong Chen1, Fengyuan Zhu1, and Pheng Ann Heng1,2

data=squeeze(data);
SizeM=size(data);

if nargin<2
d=9;
end

% patch分割
X=zeros((SizeM(1)-d)*(SizeM(2)-d),d^2);
for i=1:d
    for j=1:d
        F=data(i:SizeM(1)-d+i-1,j:SizeM(2)-d+j-1);
        X(:,j+(i-1)*d)=F(:);
    end
end
delta=NoiseLevel(X);
end

%%
function delta=NoiseLevel(X)
[~,mm]=size(X);
%% 求协方差矩阵
F=cov(X);
%% 求协方差矩阵的特征值并降序排列
[~,D]=eig(F);
D=real(diag(D));
D=sort(D,'descend');
%% 估计噪声大小
for ii=1:mm
t=sum(D(ii:mm))/(mm+1-ii);
F=floor((mm+ii)/2);
F1=F-1;
F2=min(F+1,mm);
if (t<=D(F1))&&(t>=D(F2))
delta=sqrt(t);
break;
end
end
end