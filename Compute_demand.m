function  [G,Demand]= Compute_demand(TOCs,Demand)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates the demand on each service (G) based on the services available 
% and their prices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Demand.u       = Compute_Utilities(TOCs, Demand);
Demand.u_train = Compute_Train_Utility(Demand);
G              = Compute_gtrain_Demand(Demand);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function ui = Compute_Utilities(TOCs,Demand)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For each TOC in the corridor
for i=1:TOCs.nTOC

    all_i     = TOCs.data{i,2};          % servicios del TOC i
    for w=1:size(all_i,2) % For each time slot w (demand)

        % Compute utilities of the allocated time slot (demand)
        ui{i,w} = Compute_uij(TOCs,Demand,i,w);

    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [uij] = Compute_uij(TOCs,Demand,i,w)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The utilities of a time slot will be a matrix
uij       = NaN(size(TOCs.data{i,1}));
indices=find(TOCs.data{i,2} ~= 0);
ticket_price = TOCs.data{i,3}(indices);  % prices
T=Demand.T(indices);
uij(indices)= Demand.u_formula(T,Demand.t(w),ticket_price);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [u_w] = Compute_Train_Utility(Demand)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

beta_1=(1/Demand.BTren);
for w=1:size(Demand.u,2)
    for s=1:2
        suma=0;
        for i=1:size(Demand.u,1)
            indices = find(isfinite(Demand.u{i}(s,:)));
            suma=suma+sum(exp(Demand.BTren *Demand.u{i,w}(s,indices)));
        end
        u_w(s,w)=beta_1 * log(suma);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G= Compute_gtrain_Demand(Demand)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function [G,PrT_all,Prm_all,PrT,Prm,P_T]= Compute_gtrain_Demand(Demand)
% Prm -> P*rm
% PrT  -> P*m r/T
% P_T ->  P*m_T

% Demanda en modo tren en cada surco
A=exp(Demand.u_train);
B=exp(Demand.u_non_train* ones(size(Demand.u_train)));
P_T=(A./(A+B));
%size(P_T)
%size(Demand.gm)
g_train=Demand.gm.*P_T;

%incializacion
for i=1:size(Demand.u,1)
    G{i}=zeros(size(Demand.u{1,1}));
    PrT_all{i}=zeros(size(Demand.u{1,1}));
end

% Demanda por servicios
for w=1:size(Demand.u{1,1},2)
    U=zeros(size(Demand.u{1,w}));
    for i=1:size(Demand.u,1)
        A=zeros(size(Demand.u{i,w}));
        indices=isfinite(Demand.u{i,w});
        A(indices)=exp(Demand.u{i,w}(indices));
        U=U+A;
    end
    Total=sum(U,2); % suma todas las columnas

    % probabilidades por servicios
    suma=zeros(size(Demand.u{1,w}));
        for i=1:size(Demand.u,1)
            A=zeros(size(Demand.u{i,w}));
            indices=isfinite(Demand.u{i,w});
            A(indices)=exp(Demand.u{i,w}(indices));
            PrT{i,w}=A./Total;
            PrT_all{i}=PrT_all{i}+PrT{i,w};
            G{i}=G{i}+PrT{i,w}.*g_train(:,w);
        end
end

end




        



