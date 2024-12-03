%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      M   A   I   N
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Ricardo García Ródenas 
% Date: 1 December 2024
% This main script for the calculation of the railway market equilibrium
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%    SIMPLE STRATEGIES          %%%%%%%%%%%%%%%%%%%%%%
%
%   S.y{o,stra}:      cell containing the set of simple strategies for TOC o
%                         S.y{o,stra} = yo is the matrix with the slots
%                         requested by o when applying strategy stra=1,2,3,...
%
%-------------
%   S.stra:          structure whose elements are:
%                      S.stra.o1 = [stra1, stra2, ..., stra_m]
%                      S.stra.o2 = [      ...         ]
%                     These vectors contain the simple strategies.
%-------------
%   S.p{o}:          cell containing probability vectors for TOC "o" to use 
%                       its simple strategies.
%                       S.p{o1} = [p_stra1, p_stra2, ..., p_stra_m]
%                       S.p{o2} = [      ...         ]
%
%%%%%%%%%%%%%%%%%%%%%%    COMBINED  STRATEGIES       %%%%%%%%%%%%%%%%%%%%%%
%
%      Yn{i}:       matrix representing the combined strategy i for all TOCs.
%      py(i):       probability of the combined strategy i occurring in reality.
%      stra:        matrix detailing the composition of the combined strategy.
%       Uo:         vector of payoffs for the different TOCs.
%                       Uo = [u0(o1,y), ..., u0(o|O|,y)] where u0(o, y) is the
%                       payoff for TOC o under the combined strategy y.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear, clc,close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Definition of the experiment
% The variable ExpName contains the name of the file where the results of 
% the experiment are saved
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% European Work Group on Transportation 2023 %%%%%%%%%%%%%%%
%ExpName='EXP1Prior'
%ExpName='EXP1Equi'
%ExpName='EXP2Equi'

%% FEATURES of experiments EWGT2023:
% The optios of these experiments are:
% (in main.m) 
% etiqueta_demanda= 'slot';%  Demand model is a all/nothing assignment model. 
% MaxIter=10;              % Max number of main iterates
% ( in InitializeProblem() ) 
% gm_i  =1.0* ...;         % Potential demand  (in -->Init_Potential_Demand(n)
% r  = timeofday([t0:minutes(30):tf]); % Number of time slots (every 30 mins)
% TOCs.k      = [0.25, 0.25, 0.25];    % Capacity of TOCs
% TO.Rule= {'equity','priority'} (in InitializeProblem()) % Choose an
% option
% (in CGA)
%  opts1 (Options for genetic algorithm) generated by optimoptions del ga  

%%%%%%%%%%%%%%%%%%% Transportation Research - Part B %%%%%%%%%%%%%%%%%%%%%%
%ExpName='EXP2EquiCasoReal_prueba1'

%% FEATURES of experiments in TR-B:
% The optios of these experiments are:
% (in main.m) 
% etiqueta_demanda= 'precios';%  Demand model is a all/nothing assignment model. 
% MaxIter=10;              % Max number of main iterates
% ( in InitializeProblem() ) 
% gm_i  =2.5.0* ...;         % Potential demand  (in -->Init_Potential_Demand(n)
% r  = timeofday([t0:minutes(15):tf]); % Number of time slots (every 15 mins)
% TOCs.k       = [0.65, 0.30, 0.05];    % Capacity of TOCs
% TO.Rule= 'equity'; (in InitializeProblem()) % Choose an
% option
% (in CGA)
%  opts1 (Options for genetic algorithm) generated by optimoptions del ga  


ExpName='Prueba';                              % name of the file to save the results
seed=25412250; rng(seed)
addpath("./filesMATLABCentral/")               % Contains auxiliary functions downloaded from MATLAB Central.
file_resultados=['./results/' ExpName '.mat']; % folder and file name where the results will be written to
etiqueta_demanda='slot';                       % options: 'slot' 'precios',
MaxIter=2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  InitializeProblem():  This function initializes a test problem by creating the following:
% - TO: Defines characteristics of the infrastructure manager.
% - TOCs: Specifies the features of the transport operators (e.g., costs, services).
% - Demand: Sets parameters for the demand model, including utility functions.
% - S: Initializes the structure for pure strategies used by the TOCs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[TO,TOCs,Demand,S] = InitializeProblem();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialises the TOCs variable from a feasible random solution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iter=1;
n_player=TOCs.nTOC;
TOCs = Make_Request(Demand,TO, TOCs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      INITIAL COMBINED STRATEGY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Yn{1}=TOCs;
py=[1];
stra=zeros([1,n_player]);
Uo=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       INITIAL PURE STRATEGY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:n_player
    S.y{i,iter}=TOCs.data{i,iter};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              MAIN   LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for contador=1:MaxIter

    stra_new=[];
    iter=iter+1;
    for i=1:n_player
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %               Solving CGA
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [yo,uo]=CGA(i,stra,Yn,py,Demand,TO,etiqueta_demanda);

        if uo>0
            S.y{i,iter}=yo;
            eval(['S.stra.o', int2str(i),'=[S.stra.o', int2str(i),' iter];'])
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Buldign the cartesian product 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for j=1:n_player% sorting
        eval(['A.stra.o',int2str(j),'=S.stra.o', int2str((1-j+n_player)),'(:)'';'])
    end

    CP = CartesianProduct(A.stra);

    for n = 1:CP.Cardinal
        stra_new(n,:) = CP.getTuple(n);
    end
    stra_new=stra_new(:,size(stra_new,2):-1:1); % sorting the columns
    Uo_new=zeros(size(stra_new));

    for n = 1:CP.Cardinal
        RowIdx = find(ismember(stra, stra_new(n,:),'rows'));
        if isfinite(RowIdx)
            Uo_new(n,:)=Uo(RowIdx,:);
            Yn_new{n}=Yn{RowIdx};
            py_new(n)=py(RowIdx);
        else
            %% Computing a new solution
            [Uo_stra,TOC_stra]=EvaluaStrategia(stra_new(n,:),S,Demand,TOCs,TO,etiqueta_demanda);
            Uo_new(n,:)=Uo_stra;
            Yn_new{n}=TOC_stra;
        end
    end

    stra=stra_new;
    Uo=Uo_new;
    Yn=Yn_new;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Solving the RMP
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:n_player
        M(i)=eval( ['length(S.stra.o', int2str(i),')']);
    end

    %[P,payoff,iterations,err] = npg(M,Uo)

    [P] = npg(M,Uo); % optimal probabilities after solving the RMP
    %clc,Uo,stra,P

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % elimination of columns
    [Yn,py,stra,Uo,S]=DeleteColumns(Yn,stra,Uo,S,P);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Resultados.Yn{contador}=Yn;
    Resultados.py{contador}=py;
    Resultados.stra{contador}=stra;
    Resultados.Uo{contador}=Uo;
    Resultados.S{contador}=S;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SAVE THE RESULTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save(file_resultados,'Resultados')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% END MAIN 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             A U X I L I A R       F U N C T I O N 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following functions is used to delete columns

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Yn_new,py,stra_new,Uo_new,S]=DeleteColumns(Yn,stra,Uo,S,A)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A probabilities of pure strategies. Colums associated with TOCs o
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inicializacion
idx_cero=[];
n=size(A,2);
n_stra=size(stra,1);
error=0.0001;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:n
    idx=find(A(:,j)<error & A(:,j) ~=  0 ); % probability equal to zero
    for s=1:length(idx)
        eval(['aux=S.stra.o', int2str(j),'(idx(s));'])
        idx_cero=union(idx_cero,find(stra(:,j)==aux));
    end
end
idx_com=setxor(idx_cero,1:1:n_stra);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% calculation of probabilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P=zeros(size(stra));
for j=1:n
    eval(['n_stra_o=length(S.stra.o', int2str(j),' );']) ;
    for s=1:n_stra_o
        eval(['aux=S.stra.o', int2str(j),'(s);'])
        idx=find(stra(:,j) ==aux);
        P(idx,j)=A(s,j);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Updating composite strategies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P= prod(P');
py=P(idx_com);
stra_new=stra(idx_com,:);
Yn_new=Yn(idx_com);
Uo_new=Uo(idx_com,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Updating pure strategies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:n
    idx=find(A(:,j)>=error); % probability equal to zero
    eval(['S.stra.o', int2str(j),'=S.stra.o', int2str(j),'(idx); '])
    S.p{j}=A(idx,j);
end
end





