function [ simi ] = localsimi(d1,d2,rect,niter,eps,verb)
%  LOCALSIMI: calculate local similarity between two datasets
%
%  IN   d1:   	input data 1
%       d2:     input data 2
%       verb:   verbosity flag (default: 0)
%
%  OUT  simi:  	calculated local similarity, which is of the same size as d1 and d2
%
%  Copyright (C) 2016 Yangkang Chen
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation, either version 3 of the License, or
%  any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details: http://www.gnu.org/licenses/
%
%  Reference:   
%  				1. Chen, Y. and S. Fomel, 2015, Random noise attenuation using local signal-and-noise orthogonalization, Geophysics, , 80, WD1-WD9. (Note that when local similarity is used for noise suppression purposes, this reference must be cited.)
%               2. Local seismic attributes, Fomel, Geophysics, 2007
%
% DEMO
% test_localortho.m 

if nargin<2
    error('Input data 1 and data 2 must be provided!');
end

[n1,n2,n3]=size(d1);

if nargin==2
    rect=ones(3,1);
    if(n1==1) error('data must be a vector or a matrix!');
    else
        rect(1)=20;
    end
    if(n2~=1) rect(2)=10;end
    if(n3~=1) rect(3)=10;end
    niter=50;
    eps=0.0;
    verb=1;
end;

if nargin==3
   niter=50;
   eps=0.0;
   verb=1;
end

if nargin==4
   eps=0.0;
   verb=1;
end

if nargin==5
   verb=1;
end

%eps=0.0;

nd=n1*n2*n3;
ndat=[n1,n2,n3];
eps_dv=eps;
eps_cg=0.1; 
tol_cg=0.000001;
[ ratio ] = str_divne(d2, d1, niter, rect, ndat, eps_dv, eps_cg, tol_cg,verb);
[ ratio1 ] = str_divne(d1, d2, niter, rect, ndat, eps_dv, eps_cg, tol_cg,verb);

simi=sqrt(abs(ratio.*ratio1));
end

function [ rat ] = str_divne(num, den, Niter, rect, ndat, eps_dv, eps_cg, tol_cg,verb)
% str_divne: N-dimensional smooth division rat=num/den          
% This is a subroutine from the seistr package (https://github.com/chenyk1990/seistr)
% 
% BY Yangkang Chen, Hang Wang, and co-authors, 2019
% 
% INPUT
% num: numerator
% den: denominator
% Niter: number of iterations
% rect: triangle radius [ndim]
% ndat: data dimensions [ndim]
% eps_dv: eps for divn  (default: 0.01)
% eps_cg: eps for CG    (default: 1)
% tol_cg: tolerence for CG (default: 0.000001)
% verb: verbosity flag
% 
% OUTPUT
% rat: output ratio
%  
% Reference
% H. Wang, Y. Chen, O. Saad, W. Chen, Y. Oboue, L. Yang, S. Fomel, and Y. Chen, 2021, A Matlab code package for 2D/3D local slope estimation and structural filtering: in press.

t1divne=clock;

n=length(num(:));

%% recommended parameters
% eps_dv=0.01;
% eps_cg=1;we
% tol_cg=0.000001;
% verb=1;
% eps_dv
% eps_cg
% tol_cg

ifhasp0=0;
p=zeros(n,1);

if (eps_dv > 0.0)
    for i = 0 : n-1
        norm = 1.0 / hypot(den(i+1), eps_dv);
        num(i+1) = num(i+1) * norm;
        den(i+1) = den(i+1) * norm;
    end
end

norm=sum(den(:).*den(:));

if ( norm == 0.0)
    rat=zeros(n,1);
    return
end

norm = sqrt(n / norm);

num=num*norm;
den=den*norm;

par_L=struct;
par_L.nm=n;
par_L.nd=n;
par_L.w=den(:);

par_S=struct;
par_S.nm=n;
par_S.nd=n;
par_S.nbox=rect;
par_S.ndat=ndat;
par_S.ndim=3;


[rat ] = str_conjgrad([], @str_weight_lop, @str_trianglen_lop, p, [], num(:), eps_cg, tol_cg, Niter,ifhasp0,[],par_L,par_S,verb);
rat=reshape(rat,ndat(1),ndat(2),ndat(3));

t2divne=clock;

end

function [dout] = str_weight_lop(din,par,adj,add )
% str_weight_lop: Weighting operator (verified)
%
% BY Yangkang Chen, Hang Wang, and co-authors, 2019
%
% INPUT
% din: model/data
% par: parameter
% adj: adj flag
% add: add flag
% OUTPUT
% dout: data/model
%
t1weight=clock;

nm=par.nm;
nd=par.nd;
w=par.w;

if adj==1
    d=din;
    if isfield(par,'m') && add==1
        m=par.m;
    else
        m=zeros(par.nm,1);
    end
else
    m=din;
    if isfield(par,'d') && add==1
        d=par.d;
    else
        d=zeros(par.nd,1);
    end
end

[ m,d ] = str_adjnull( adj,add,nm,nd,m,d );

if adj==1
    m=m+d(:).*w(:);
else %forward
    d=d+m(:).*w(:); %d becomes model, m becomes data
end

if adj==1
    dout=m;
else
    dout=d;
end
t2weight=clock;

end

function [dout] = str_trianglen_lop(din,par,adj,add )
% str_trianglen_lop: N-D triangle smoothing operator (verified)
%
% BY Yangkang Chen, Hang Wang, and co-authors, 2019
%
% INPUT
% din: model/data
% par: parameter
% adj: adj flag
% add: add flag
% OUTPUT
% dout: data/model

t1tri=clock;

if adj==1
    d=din;
    if isfield(par,'m') && add==1
        m=par.m;
    else
        m=zeros(par.nm,1);
    end
else
    m=din;
    if isfield(par,'d') && add==1
        d=par.d;
    else
        d=zeros(par.nd,1);
    end
end

nm=par.nm;     %int
nd=par.nd;     %int
ndim=par.ndim; %int
nbox=par.nbox; %vector[ndim]
ndat=par.ndat; %vector[ndim]

[ m,d ] = str_adjnull( adj,add,nm,nd,m,d );

tr = cell(ndim,1);

s =[1,ndat(1),ndat(1)*ndat(2)];

for i = 0 : ndim-1
    if (nbox(i+1) > 1)
        np = ndat(i+1) + 2*nbox(i+1);
        wt = 1.0 / (nbox(i+1)*nbox(i+1));
        tr{i+1} = struct('nx', ndat(i+1), 'nb', nbox(i+1), 'box', 0, 'np', np, 'wt', wt, 'tmp', zeros(np,1));
    else
        tr{i+1}=[];
    end
end



if adj==1
    tmp=d;
else
    tmp=m;
end


for i=0:ndim-1
    if ~isempty(tr{i+1})
        for j=0:nd/ndat(i+1)-1
            i0=str_first_index(i,j,ndim,ndat,s);
            [tmp,tr{i+1}]=str_smooth2(tr{i+1},i0,s(i+1),0,tmp);
        end
    end
end

if adj==1
    m=m+tmp;
else
    d=d+tmp;
end

if adj==1
    dout=m;
else
    dout=d;
end

t2tri=clock;
end

function [ i0 ] = str_first_index( i, j, dim, n, s )
%% str_first_index: Find first index for multidimensional transforms
%
% BY Yangkang Chen, Hang Wang, and co-authors, 2019
%
% INPUT
% i:    dimension [0...dim-1]
% j:    line coordinate
% dim:  number of dimensions
% n:    box size [dim], vector
% s:    step [dim], vector
% OUTPUT
% i0:   first index

n123 = 1;
i0 = 0;
for k = 0 : dim-1
    if (k == i)
        continue;
    end
    ii = floor(mod((j/n123), n(k+1)));
    n123 = n123 * n(k+1);
    i0 = i0 + ii * s(k+1);
end

end


function [ x , tr ] = str_smooth2( tr, o, d, der, x)
%% str_smooth2: apply triangle smoothing
%
% BY Yangkang Chen, Hang Wang, and co-authors, 2019
%
% INPUT
% tr:   smoothing object
% o:    trace sampling
% d:    trace sampling
% x:    data (smoothed in place)
% der:  if derivative
% OUTPUT
% x: smoothed result
% tr: triangle struct

t1sm=clock;

tr.tmp = triple2(o, d, tr.nx, tr.nb, x, tr.tmp, tr.box, tr.wt);
tr.tmp = doubint2(tr.np, tr.tmp, (tr.box || der));
x = fold2(o, d, tr.nx, tr.nb, tr.np, x, tr.tmp);
t2sm=clock;
end


function [ tmp ] = triple2( o, d, nx, nb, x, tmp, box, wt )
% BY Yangkang Chen, Nov, 04, 2019

t1trp=clock;

for i = 0 : nx+2*nb-1
    tmp(i+1) = 0;
end
if (box)
    tmp(1+1:end)     = cblas_saxpy(nx,  +wt,x(1+o:end),d,tmp(1+1:end),   1); % y += a*x
    tmp(1+2*nb:end)  = cblas_saxpy(nx,  -wt,x(1+o:end),d,tmp(1+2*nb:end),1);
else
    tmp              = cblas_saxpy(nx,  -wt,x(1+o:end),d,tmp,            1); % y += a*x
    tmp(1+nb:end)    = cblas_saxpy(nx,2.*wt,x(1+o:end),d,tmp(1+nb:end),  1);
    tmp(1+2*nb:end)  = cblas_saxpy(nx,  -wt,x(1+o:end),d,tmp(1+2*nb:end),1);
end

t2trp=clock;
end

function [ xx ] = doubint2( nx, xx, der )
% Modified by Yangkang Chen, Nov, 04, 2019
% integrate forward
t = 0.0;
for i = 0 : nx-1
    t = t + xx(i+1);
    xx(i+1) = t;
end


if(der)
    return;
end

% integrate backward
t = 0.0;
for i = nx-1 : -1 : 0
    t = t + xx(i+1);
    xx(i+1) = t;
end


end



function [y] = cblas_saxpy( n, a, x, sx, y, sy )
%% y += a*x
% Modified by Yangkang Chen, Nov, 04, 2019

for i = 0 : n-1
    ix = i * sx;
    iy = i * sy;
    y(iy+1) = y(iy+1) + a * x(ix+1);
    
end

end

function [ x ] = fold2(o, d, nx, nb, np, x, tmp)
% Modified by Yangkang Chen, Nov, 04, 2019

% copy middle
for i = 0 : nx-1
    x(o+i*d+1) = tmp(i+nb+1);
end

% reflections from the right side
for j = nb+nx : nx : np
    if (nx <= np-j)
        for i = 0 : nx-1
            x(o+(nx-1-i)*d+1) = x(o+(nx-1-i)*d+1) + tmp(j+i+1);
        end
    else
        for i = 0 : np-j-1
            x(o+(nx-1-i)*d+1) = x(o+(nx-1-i)*d+1) + tmp(j+i+1);
        end
    end
    j = j + nx;
    if (nx <= np-j)
        for i = 0 : nx-1
            x(o+i*d+1) = x(o+i*d+1) + tmp(j+i+1);
        end
        
    else
        for i = 0 : np-j-1
            x(o+i*d+1) = x(o+i*d+1) + tmp(j+i+1);
        end
    end
end
%
%     reflections from the left side
for j = nb : -nx : 0
    if (nx <= j)
        for i = 0 : nx-1
            x(o+i*d+1) = x(o+i*d+1) + tmp(j-1-i+1);
        end
    else
        for i = 0 : j-1
            x(o+i*d+1) = x(o+i*d+1) + tmp(j-1-i+1);
        end
    end
    j = j - nx;
    if (nx <= j)
        for i = 0 : nx-1
            x(o+(nx-1-i)*d+1) = x(o+(nx-1-i)*d+1) + tmp(j-1-i+1);
        end
    else
        for i = 0 : j-1
            x(o+(nx-1-i)*d+1) = x(o+(nx-1-i)*d+1) + tmp(j-1-i+1);
        end
    end
end


end

function [ m,d ] = str_adjnull( adj,add,nm,nd,m,d )
%% Claerbout-style adjoint zeroing Zeros out the output (unless add is true). 
% Useful first step for and linear operator.
%  
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) and later version.
%   
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%   
%   You should have received a copy of the GNU General Public License
%   along with this program; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%%
% adj : adjoint flag; add: addition flag; nm: size of m; nd: size of d
if(add)
    return
end

if(adj)
    m=zeros(nm,1);
    for i = 0 : nm-1
        m(i+1) = 0.0;
    end
else
    d=zeros(nd,1);
    for i = 0 : nd-1
        d(i+1) = 0.0;
    end    

end
end


function [ x ] = str_conjgrad(opP,opL,opS, p, x, dat, eps_cg, tol_cg, N,ifhasp0,par_P,par_L,par_S,verb)
% str_conjgrad: conjugate gradient with shaping
% 
% BY Yangkang Chen, Hang Wang, and co-authors, 2019
%
% Modified by Yangkang Chen, Nov, 09, 2019 (fix the "adding" for each oper)
% 
% INPUT
% opP: preconditioning operator
% opL: forward/linear operator
% opS: shaping operator
% d:  data
% N:  number of iterations
% eps_cg:  scaling
% tol_cg:  tolerance
% ifhasp0: flag indicating if has initial model
% par_P: parameters for P
% par_L: parameters for L
% par_S: parameters for S
% verb: verbosity flag
%
% OUPUT
% x: estimated model
%

np=length(p(:));
nx=par_L.nm;    %model size
nd=par_L.nd;    %data size

if ~isempty(opP)
d=-dat; %nd*1
r=feval(opP,d,par_P,0,0);
else
  r=-dat;  
end



if ifhasp0
    x=feval(op_S,p,par_S,0,0);
    if ~isempty(opP)
        d=feval(opL,x,par_L,0,0);
        par_P.d=r;%initialize data
        r=feval(opP,d,par_P,0,1);
    else
        par_P.d=r;%initialize data
        r=feval(opL,x,par_L,0,1);
    end
else
    p=zeros(np,1);%define np!
    x=zeros(nx,1);%define nx!
end

dg=0;
g0=0;
gnp=0;
r0=sum(r.*r);   %nr*1

for n=1:N
    gp=eps_cg*p; %np*1
    gx=-eps_cg*x; %nx*1
        
    if ~isempty(opP)
        d=feval(opP,r,par_P,1,0);%adjoint
        par_L.m=gx;%initialize model
        gx=feval(opL,d,par_L,1,1);%adjoint,adding
    else
        par_L.m=gx;%initialize model
        gx=feval(opL,r,par_L,1,1);%adjoint,adding
    end
    
    par_S.m=gp;%initialize model
    gp=feval(opS,gx,par_S,1,1);%adjoint,adding
    gx=feval(opS,gp,par_S,0,0);%forward,adding
    
    if ~isempty(opP)
        d=feval(opL,gx,par_P,0,0);%forward
        gr=feval(opP,d,par_L,0,0);%forward
    else
        gr=feval(opL,gx,par_L,0,0);%forward
    end
    
    gn = sum(gp.*gp); %np*1
    
    if n==1
        g0=gn;
        sp=gp; %np*1
        sx=gx; %nx*1
        sr=gr; %nr*1
    else
        alpha=gn/gnp;
        dg=gn/g0;
        
        if alpha < tol_cg || dg < tol_cg
            break;
        end
        
        gp=alpha*sp+gp;
        t=sp;sp=gp;gp=t;
        
        gx=alpha*sx+gx;
        t=sx;sx=gx;gx=t;
        
        gr=alpha*sr+gr;
        t=sr;sr=gr;gr=t;
    end
     
    beta=sum(sr.*sr)+eps_cg*(sum(sp.*sp)-sum(sx.*sx));
        
    if verb
        fprintf('iteration: %d, res: %g !\n',n,sum(r.* r) / r0);  
    end
        
    alpha=-gn/beta;
    
    p=alpha*sp+p;
    x=alpha*sx+x;
    r=alpha*sr+r;
    
    gnp=gn;
end


end