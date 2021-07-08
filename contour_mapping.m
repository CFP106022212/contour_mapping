clc;clear;
file = 'example.xlsx';
data = xlsread(file,"F");
size_of_data = size(data);

x = data(1,2:size_of_data(2));
y = data(2:size_of_data(1),1);
F = data(2:size_of_data(1),2:size_of_data(2));

[xx, yy] = meshgrid(x, y);

x1 = reshape(xx,[],1);
y1 = reshape(yy,[],1);
F1 = reshape(F ,[],1);

F_fn = fit([x1, y1],F1,'poly33');


data = xlsread(file,"Q");
Q   = data(2:6,2:6);
Q1  = reshape(Q ,[],1);

Q_inv_fn = fit([x1,y1],1./Q1,'poly33');


figure('outerposition',get(0,'screensize'));

subplot(2,2,1)
plot(F_fn,[x1,y1],F1);
xlabel([char(949) '_{r}' '^{''}'])
ylabel([char(949) '^{''''}' '/' char(949) '^{''}'])
zlabel('F')

subplot(2,2,2)
plot(Q_inv_fn,[x1,y1],1./Q1);
xlabel([char(949) '_{r}' '^{''}'])
ylabel([char(949) '^{''''}' '/' char(949) '^{''}'])
zlabel('1/Q')


subplot(2,2,3)
scatter3(x1,y1,Q1,'filled');hold on;

xi = linspace(min(x),max(x),50);
yi = transpose(linspace(min(y),max(y),50));
[xxi, yyi] = meshgrid(xi, yi);
xi1 = reshape(xxi,[],1);
yi1 = reshape(yyi,[],1);
z = 1./Q_inv_fn(xi1,yi1);

surf(xxi,yyi,reshape(z ,[],sqrt(length(z))));hold off;
zlabel('Q')
xlabel([char(949) '_{r}' '^{''}'])
ylabel([char(949) '^{''''}' '/' char(949) '^{''}'])


N  = 9;
xi = linspace(min(x),max(x),N);
yi = transpose(linspace(min(y),max(y),N));
[xxi, yyi] = meshgrid(xi, yi);
Qi = zeros(N,N);
Fi = zeros(N,N);

for i = 1:N
    for j = 1:N
        Fi(j,i) = F_fn(xi(i),yi(j));
        Qi(j,i) = 1/Q_inv_fn(xi(i),yi(j));
    end 
end

x1_output = reshape(xxi,[],1);
y1_output = reshape(yyi,[],1);
F_output  = reshape(Fi,[],1);
Q_output  = reshape(Qi,[],1);

xlswrite('F.xlsx',[x1_output,y1_output,F_output]);
xlswrite('Q.xlsx',[x1_output,y1_output,Q_output]);

%key your data here
Q_data = [1100,200];
F_data = [2.38,2.37];

options = optimoptions('fsolve','Display','final-detailed');
result = zeros(length(Q_data),2);
for i = 1:length(Q_data)
    fun = @(x) [1/Q_inv_fn(x(1),x(2))-Q_data(i),F_fn(x(1),x(2))-F_data(i)];
    x0  = [8,0.02]; %initial guess
    result(i,:) = fsolve(fun,x0,options);
end


subplot(2,2,4)
contour(xxi,yyi,Fi,'ShowText','on'); hold on;
contour(xxi,yyi,Qi,'ShowText','on')
title('contour')
colormap(gca,'gray')
xlabel([char(949) '_{r}' '^{''}'])
ylabel([char(949) '^{''''}' '/' char(949) '^{''}'])

scatter(result(:,1),result(:,2),80,'filled');hold off;

disp(result);