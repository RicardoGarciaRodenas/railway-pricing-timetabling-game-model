%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       M   A   I   N equilibrium prices
% This script process the data for  Experiment 1: Price Equilibrium of the
% paper
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear, clc,close all
seed=25283; rng(seed)
[TO,TOCs,Demand] = InitializeProblem();
%test=1; % ponerlo como tercer parametro Make_Request para depurar
TOCs = Make_Request(TO, TOCs);
TOCs = A(TOCs,TO);
%TOCsNew = A_Proj(2,TOCs);
for i=1:TOCs.nTOC
    TOCs.data{i,2}=0*TOCs.data{i,2};
    for s=1:2
        indices=(i-1)*20+(1:1:10);
        TOCs.data{i,2}(s,indices)=1;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Test={'test1','test2'}
for  n_test=1:length(Test)
    if strcmp(Test{n_test},'test1' )
        % Test 1
        Demand.alpha      = 0.15;
        Demand.BTren      = 10;
        Demand.u_non_train= 1;

    elseif strcmp(Test{n_test},'test2' )
        % Test 2
        Demand.alpha      = 0.15;
        Demand.BTren      = 1;
        Demand.u_non_train= 1;
    end

    % Table to store results
    experimento={'exp1_pre','exp2_pre_rec','exp3_pre_abs'}
    %experimento={'exp2_pre_rec'}
    for  n_exp=1:length(experimento)
        NameFilas= {'CPU','TOC1','TOC2','TOC3'}
        T=table('RowNames',NameFilas)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %EXPERIMENTO 1.1: % price only
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp(experimento{n_exp},'exp1_pre' )
            Demand.u_formula=@ (tj,tw,prices)  2. - Demand.alpha * prices;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %EXPERIMENTO 1.2: %  price + desire reciprocal travel to distanceaprice 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif strcmp(experimento{n_exp},'exp2_pre_rec')
            Demand.u_formula=@ (tj,tw,prices)  1./(1.*(tj -tw).^2 + 0.5) - Demand.alpha * prices;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %EXPERIMENTO 1.3: %   % price + travel desire absolute value
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif strcmp(experimento{n_exp},'exp3_pre_abs')
            Demand.u_formula=@ (tj,tw,prices) -Demand.alpha *20* abs(tj-tw) - Demand.alpha *prices
        end
        filname_tex= ['./tex/' Test{n_test} experimento{n_exp} '.tex']
        filname_fig= ['./fig/' Test{n_test}  experimento{n_exp} '.eps']
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ALGORITHM PROPOSED IN THE PAPER for calculating the equilibrium price
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tic;
        x=1:TOCs.nTOC;
        CPU=toc;
        [TOCs] = Compute_Optimal_Prices(x,TOCs,Demand)
        CPU=toc-CPU;
        for i=1:3
            indices=find(TOCs.data{i,2}==1);
            precios=TOCs.data{i,3}(indices);
            Z(i)=f_i(precios,i,Demand,TOCs)
        end
        Z=round([CPU Z],2)
        T=[T table(Z','VariableNames',{'Paper'})];

        if strcmp(Test{n_test},'test2' )
            escala=[6,20,1,12];
            DibujaSolution(TOCs,Demand,filname_fig,escala)
        else
            DibujaSolution(TOCs,Demand,filname_fig)
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ALGORITMS of MATLAB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
metodo={ 'sqp' , 'sqp-legacy' , 'active-set' , 'interior-point' };
%metodo={  'active-set'};
for j=1:length(metodo)
CPU=toc;
Z=ALG_OPT_EQUI(Demand,TOCs,metodo{j});
CPU=toc-CPU;
T1=table(round([CPU,Z]',2),'VariableNames',{metodo{j}});
T=[T T1];
end
table2latex(T,filname_tex);
clear T
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Z=ALG_OPT_EQUI(Demand,TOCs,metodo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% equilibrio con optimizacion
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
function dibujo_equilibrio(TOCs,Demand)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dibuja dos operadores con el mismo precio y la otra va aumentando el
% precio. Se ve en ventanas separadas para el precio de la tercera

for xx=1:20
    figure(xx)
    for x=1:20
for i=1:3
TOCs.data{i,3}=TOCs.data{i,2}*x;
end
TOCs.data{1,3}=TOCs.data{1,2}*xx;
for i=1:3
IND1=find(TOCs.data{i,2}==1);
precios=TOCs.data{i,3}(IND1);
z(i,x)=f_i(precios,i,Demand,TOCs);
end
end
for s=1:3
plot(z(s,:))
hold on
end
end
%%%

    figure((xx+1))
    for x=1:50
        y=8+x*0.1;
for i=1:3
TOCs.data{i,3}=TOCs.data{i,2}*y;
end

for i=1:3
IND1=find(TOCs.data{i,2}==1);
precios=TOCs.data{i,3}(IND1);
z(i,x)=f_i(precios,i,Demand,TOCs);
end
end
for s=1:3
plot(z(s,:))
hold on
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [TOCs] = Compute_Optimal_Prices(x,TOCs,Demand)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% x es un vector conteniendo los TOCs que intervienen en el equilibrio
% parámetros de tolerancia. Equilibrio y estrategia TOC
Tol_equi=0.1;
Tol_TOC=0.5;
condicion_equi=1;
%b=0.005; % argumento del momentum
while (condicion_equi)
    
    for i=x

        indices=find(TOCs.data{i,2}==1);
        precios_0=TOCs.data{i,3}(indices);
        precios_equi{i}=precios_0;
        condicion=1;
        %mt=zeros(size(precios_0));
        while (condicion)
            precios_1=Iter_precios_i(i,precios_0,Demand,TOCs);
            %mt=b*mt+(1-b)*(precios_1'-precios_0);
            if norm(precios_1'-precios_0,"inf")<Tol_TOC
                condicion=0;
            end

            precios_0=0.5*precios_1'+0.5*precios_0;
            %precios_0=precios_0+mt;
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
function precios_new = Iter_precios_i(i,precios,Demand,TOCs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Z,G,indices]=f_i(precios,i,Demand,TOCs);
h=0.01;
for r=1:length(precios)

    precios_inc=precios;
    precios_inc(r)= precios_inc(r)+h;
    [Z_inc,G_inc]=f_i(precios_inc,i,Demand,TOCs);
    Der=(Z_inc-Z)/h;
    Der_g=(G_inc{i}(indices(r))-G{i}(indices(r)))/h;
    %precios_new(r)=-(G{i}(indices(r))*precios(r)) / (Der(r)-G{i}(indices(r))) ;
    precios_new(r)=precios(r)-Der/Der_g;
end
end


