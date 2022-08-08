function plot_pretty_bars(bar_heights)

blue = [0,50,190]/255;
red = [192,0,0]/255;

light_blue = [1,1,1] - ([1,1,1] - blue)*0.2;
light_red = [1,1,1] - ([1,1,1] - red)*0.2;

yticks = [0.25,0.50,0.75,1]; yticklabels = {'25%','50%','75%','100%'};

mbh = nanmean(bar_heights);
scr = mbh(1);
sir = mbh(2);
scu = mbh(3);
siu = mbh(4);

figure;
bar(1,scr,'FaceColor',light_blue,'LineWidth',5,'LineStyle','-','EdgeColor',blue); hold on
bar(2,sir,'FaceColor',light_blue,'LineWidth',5,'LineStyle','--','EdgeColor',blue);
bar(3,scu,'FaceColor',light_red,'LineWidth',5,'LineStyle','-','EdgeColor',red);
bar(4,siu,'FaceColor',light_red,'LineWidth',5,'LineStyle','--','EdgeColor',red)
errorbar(1:4,[scr,sir,scu,siu],nansem(bar_heights),'k.')
set(gca,'fontsize',30,'ytick',yticks,'yticklabels',yticklabels,'xticklabels','');
ylabel('Stay Probability','Fontsize',30);
ylim([0.1,1]); xlim([0.25,4.75])

end