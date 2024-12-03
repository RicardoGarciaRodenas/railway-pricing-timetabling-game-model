function DibujaSolution(TOCs,Demand,filname_fig,escala)
estilo={'o-b','s--r','*-k'};

for s=1:2
    figure(s)
    for i=1:TOCs.nTOC
        hold on
        indices=find(TOCs.data{i,2}(s,:)==1);
        precios=TOCs.data{i,3}(s,indices);
        t=Demand.t(indices);
        plot(t,precios,estilo{i},'LineWidth',2, 'MarkerSize',8)
        hold on
        xlabel('Time of Day')
        ylabel('Prices')
        grid on
        ax=gca;
        ax.FontSize=18;
        if nargin==4
        axis(escala)
        end
    end
    if nargin>=3
        print(filname_fig,'-depsc')
    end
end

