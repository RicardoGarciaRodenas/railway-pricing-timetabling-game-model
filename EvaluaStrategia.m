%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [U,TOCs_new]=EvaluaStrategia(stra,S,Demand,TOCs,TO,etiqueta_demanda)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TOCs_new=TOCs;
for i=1:length(stra)
    TOCs_new.data{i,1}=S.y{i,stra(i)};
end
TOCs_new = A(TOCs_new,TO);
[U,TOCs_new]= U0([],Demand,TOCs_new,TO,etiqueta_demanda);
end