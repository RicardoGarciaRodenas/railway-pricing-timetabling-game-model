%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [Z,TOCs_new]= U0(i,Demand,TOCs,TO,etiqueta_demanda)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(i)==1 % in this case this function is used in the CGA
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Z=0; % Profit

%%% calculate the projected variables xo. In the code the index of the paper o is i
TOCs_new = A_Proj(i,TOCs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% demand revenues
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(etiqueta_demanda,'precios' )   %% calculate equilibrium prices zo
    [TOCs_new,Z_new]=Optimal_Prices(Demand,TOCs_new,'Paper',i:i);
    Ingresos=Z_new(i);
elseif strcmp(etiqueta_demanda,'slot' )  % demand captured in time-slots. Price=70 euros
    Ingresos=sum(Demand.gm.*TOCs_new.data{i,2},'all')*70;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% calculating operating costs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cost_oper=sum((TO.pricesTimeSlot+TOCs_new.for{i}).*TOCs_new.data{i,2},'all');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% depreciation costs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nTren=nT(i,TOCs_new,TO);
cost_amor=nTren*TOCs_new.Co(i);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Profit
Z=Ingresos - cost_oper - cost_amor -TOCs_new.ca;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif length(i)==0 % pay-offs are to be calculated for each operator.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TOCs_new=TOCs; % the solution is already feasible, it is not touched;
Z=0; % Profit

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% demand revenues
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(etiqueta_demanda,'precios' )   %% calculate equilibrium prices zo
    [TOCs_new,Ingresos]=Optimal_Prices(Demand,TOCs_new,'Paper',1:TOCs.nTOC);
elseif strcmp(etiqueta_demanda,'slot' )  % demand captured in time-slots
    for i=1:TOCs.nTOC
    Ingresos(i)=sum(Demand.gm.*TOCs_new.data{i,2},'all')*70;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% calculating operating costs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:TOCs.nTOC
cost_oper(i)=sum((TO.pricesTimeSlot+TOCs_new.for{i}).*TOCs_new.data{i,2},'all');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% depreciation costs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:TOCs.nTOC
nTren(i)=nT(i,TOCs_new,TO);
cost_amor(i)=nTren(i)*TOCs_new.Co(i);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Profit
Z=Ingresos - cost_oper - cost_amor -TOCs_new.ca;
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function n_T=nT(i,TOCs,TO)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate the number of trains to satisfy a timetable
% TOCs timetable data of TOCs
% i is the specific company you wish to calculate the fleet required
% n_T number of trains
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inicializacion
n_T=0;
indices=find(TOCs.data{i,2}==1);
T=TO.w(indices); % instantes de inicio
W=mod(1+indices,2)+1;
viaje=duration(2,30,0);
Q={[],[]} ;% trenes en cola en cada estacion
Tq={[],[]};  % tiempo disponible de cada tren para iniciar viaje

for r=1:length(T)
    % salida de estacion
    ir=W(r); % estacion inicial
    jr=mod(ir,2)+1; % estacion final
    tb=T(r); % tiempo de inicio
    te=tb+viaje; % tiempo final
    [tq,i_q]=min(Tq{ir});
    if length(tq)==0
        tq=Inf;
    end

    if tb<tq
        n_T=n_T+1;
        q=n_T;
    else
     
        q=Q{ir}(i_q);
        % eliminacion de cola
        Q{ir}=Borra(Q{ir},i_q);
        Tq{ir}=Borra(Tq{ir},i_q);
    end
    % Lo ponga en la cola de la estación de destino
    
    Q{jr}=[Q{jr},q];
    Tq{jr}=[Tq{jr},te];

end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x=Borra(x,x0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x=[x(1:(x0-1)),x((x0+1):end)];
end