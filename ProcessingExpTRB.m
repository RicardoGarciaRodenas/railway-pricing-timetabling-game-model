clc, close all, clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ExpName='EXP2Equi'
ExpName='CasoReal_1'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WARNING: InitalizeProblem-> to time slots separated 15 mins
load(['./results/' ExpName '.mat']);
addpath("./filesMATLABCentral/");
filname_tex= ['./tex/TRB/' ExpName '_table.tex'];
filname_fig= ['./fig/TRB/' ExpName '_OD'];
filname_fig_alg= ['./fig/TRB/' ExpName '_alg_'];
[TO,aux1,Demand,aux2] = InitializeProblem();
CosEqui=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iter=length(Resultados.Yn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% T A B L A S
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:iter
[T1,CosteEstrategia,TOCsnew,G,Demand]=CalculosTabla(Resultados,i,filname_tex,Demand,TO);

CosEqui=[CosEqui, CosteEstrategia];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% G R A F I C O S
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:2
    %DibujaUna(j,TOCsnew,Demand) % Demanda potencial
    DibujaDemanda(j,TOCsnew,Demand, G)
    filname_fig1=[filname_fig num2str(j) '_Passengers.eps'];
    print(filname_fig1,'-depsc')
    DibujaPrecio(j,TOCsnew,Demand)
    filname_fig1=[filname_fig num2str(j) '_Price.eps'];
    print(filname_fig1,'-depsc')
end
for j=1:3
    figure
    DibujaAlgoritmo(CosEqui,j,Resultados)
    filname_fig1=[filname_fig_alg num2str(j) '.eps'];
    print(filname_fig1,'-depsc')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DibujaUna(j,TOCs,Demand)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
col={[0 0.4470 0.7410],[0.9290 0.6940 0.1250],[0.4660 0.6740 0.1880]};
idx={[]};
figure
for i=1:3
    hold on
    aux=TOCs.data{i,2}(j,:);
    idx{i}=find(aux==1);
    b=bar(Demand.t(idx{i}),Demand.gm(j,idx{i}));
    b.BarWidth=0.4;
    b.FaceColor = col{i};
end
xlabel('Time of Day')
ylabel('Passengers')
grid on
ax=gca;
ax.FontSize=18;
plot(Demand.t,Demand.gm,'k-','LineWidth',4)
legend({'TOC1','TOC2','TOC3'})
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DibujaDemanda(j,TOCs,Demand, G)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
col={[0 0.4470 0.7410],[0.9290 0.6940 0.1250],[0.4660 0.6740 0.1880]};
idx={[]};
figure
for i=1:3
    hold on
    idx{i}=find(ne(G{i}(j,:),0));
    b=bar(Demand.t(idx{i}),G{i}(j,idx{i}));
    b.BarWidth=0.4;
    b.FaceColor = col{i};
end
xlabel('Time of Day')
ylabel('Passengers')
grid on
ax=gca;
ax.FontSize=18;
legend({'TOC1','TOC2','TOC3'})
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DibujaPrecio(j,TOCs,Demand)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
col={[0 0.4470 0.7410],[0.9290 0.6940 0.1250],[0.4660 0.6740 0.1880]};
idx={[]};
figure
for i=1:3
    hold on
    idx{i}=find(ne(TOCs.data{i,2}(j,:),0));
    b=bar(Demand.t(idx{i}),TOCs.data{i,3}(j,idx{i}));
    b.BarWidth=0.4;
    b.FaceColor = col{i};
end
xlabel('Time of Day')
ylabel('Price')
grid on
ax=gca;
ax.FontSize=18;
legend({'TOC1','TOC2','TOC3'})
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tabla
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T=TablaDemanda(TOCs,TO,G,Coste)
for j=1:2
    for i=1:3
        aux=find(ne(G{i}(j,:),0));
        DEMANDA(i,j)=sum(G{i}(j,:));
        SERVICIOS(i,j)=length(aux);
    end
end
for i=1:3
    n_T(i)=nT(i,TOCs,TO);
end
SERVICIOS(:,3)=SERVICIOS(:,1)+SERVICIOS(:,2);
DEMANDA(:,3)=DEMANDA(:,1)+DEMANDA(:,2);
DEMANDA=round(DEMANDA,0);
NameFilas= {'TOC1','TOC2','TOC3'};

T=table(DEMANDA(:,1),SERVICIOS(:,1),DEMANDA(:,2),SERVICIOS(:,2),DEMANDA(:,3),n_T',Coste,'RowNames',NameFilas, 'VariableNames',{'OD1','S1','OD2','S2', 'Passengers','Roll. Stock','Revenue'});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function n_T=nT(i,TOCs,TO)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calcular el numero de trenes para satisfacer un horario
% TOCs datos de horarios de los TOCs
% i es la compañia especifica que se desea calcular la flota necesaria
% n_T número de trenes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x=Borra(x,x0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x=[x(1:(x0-1)),x((x0+1):end)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CosEqui=CosteEstrategiaCombinada(Resultados,iter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_stra=length(Resultados.Yn{iter})
py=Resultados.py{iter};
CosEqui=zeros(size(Resultados.Uo{iter}(1,:)'));
for strategia=1:n_stra
    Coste=Resultados.Uo{iter}(strategia,:)'
    CosEqui=CosEqui+py(strategia)*Coste;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [T1,CosteEstrategia,TOCsnew,G,Demand]=CalculosTabla(Resultados,iter,filname_tex,Demand,TO)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_stra=length(Resultados.Yn{iter});
py=Resultados.py{iter};
T=zeros([3,7]);
for strategia=1:n_stra
    TOCsnew=Resultados.Yn{iter}{strategia};
    Coste=Resultados.Uo{iter}(strategia,:)';
    [G,Demand]= Compute_demand(TOCsnew,Demand);
    T1=TablaDemanda(TOCsnew,TO,G,Coste);
    T=T+py(strategia)*T1{:,:};
end
CosteEstrategia=CosteEstrategiaCombinada(Resultados,iter);
T1{:,:}=round(T,1);
table2latex(T1,filname_tex);
end

