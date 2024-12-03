%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Precios_opt,f_opt]= Sol_f_i(i,Demand,TOCs,metodo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes the optimal prices for TOC i
% Maximizing Objective function for TOC i based on prices (precios)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f=@(precios) - f_i(precios,i,Demand,TOCs);

indices=find(TOCs.data{i,2}==1);

precios_0=TOCs.data{i,3}(indices);
lb=zeros(size(precios_0));

% active-set
if nargin<=3
    options = optimoptions('fmincon','Display','iter','Algorithm','active-set');
else
    options = optimoptions('fmincon','Display','none','Algorithm',metodo);
end

if length(indices)==0
    f_opt=0;
    Precios_opt=[];
else
    [Precios_opt,f_opt] = fmincon(f,precios_0,[],[],[],[],lb,[],[],options);
end
f_opt=-f_opt; % estamos maximizando
end