%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TOCs = A_Proj(orden,TOCs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A_Proj: Assignemnt of time slots but the algorithm avoids modifying the 
%        slots assigned to the other operators, 
%   Equation (27) of the paper. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TOCs.data{orden,2}=zeros(size(TOCs.data{orden,1}));
Disponibles=zeros(size(TOCs.data{1,1}));
for i=1:TOCs.nTOC
    if  i~=orden
        Disponibles=Disponibles+TOCs.data{i,2};
    end
end


indices1=find(Disponibles==0);
indices2=find(TOCs.data{orden,1}==1);
ind=intersect(indices1,indices2);
TOCs.data{orden,2}(ind)=1;
Disponibles(ind)=1;
Peticiones_ocupadas=zeros(size(TOCs.data{1,1})); %peticiones
Peticiones_ocupadas(setdiff(indices2,ind))=1;
[Disponibles,D]=Asignacion(Disponibles,Peticiones_ocupadas);
TOCs.data{orden,2}=TOCs.data{orden,2}+D;


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


