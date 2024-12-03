function DibujaAlgoritmo(CosEqui,j,Resultados)
col=[0. 0.4470 0.7410;0.9290 0.6940 0.1250;0.4660 0.6740 0.1880];
yyaxis left
plot(CosEqui(j,:),'s-','LineWidth',3)
xlabel('Iterate')
ylabel('Pay Off')
grid on
ax=gca;
ax.FontSize=18;
ax.ColorOrder = col(j,:)

%%%%%%%%%%%
yyaxis right
iter=length(Resultados.Yn);
for i=1:iter
 n_estra(i)=length(unique(Resultados.stra{i}(:,j)));
end
stem(n_estra,'LineWidth',2)
ax=gca;
ax.FontSize=18;
ax.ColorOrder = [0,0,0];
yticks([0,1,2,3,4])
axis([0,11,0,4])
grid on
name_toc=['TOC' num2str(j)]
legend({name_toc','# stra.'})