%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TOCs = A(TOCs,TO)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A: Time slot assignment algorithm for each TOC. The algorithm can use
%    either a priority-based rule or a equity-based rule.
%    Refer to the https://arxiv.org/abs/2401.12073 for detailed explanations 
%    on how the algorithm works.
%    El output is  TOCs.data{i,2}, it contains the assignment matrix 
%    for TOCs i
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(TO.Rule,'equity')
    % % Resource Allocation
    TOCs  = A_equity(TO,TOCs);
elseif strcmp(TO.Rule,'priority')
    TOCs=A_priority(TOCs,TO);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function receives the TO and TOCs structures as well as a delta
% parameter which determines the defined shift to displace the TOCs
% request to met them. The function returns an allocation cell which contains the
% allocated resources for each market.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TOCs = A_equity(TO,TOCs)

for i=1:TOCs.nTOC
TOCs.data{i,2}=zeros(size(TOCs.data{i,1}));
end
phi(1:TOCs.nTOC)=Inf;
%n_asig(1:TOCs.nTOC)=0; % asignaciones realizadas
Disponibles=zeros(size(TOCs.data{1,1}));
AuxDis=zeros(size(TOCs.data{1,1}));
n_peticiones=0;
for i=1:TOCs.nTOC
peticiones{i}=find(TOCs.data{i,1}==1);
n_asig(i)=length(peticiones{i});
n_peticiones=n_peticiones+n_asig(i);
end

for j=1:n_peticiones
    phi_aux=n_asig./TOCs.k;
    [phi_max,i]=max(phi_aux);
    n_asig(i)=n_asig(i)-1;
    pet=peticiones{i}(1);
    peticiones{i}(1)=[];
    Peticion_i=AuxDis;
    Peticion_i(pet)=1;
    [Disponibles,D]=Asignacion(Disponibles,Peticion_i);
     TOCs.data{i,2}=TOCs.data{i,2}+D;
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  TOCs=A_priority(TOCs,TO)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
orden=TO.priority;
% orden contiene la prioridad del TOCs
Disponibles=zeros(size(TOCs.data{1,1}));
for i=1:TOCs.nTOC

    TOCs.data{orden(i),2}=zeros(size(TOCs.data{1,1}));
    indices1=find(Disponibles==0);
    n_disponibles=length(indices1);
    indices2=find(TOCs.data{orden(i),1}==1);
    n_peticiones=length(indices2);
    ind=intersect(indices1,indices2);
    n_pet_libre=length(ind);
    TOCs.data{orden(i),2}(ind)=1;
    Disponibles(ind)=1;
   
    Peticiones_ocupadas=zeros(size(TOCs.data{1,1})); %peticiones
    Peticiones_ocupadas(setdiff(indices2,ind))=1;
    n_pet_ocu=length(setdiff(indices2,ind));
    [Disponibles,D]=Asignacion(Disponibles,Peticiones_ocupadas);
    TOCs.data{orden(i),2}=TOCs.data{orden(i),2}+D;

end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [A,D]=Asignacion(A,B)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% B peticiones
% A disponibles
% D asignaciones

D=zeros(size(B));
for s=1:size(A,1)
    indices_pet=find(B(s,:)==1);
    indices_slot=find(A(s,:)==0);

    while length(indices_pet)>=1
        a=indices_pet(1);
        if length(indices_pet)>=2


            b=indices_pet(2);
            indices_pet=indices_pet(2:end);
            [A1,A2]=Busca(a,indices_slot);
            [B1,B2]=Busca(b,indices_slot);
            if a-A1<A2-a
                A(s,A1)=1;
                D(s,A1)=1;
            else
                A(s,A2)=1;
                D(s,A2)=1;
            end
            %
        else
            indices_pet=[];
            [A1,A2]=Busca(a,indices_slot);
            if a-A1<A2-a
                A(s,A1)=1;
                D(s,A1)=1;
            else
                A(s,A2)=1;
                D(s,A2)=1;
            end

        end
        indices_slot=find(A(s,:)==0);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [A1,A2]=Busca(a,indices_slot)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inda1=find(indices_slot<a);
inda2=find(indices_slot>a);
if length(inda1)>0
    A1=indices_slot(inda1(end));
else
    A1=[-Inf];
end

if length(inda2)>0
    A2=indices_slot(inda2(1));
else
    A2=[Inf];
end
end


