%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [yo,uo]=CGA(i,stra,Yn,py,Demand,TO,etiqueta_demanda)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function solves the CGA problem
% yo is a new strategy for TOC i given the current set of strategies.
% yo improves the current set of strategies.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Definition of the CGA problem to be solved with the GA algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

m=size(Yn{1}.data{i,1}); % dimensions 
nvars=m(1)*m(2);

[ia,py_new]=simplifica(i,stra,py);
fun=@(x) -f(x,i,stra,Demand,Yn,py,m,TO,etiqueta_demanda,ia,py_new); % I change the sign because it is maximising
lb=zeros([1,nvars]);
ub=ones([1,nvars]);
intcon=1:nvars;
A=[ones([1,m(2)]), zeros([1,m(2)]);
       zeros([1,m(2)]), ones([1,m(2)])];
b=floor(Yn{1}.k(i)*size(TO.w,2));
b=[b;b];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% options fo GA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%PopulationSize=400;
PopulationSize=200;

%opts1 = optimoptions('ga','PopulationSize',PopulationSize, 'MaxGenerations',50, ...
%    'EliteCount', 0.01*PopulationSize,'CrossoverFraction',0.95,'PlotFcn',@gaplotbestfun);

opts = optimoptions('ga','PopulationSize',PopulationSize, 'MaxGenerations',100, ...
    'UseParallel',true, 'EliteCount', 0.01*PopulationSize,'CrossoverFraction',0.95,'PlotFcn',@gaplotbestfun);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[x_opt,f_opt] = ga(fun,nvars,A,b,[],[],lb,ub,[],intcon,opts); % less than or equal to time slots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Reshape the optimal strategy
yo=reshape(x_opt,[m(2),m(1)])';
uo=-f_opt;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   a u x i l i a r y   f u n c t i o n s
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [Z_opt,TOCs_new]=f(x,i,stra,Demand,Yn,py,m,TO,etiqueta,ia,py_new)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Z_opt=0;

for s=1:length(ia)
    j=ia(s);
    TOCs=Yn{j};
    TOCs.data{i,1}=reshape(x,[m(2),m(1)])';
    [Z,TOCs_new]=U0(i,Demand,TOCs,TO,etiqueta);
    Z_opt=Z_opt+py_new(s)*Z;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [ia,py_new]=simplifica(i,stra,py)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function folds the set of alternatives by eliminating those of TOCs i.

n=size(stra,2);
idx=[1:i-1,(i+1):n];
[C,ia,ic] = unique(stra(:,idx),'rows');
m=size(stra,1);
for j=1:m
    idx1=find(ic==j);
    py_new(j)=sum(py(idx1));
end
end
