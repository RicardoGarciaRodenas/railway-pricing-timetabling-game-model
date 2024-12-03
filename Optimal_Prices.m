%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [TOCs,Z]=Optimal_Prices(Demand,TOCs,metodo,x)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function integrates the calculation of equilibrium prices using 
% the algorithm in the paper and MATLAB optimization algorithms to solve models.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if  strcmp(metodo,'Paper' )
    [TOCs,Z] = Compute_Optimal_Prices(x,TOCs,Demand);
else
    [TOCs,Z]=ALG_OPT_EQUI(Demand,TOCs,metodo); % Using optimization toolbox
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [TOCs,Z]=ALG_OPT_EQUI(Demand,TOCs,metodo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% equilibrium calculation using optimisation toolbox

Tol_equi=0.1;
condicion_equi=1;

while (condicion_equi)

    for i=1:TOCs.nTOC
        IND=find(TOCs.data{i,2}==1);
        precios_equi{i}=TOCs.data{i,3}(IND);    
        if nargin==2
            [Precios_opt,f_opt]= Sol_f_i(i,Demand,TOCs);
        else
            [Precios_opt,f_opt]= Sol_f_i(i,Demand,TOCs,metodo);
        end
        Z(i)=f_opt;
        TOCs.data{i,3}(IND)=Precios_opt;
        error(i)=norm(precios_equi{i}-Precios_opt,"inf");
    end
    if max(error)<Tol_equi
        condicion_equi=0;
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [TOCs,Z] = Compute_Optimal_Prices(x,TOCs,Demand)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% x is a vector containing the TOCs involved in the equilibrium.

% tolerance parameters. Equilibrium between TOCs and TOC strategy
Tol_equi=0.1;
Tol_TOC=0.5;
condicion_equi=1;

while (condicion_equi)
    
    for i=x

        indices=find(TOCs.data{i,2}==1);
        precios_0=TOCs.data{i,3}(indices);
        precios_equi{i}=precios_0;
        condicion=1;
        while (condicion)
            if length(precios_0)>0
            [precios_1,Z(i)]=Iter_precios_i(i,precios_0,Demand,TOCs);
            else
                precios_1=[];
                Z(i)=0;
            end
            
            if norm(precios_1'-precios_0,"inf")<Tol_TOC
                condicion=0;
            end

            precios_0=0.5*precios_1'+0.5*precios_0;
            
        end
        error(i)=norm(precios_equi{i}-precios_0,"inf");       
        TOCs.data{i,3}(indices)=precios_0';
    end

if max(error)<Tol_equi
    condicion_equi=0;
end

end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [precios_new ,Z]= Iter_precios_i(i,precios,Demand,TOCs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Z,G,indices]=f_i(precios,i,Demand,TOCs);
h=0.01;
for r=1:length(precios)

    precios_inc=precios;
    precios_inc(r)= precios_inc(r)+h;
    [Z_inc,G_inc]=f_i(precios_inc,i,Demand,TOCs);
    Der=(Z_inc-Z)/h;
    Der_g=(G_inc{i}(indices(r))-G{i}(indices(r)))/h;
    precios_new(r)=precios(r)-Der/Der_g;

end
end

