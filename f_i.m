%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [Z,G,indices,Demand]= f_i(precios,i,Demand,TOCs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Objective function for TOC i based on prices (precios)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

indices=find(TOCs.data{i,2}==1);
TOCs.data{i,3}(indices)=precios;
[G,Demand]= Compute_demand(TOCs,Demand);
Z=sum(G{i}.*TOCs.data{i,3},'all');

end