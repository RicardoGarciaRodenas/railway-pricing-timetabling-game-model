%% Cartesian product
%  Version : 1.0.0.0
%  Author  : E. Ogier
%  Release : 15th june 2020
%
%  OBJECT METHODS:
%  -  CP = CartesianProduct(ARGUMENT1,ARGUMENT2,[...],ARGUMENTn): 
%      createS a cartesian product object on the basis of a unique 
%      structure ARGUMENT1, including numeric vectors or 1-D cells, or
%      multiples numeric vectors or 1-D cells ARGUMENT1, ARGUMENT2, [...], 
%      ARGUMENTn.
%  -  CP.getCardinal():
%      gets the cardinal of the set resulting from the cartesian product
%      (product of the cardinals of the sets).
%  -  CP.getTuple(INDEX):
%      gets the tuple at specific index INDEX considering the elements of
%      the first set included in the cartesian product are sampled first,
%      then the elements of the second set, etc; return result as numeric 
%      matrix or 2-DBcell (cell in the presence of a non-numeric element).
%  -  CartesianProduct.getTuples(ARGUMENT1,ARGUMENT2,[...]):
%      gets all the tuples resulting from the cartesian product based on a 
%      unique structure ARGUMENT1, including numeric vectors or 1-D cells, 
%      or multiple numeric vectors or cells ARGUMENT1, ARGUMENT2, [...], 
%      ARGUMENTn; returns result as numeric matrix or 2-D cell(cell in the 
%      presence of a non-numeric element).
%
%  EXAMPLE 1:
%  
%  % Structure of 3 binary values (word of 3 bits)
%  B = ...
%      struct('b2',[false true],...
%             'b1',[false true],...
%             'b0',[false true]);
%  
%  % Cartesian product
%  CP = CartesianProduct(B);
%  
%  % Display of tuples
%  fprintf(1,'Words of 3 bits:\n\n');
%  fprintf(1,'Word | bit#%u | bit#%u | bit#%u \n',2,1,0);
%  fprintf(1,'-----|-------|-------|-------\n');    
%  for n = 1:CP.Cardinal    
%      Tn = CP.getTuple(n);
%      fprintf(1,'  %u  |   %u   |   %u   |   %u   \n',Tn*2.^(0:2)',Tn(3),Tn(2),Tn(1));   
%  end
%
%  EXAMPLE 2:
%  
%  % Sets of mixed variables 
%  Letters  = {'A','B'};
%  Symbols  = {'0',1,'2'};
%  Integers = 3:4;
%  
%  % Cartesian product
%  CP = CartesianProduct(Letters,Symbols,Integers);
%  
%  % Formats for display
%  Formats = {'''%s''',' %u '};
%  Format = @(e)Formats{1+isnumeric(e)};
%
%  % Display of tuples
%  fprintf(1,'Tuples of 3 mixed sets of both letters and integers:\n\n');
%  fprintf(1,'Tuple | Letter | Symbol | Integer \n');
%  fprintf(1,'------|--------|--------|---------\n');    
%  for n = 1:CP.Cardinal
%      Tn = CP.getTuple(n);       
%      fprintf(1,...
%              sprintf('  %s  |   %s  |   %s  |   %s    \n',...
%              '%2u',Format(Tn{1}),Format(Tn{2}),Format(Tn{3}) ),...
%              n,Tn{1},Tn{2},Tn{3}); 
%  end
%  
%  EXAMPLE 3:
%
%  % Tuples from the cartesian product of two sets
%  Set1 = {'a','b','c'};
%  Set2 = {'d','e','f'};
%  Tuples = CartesianProduct.getTuples(Set2,Set1);
%  
%  % Display of the elements from the first set
%  fprintf(1,'Sets:\nSet1 = {');
%  cellfun(@(c)fprintf(1,'''%c'',',c),Set1(1:(end-1)));
%  cellfun(@(c)fprintf(1,'''%c''} ; ',c),Set1(end));
%  
%  % Display of the elements from the second set
%  fprintf(1,'Set2 = {');
%  cellfun(@(c)fprintf(1,'''%c'',',c),Set2(1:(end-1)));
%  cellfun(@(c)fprintf(1,'''%c''}\n',c),Set2(end));
%  
%  % Display of the tuples from the cartesian product
%  fprintf(1,'\nCartesian product:\nSet1 x Set2 = {');
%  arrayfun(@(n)fprintf(1,'(''%c'',''%c''),',Tuples{n,2},Tuples{n,1}),1:(size(Tuples,1)-1));
%  fprintf(1,'(''%c'',''%c'')}\n',Tuples{end,2},Tuples{end,1});

classdef CartesianProduct < matlab.mixin.SetGet
    
    % Private properties
    properties (SetAccess = 'private')
        
        % Cardinal of the set resulting from the cartesian product
        Cardinal = 0;
        
        % Sets to be considered in cartesian product
        Sets = ...
            struct('Name',     '',...   % Name
                   'Elements', [],...   % Elements
                   'Cardinal', 0);      % Cardinal
        
    end
    
    % Hidden properties
    properties (Hidden)
                
        % Indicator of the presence of cells
        PresenceOfCells = false;
        
        % Modulos
        Modulos = NaN;
        
    end
    
    % Methods
    methods
        
        % Constructor
        function Object = CartesianProduct(varargin)
            
            switch nargin
                
                % Absence of argument
                case 0
                    
                    error('At least one argument is required.');
                    
                % Unique argument
                case 1
                    
                    if isstruct(varargin{1})
                        
                        Names = fieldnames(varargin{1});
                        
                        for s = 1:numel(Names)
                        
                            % Presence of cells among sets
                            Object.PresenceOfCells = or(Object.PresenceOfCells,iscell(varargin{1}.(Names{s})));
                        
                            % Name of the current set
                            Object.Sets(s).Name = Names{s};
                            
                            % Elements of the current set
                            Object.Sets(s).Elements = varargin{1}.(Names{s});                            
                            
                        end
                        
                    else
                        
                        error('Structure of numeric vectors or cells expected in case of unique argument.');                        
                        
                    end
                    
                % Multiple arguments
                otherwise
                    
                    if all(cellfun(@isnumeric,varargin)|cellfun(@iscell,varargin))
                                  
                        % Presence of cells among sets
                        Object.PresenceOfCells = any(cellfun(@iscell,varargin));
                        
                        for s = 1:nargin
                            
                            % Name of the current set
                            Object.Sets(s).Name = sprintf('Set#%u',s);                            
                            
                            % Elements of the current set
                            Object.Sets(s).Elements = varargin{s};
                        
                        end
                                              
                    else
                        
                        error('Numeric vectors or cells expected in case of multiple arguments.');
                        
                    end
                    
            end
            
            for s = 1:numel(Object.Sets)
                
                % Cardinal of the current set
                Object.Sets(s).Cardinal = numel(Object.Sets(s).Elements);
                
                % Modulos and cardinal of the cartesian product
                if eq(s,1)
                    Object.Modulos(s) = 1;
                    Object.Cardinal = Object.Sets(s).Cardinal;
                else
                    Object.Modulos(s) = Object.Modulos(s-1)*Object.Sets(s-1).Cardinal;
                    Object.Cardinal = Object.Cardinal*Object.Sets(s).Cardinal;
                end
                
            end
            
        end
        
        % Method 'getTuple'
        function T = getTuple(Object,n)
            
            % All tuples in the absence of index
            if eq(nargin,1)
                n = 1:Object.Cardinal;
            end
            
            % Preallocation
            if Object.PresenceOfCells                
                T = cell(numel(n),numel(Object.Sets));
            else
                T = NaN(numel(n),numel(Object.Sets));
            end
            
            for s = 1:numel(Object.Sets)
                
                % Index of the current set
                ns = mod(floor((n-1)/Object.Modulos(s)),Object.Sets(s).Cardinal)+1;
                
                % Extraction of the element at specified index
                if Object.PresenceOfCells 
                    if iscell(Object.Sets(s).Elements)
                        T(:,s) = Object.Sets(s).Elements(ns);
                    else
                        for i = 1:numel(ns)
                            T{i,s} = Object.Sets(s).Elements(ns(i));
                        end
                    end
                else
                    T(:,s) = Object.Sets(s).Elements(ns);
                end
                
            end
            
        end
        
        % Method 'getCardinal'
        function Cardinal = getCardinal(Object)
            
            Cardinal = Object.Cardinal;
            
        end
                                                                                                        
    end
    
    % Static method
    methods (Static)
         
        % Method 'getTuple'
        function T = getTuples(varargin)
            
            CP = CartesianProduct(varargin{:});
            
            T = CP.getTuple();
            
        end
    
    end
     
end
