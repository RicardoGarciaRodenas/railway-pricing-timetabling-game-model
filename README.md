# Code and experiments of the paper "A Game-based Model for Pricing and Timetabling in   Liberalised Passenger Railway Markets"
Authors:

* Ricardo García-Ródenas
* María Luz López-García
* Julio Alberto López-Gómez
* José Ángel Martín-Baos
* Nikola Bešinović
* Jan Eisold

These codes are associated with the paper "A Game-based Model for Pricing and Timetabling in   Liberalised Passenger Railway Markets"

If you use any part of the code or data provided in this repository, please cite it as:
García-Ródenas, R., M.L. López-García,J.A. López-Gómez, J.A. Martín-Baos, N. Bešinović, J. Eisold
 A Game-based Model for Pricing and Timetabling in Liberalised Passenger Railway Markets"

You can also access the preprint version of this paper on [arXiv](AÑADIR).


## Abstract

European Directives state a vertical separation governance structure in the railway  industry. Under this governance structure,  \glspl*{RU} compete in a  bidding process to obtain the rights to run trains on the liberalised corridors at the designated times and thus can provide transport services to passengers. The infrastructure resources are provided by the \gls*{IM} who  assesses the bids received, and allocates the resources to each \gls*{RU}. Then, the \glspl*{RU} optimise their timetables and fares to maximize their revenues while the passengers, depending on their utilities,  make the decision to travel with one or other company.

This article presents an equilibrium model aimed at examining the implications of cost structure in the process of liberalization within a passenger railway market. The model encompasses two interactions: (i) \glspl{RU} with \gls{IM} ({\sl on-rail competition}), and (ii) \glspl{RU} with passengers ({\sl off-rail competition}). Relationship (i) involves competition between \glspl{RU} for the railway capacity in order to design the most suitable timetables for the needs of the passengers. Once the train paths   have been allocated, the element (ii) models the pricing strategies among the \glspl{RU} so that, depending on the equilibrium prices, they obtain the highest revenue. The model incorporates the passenger's behaviour using a nested logit model. The resulting model has a hierarchical bi-level structure. At the upper level, equilibrium bids for the train paths are established  and at the lower level, equilibrium prices are obtained for the passenger rail services. A column generation method has been proposed to obtain equilibrium bids. This method iterates between  two problems: in the {\sl restricted master problem} it computes the equilibrium bids on the set of most promising strategies found, and in the {\sl column generation problem}, each \gls{RU} incorporates a new strategy that allows it to improve its economic results in the current equilibrium situation.  Numerical cases based on data from the Spanish \gls{HSR} Madrid-Barcelona are provided to validate the models and algorithms proposed.

## Software implementation

All source code used to generate the results and figures in the paper are contained in this repository. The code is written in MATLAB, and is organised in the following folders:

The `tex` folder contains the various tables (in latex) obtained  and the `fig` folder the figures.
The `filesMATLABCentral` contains Matlab functions used in the code. These functions are not coded by the authors. 

## Files

The purpose of the various .m files developed is described below:

0.	`InitializeProblem.m`: The InitializeProblem() function initializes four structures: TO (infrastructure data), TOCs (transport operators’ data), Demand (demand model parameters and utility function), and S (initialization of pure strategies). It sets up the test problem for the transportation scenario of Madrid-Barcelona.
1.  'Main.m': It is the main script and it calculates the railway market equilibrium, saving in a .mat file.
    List of functions used by "Main.m":

        - `InitializeProblem.m`: This MATLAB function initializes the test problem (corridor Madrid-Barcelona) by generating four structures: TO (infrastructure data), TOCs (transport operators’ data), Demand (parameters and utility function), and S (pure strategies setup).
        - `A.m`: Time slot allocation process performed by IM
        - `A_Proj.m` Time slot allocation process performed by IM but it avoids modifying the slots assigned to the other operators (it used in the heuristic CGA) 
        - `CGA.m`: This function solves the CGA problem
        - `Compute_demand.m`: Calculates the demand on each service based on the services available  and their prices
        - `EvaluaStrategia.m`: Evaluates the strategy using payoff for each TOC based on the assigned slots.
        - `Make_Request.m`: Randomly requests time slots for each TOC
        - `U0.m`: Compute the pay-offs for each operator
        - `Optimal_Prices.m`: This function integrates the calculation of equilibrium prices using 
                             the algorithm in the paper and MATLAB optimization algorithms to solve models.
        - `Sol_f_i.m`: This function computes the optimal prices for TOC i
        - `f_i.m`: Pay-off function for TOC i=o based on prices (Jo(Zo,Z_o))
       
   
2. 
    - `ProcessingExpEWGT2023.m`: processes the experimental data corresponding to EWGT2023. 
        The script mainOptimization.m generates the input ['./RESULTS/experiment1_' NameModel '.mat'] for this script

    - `ProcessingExpTRB.m`: processes the experimental data corresponding to the paper submitted to Transportation Research Part B. It use `DibujaAlgoritmo`.

     - TestEquilibriumPrices.m`: This script process the data for  Experiment 1: Price Equilibrium of the paper

# Dependencies

   - `Function table2latex(T, filename)`:  converts a given MATLAB(R) table into  a plain .tex file with LaTeX formatting.  This function is required in MainExperiment1.m and MainExperiment2.m. 
    The author of this function is Victor Martinez Cagigal.

   - `filesMATLABCentral/CartesianProduct.m`: computes a cartesian product. Author:E. Ogier 
  
   - `filesMATLABCentral/npg.m`: The function npg solves an n-person finite non-co-operative game to compute one sample Nash Equilibrium. 
      See B. Chatterjee, "An optimization formulation to compute Nash equilibrium in finite games," 2009 Proceeding of International Conference on Methods and Models in Computer Science (ICM2CS), New Delhi, India, 2009, pp. 1-5, doi: 10.1109/ICM2CS.2009.5397970. 
   - `filesMATLABCentral/gamer.m`: It is necessary `npg.m` 

   - Optimization Toolbox

   - Global Optimization Toolbox

## Bug reports and feature requests

If you encounter any issues or have ideas, you can contact us at ricardo.garcia@uclm.es.


## Getting the code

You can download a copy of all the files in this repository by cloning the
[git](https://git-scm.com/) repository:

    git clone https://github.com/RicardoGarciaRodenas/TAC-access-charge-for-freight-rail-transport.git

or [download a zip archive](https://github.com/RicardoGarciaRodenas/TAC-access-charge-for-freight-rail-transport/archive/refs/heads/main.zip).


## License

All source code is made available under a MIT license. You can freely
use and modify the code, without warranty, so long as you provide attribution
to the authors. See `LICENSE.md` for the full license text.

The manuscript text is not open source. The authors reserve the rights to the
article content, which is currently submitted for publication in 
*Transportation Research Part B: Methodological*.








