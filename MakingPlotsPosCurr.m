h = findobj(gca,'Type','line');
for k = 1:5,
    x(k,:)=get(h(k),'Xdata');
    y(k,:)=get(h(k),'Ydata');
end

figure;
hold;
for k = 1:5,
    plot(x(k,:),-y(k,:));
end


