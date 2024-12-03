function [TO,TOCs,Demand,S] = InitializeProblem()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALIZATION of the test problem: Madird-Barcelona
% Generate four structures, containing the following information
% TO    : data for IM
% TOCs  : data for TOCs
% Demand: data for demand model (parameters and utillity function)
% S     : initialization of the structure containing the pure strategies 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% T R A C K   O W N E R (TO)  or I N F R A S T R U C T E R   M A N A G E R (IM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Parameters:
%  TO.Rule Criterio para realizar la asignación de los time slots to RU
%  r Time slots considerados. La cantidad total depende del numero de
%  minutos entre ello
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TO = struct;
t0 = datetime('06:15','InputFormat','HH:mm'); % First time slot at 06:15 hours.
tf = datetime('23:30','InputFormat','HH:mm'); % Last time slot at 23:30 hours.
r  = timeofday([t0:minutes(30):tf]);          % Considering one time slot every 30 mins 
%TO.r              = r;
TO.nTimeSlots = length(r);       % Number of time slots
TO.w          = [r;r];           % Two markets (go/return)
TO.Rule       ='equity';         % {'equity','priority'} Assignment criterion
TO.delta      = 50;              % Parameter of Rule equity
TO.priority   = [1,2,3];         % orden en que se satisface peticicones TOCs
TO.pricesTimeSlot= Init_Price_Slot(r,3500);%   TO.pricesTimeSlot matrix
% (two directions x number of slots) -time slot's prices 3000 euros

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       T R A I N  O P E R A T I N G  C O M P A N I E S  (TOCs)          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TOCs         = struct;
TOCs.nTOC    = 3;                   % number of TOCs
TOCs.k       = [0.65, 0.30, 0.05];  % Capacities (real)
%TOCs.k      = [0.25, 0.25, 0.25];  % Capacities (equals)
TOCs.data    = cell(TOCs.nTOC,3);   % strategy for TOCs 
% TOCs.data{o,1} 0/1 matrix representing the time/slot requirements
% TOCs.data{o,2} 0/1 matrix representing the time/slots assigned by IM
% TOCs.data{o,3} prices set for the assigned time slots
TOCs.for     = cell(TOCs.nTOC)      % Operational costs 
TOCs.for{1}  = Init_Price_Slot(r,2950); % for TOC = 1 2950 euros
TOCs.for{2}  = Init_Price_Slot(r,2950);
TOCs.for{3}  = Init_Price_Slot(r,2950);
TOCs.Co      = [11490,11490,11490]; % train depreciation costs
TOCs.ca      = 0;                   % cost of access to the rail network

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             D   E   M   A   N   D       M   O   D   E   L              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Demand            = struct;
Demand.t          = hour2double(r); % Transform path times to continuous values in interval [0, 24]
Demand.alpha      = 0.015; % Compute utilities for each market
Demand.BTren      = 1;     % Logit parameter
Demand.u_non_train= 1.1;   % Utility of non train
Demand.gm         = Init_Potential_Demand(length(Demand.t)); % Potential demand
% Various utility functions: tw desired intant to travel, tj time slot
% instant and price of the ticket
%Demand.u_formula = @ (tj,tw,prices)  1./(1.*(tj -tw).^2 + 0.5) - Demand.alpha * prices;
%Demand.u_formula = @ (tj,tw,prices)  1./(10.*(tj -tw).^2 + 0.5) - Demand.alpha * prices;
%Demand.u_formula = @ (tj,tw,prices) -Demand.alpha *20* abs(tj-tw) - Demand.alpha *prices;
Demand.u_formula  = @ (tj,tw,prices) -Demand.alpha *100* abs(tj-tw) - 0.85*Demand.alpha *prices;
Demand.T          = [Demand.t ; Demand.t ]; % aux evaluar utilidadesmatricialemtne

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  S initialize the structure of pure strategies of the TOCs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S=struct;
S.y={};
S.p={};
S.stra=struct;
sentencia='S.stra=struct(';
for o=1:TOCs.nTOC
    sentencia=[sentencia, '''o', int2str(o),''',1' ];
    if o<TOCs.nTOC
        sentencia=[sentencia, ',' ];
    else
        sentencia=[sentencia, ');' ];
    end
    S.p{o}=[1];
end
eval(sentencia)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             A U X I L I A R       F U N C T I O N S
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following functions are used in data processing

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [double] = hour2double(hour)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
double = [];
for i=1:length(hour)
    % Number of ":" detected
    colons    = 0;
    % Vector to store the integer part of the number
    int_part  = [];
    % Vector to store the real part of the hour
    real_part = [];
    % Transform the hour into a char vector
    hour_      = char(hour(i));
    for j=1:length(hour_)
        if(hour_(j) == ':')
            colons = colons + 1;
        else
            if(colons == 0) % Integer part
                int_part  = [int_part, str2num(hour_(j))];
            elseif(colons == 1) % Real part
                real_part = [real_part, str2num(hour_(j))];
            end
        end
    end
    % Transform the int_part vector into a number
    int_part = str2num(strrep(num2str(int_part), ' ', ''));
    % Transform the real_part vector into a number
    real_part = str2num(strrep(num2str(real_part), ' ', ''));
    % Obtain the double value of the our
    double(i)    = int_part + real_part/60;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [gm] = Init_Potential_Demand(n)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialise a zero matrix which contains the potential demand of
% each market
gm_i  =2.5* [145,145,145,145,318,318,317,317,318,318,318,318,145,145,145,145,72,73,73,...
    72,62,63,63,62,70,70,70,70,110,110,110,110,177,178,178,178,155,155,155,155,112,...
    113,113,112,126,127,127,126,205,205,205,205,192,193,193,193,132,133,133,132,87,...
    88,88,87,50,50,50,50,40,40];
gm_i=acortar_ensanchar(gm_i,n); % reduces / contracts demand to n slots
gm= [gm_i;gm_i];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y=acortar_ensanchar(x,n)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
z=length(x)/n;
cap=ones(1,length(x)+1);
x(end+1)=0;
y=zeros(1,n);
aqui=1;
for i=1:n
    z_aqui=z;
    while  z_aqui>0
        if z_aqui>cap(aqui)+eps
            y(i)=y(i)+x(aqui)*cap(aqui);
            z_aqui=z_aqui-cap(aqui);
            cap(aqui)=0;
            aqui=aqui+1;
        else
            y(i)=y(i)+z_aqui*x(aqui);
            cap(aqui)=cap(aqui)-z_aqui;
            z_aqui=0;
        end
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function path_price = Init_Price_Slot(r,p)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path_price = zeros(1, length(r))+p;
path_price=[path_price ; path_price];
end
