clear all;
%close all;
N=1000;

% 产生噪声 xi是白噪声，e是有色噪声
c = [1 -0.5];
nc = length(c) - 1;
xik=zeros(nc,1);  %白噪声初值
xii=randn(N,1);  %产生均值为0，方差为1的高斯白噪声序列

for k=1:N
    e(k)=c*[xii(k);xik];  %产生有色噪声
    %数据更新
    for i=nc:-1:2
        xik(i)=xik(i-1);
    end
    xik(1)=xii(k);
end
% 无噪声
% rand_data = zeros(N, 1);
% 使用随机噪声
% rand_data = rand(N, 1);
% 使用白噪声
% rand_data = xii;
% 使用有色噪声
rand_data = e;

% 噪声减小10倍
rand_data = rand_data ./ 10;

%控制器参数
nu=1;
eita =1;
miu =1;
rou1=0.6;
rou2=0.6;
rou3=0.6;
rou4=0.6;
lamda =10;

%初值
%y(1:nu+1)=0;u(1:nu)=0;du(1:nu,1:nu)=0;
y(1)=-1;y(2)=1;y(3)=0.5;y(4)=0.5;
u(1:3)=0;
du(1:3,1:nu)=0;
%期望值
for k=1:N+1
    yd(k)=0.5+0.5*(-1)^round(k/200);
end
I=eye(nu);
%控制器伪偏导数初值
% fai(1:nu,1) =2;
% fai(1:nu,2:nu)=0;
fai(1:3,1) =2;
fai(1:3,2)=0.1;
fai(1:3,3)=0.1;
fai(1:3,4)=0.1;
xi(1:3) = 0.1;
%程序循环
for k=4:N
    a(k)=1+round(k/500);
    xi(k) = y(k)-y(k-1) - fai(k-1, :)*[du(k-1,1) xi(k - 1) xi(k - 2) xi(k - 3)]';
    fai(k, :)=fai(k-1, :)+eita*(y(k)-y(k-1)-fai(k-1,1)*du(k-1,1)' - fai(k - 1, 2) * xi(k - 1) - fai(k - 1, 3) * xi(k - 2) - fai(k - 1, 4) * xi(k - 3))*[du(k-1,1) xi(k - 1) xi(k - 2) xi(k - 3)];
    if (fai(k,1)<10^(-5)) || ((du(k-1,1:nu)*du(k-1,1:nu)')^0.5<10^(-5))
        fai(k,1)=2;
    end
    u(k) = u(k-1)+(rou1*fai(k,1)*(yd(k+1)-y(k)) - rou2*fai(k,1)*fai(k,2)*xi(k) - rou3*fai(k,1)*fai(k,3)*xi(k - 1) - rou4*fai(k,1)*fai(k,4)*xi(k - 2))/(lamda+fai(k,1).^2);
    %model
    b(k)=0.1+0.1*round(k/100);
    if k<=200
        y(k+1)=1.5*y(k)-0.7*y(k-1)+0.1*(u(k)+b(k)*u(k-1));    
    else if k<=400
            y(k+1)=1.5*y(k)-0.7*y(k-1)+0.1*(u(k-2)+b(k)*u(k-3));             
        else if k<=600
                y(k+1)=1.5*y(k)-0.7*y(k-1)+0.1*(u(k-4)+b(k)*u(k-5));             
            else if k<=800
                    y(k+1)=1.5*y(k)-0.7*y(k-1)+0.1*(u(k-6)+b(k)*u(k-7));             
                else
                        y(k+1)=1.5*y(k)-0.7*y(k-1)+0.1*(u(k-8)+b(k)*u(k-9));             
                end
            end
        end
    end
    
    y(k+1) = y(k+1) + rand_data(k);
                    
    for i=1:nu
        du(k,i)=u(k-i+1)-u(k-i);
    end
    emax(k+1)=yd(k+1)-y(k+1);
end
%%%%%%%%%%%%%%%%%%%%%%%%
%控制器参数
nu=1;
eita =1;
miu =1;
rou=0.6;
lamda =10;
%初值
%y(1:nu+1)=0;u(1:nu)=0;du(1:nu,1:nu)=0;
y2(1)=-1;y2(2)=1;y2(3)=0.5;
u2(1:2)=0;
du2(1:2,1:nu)=0;
%期望值
fai2(1:2,1) =2;
fai2(1:2,2:nu)=0;
for k=3:N
    a(k)=1+round(k/500);
    fai2(k,1:nu)=fai2(k-1,1:nu)+eita*(y2(k)-y2(k-1)-fai2(k-1,1:nu)*du2(k-1,1:nu)')*du2(k-1,1:nu)/(miu+du2(k-1,1:nu)*du2(k-1,1:nu)');
    if (fai2(k,1)<10^(-5)) %|| ((du(k-1,1:nu)*du(k-1,1:nu)')^0.5<10^(-5))
        fai2(k,1)=0.5;
    end
    if nu==1
        u2(k) = u2(k-1)+rou*fai2(k,1)*(yd(k+1)-y2(k))/(lamda+fai2(k,1).^2);        
    else
        u2(k) = u2(k-1)+rou*fai2(k,1)*(yd(k+1)-y2(k)-fai2(k,2:nu)*du2(k-1,1:nu-1)')/(lamda+fai2(k,1).^2); 
    end
    %model
    b(k)=0.1+0.1*round(k/100);
    if k<=200
        y2(k+1)=1.5*y2(k)-0.7*y2(k-1)+0.1*(u2(k)+b(k)*u2(k-1));    
    else if k<=400
            y2(k+1)=1.5*y2(k)-0.7*y2(k-1)+0.1*(u2(k-2)+b(k)*u2(k-3));             
        else if k<=600
                y2(k+1)=1.5*y2(k)-0.7*y2(k-1)+0.1*(u2(k-4)+b(k)*u2(k-5));             
            else if k<=800
                    y2(k+1)=1.5*y2(k)-0.7*y2(k-1)+0.1*(u2(k-6)+b(k)*u2(k-7));             
                else
                        y2(k+1)=1.5*y2(k)-0.7*y2(k-1)+0.1*(u2(k-8)+b(k)*u2(k-9));             
                end
            end
        end
    end
    y2(k+1) = y2(k+1) + rand_data(k);
    for i=1:nu
        du2(k,i)=u2(k-i+1)-u2(k-i);
    end
    emax(k+1)=yd(k+1)-y2(k+1);
end

% 求方差
% var_y = var(y, 1)
% var_y2 = var(y2, 1)
var_y = sum((y - yd).^ 2) / N
var_y2 = sum((y2 - yd).^ 2) / N

mark=8;
step=20;
figure(1)
plot(0,'-k','MarkerSize',mark,'LineWidth',2);hold on;
plot(0,'-.bs','MarkerSize',mark,'LineWidth',2);hold on;
plot(0,'--r^','MarkerSize',mark,'LineWidth',2);hold on;
set(gca,'LineWidth',2,'fontsize',28);
plot(yd,'k-','LineWidth',2);hold on;
plot(0:k,y,'-.b','LineWidth',2);hold on;
plot(1:step:N,y(1:step:N),'bs','MarkerSize',mark,'LineWidth',2);hold on;
plot(0:k,y2,'--r','LineWidth',2);
plot(10:step:N,y2(10:step:N),'r^','MarkerSize',mark,'LineWidth',2);hold on;
grid on;xlabel('时刻');ylabel('跟踪性能');legend({'y^{*}(k)','改进方法','\lambda=10时的输出y(k)'},'Interpreter','tex');
xlim([0,1000]);ylim([-1,2.8]);

figure(2)
plot(0,'-.bs','MarkerSize',mark,'LineWidth',2);hold on;
plot(0,'--r^','MarkerSize',mark,'LineWidth',2);hold on;
set(gca,'LineWidth',2,'fontsize',28);
plot(u,'-.b','LineWidth',2);hold on;
plot(1:step:N,u(1:step:N),'bs','MarkerSize',mark,'LineWidth',2);hold on;
plot(u2,'r--','LineWidth',2);
plot(10:step:N,u2(10:step:N),'r^','MarkerSize',mark,'LineWidth',2);hold on;
ylim([-1,2.7]);
grid on;xlabel('时刻');ylabel('控制输入');legend({'改进方法','\lambda=10时的控制输入u(k)'},'Interpreter','tex');


figure(3)
plot(0,'-.bs','MarkerSize',mark,'LineWidth',2);hold on;
plot(0,'--r^','MarkerSize',mark,'LineWidth',2);hold on;
set(gca,'LineWidth',2,'fontsize',28);
plot(fai,'-.b','LineWidth',2);hold on;
plot(1:step:N,fai(1:step:N),'bs','MarkerSize',mark,'LineWidth',2);hold on;
plot(fai2,'--r','LineWidth',2);grid on;
plot(10:step:N,fai2(10:step:N),'r^','MarkerSize',mark,'LineWidth',2);hold on;
ylim([-1,2.5]);
xlabel('时刻');ylabel('PPD估计值');legend({'改进方法','\lambda=10时PPD的估计值'},'Interpreter','tex');


%plot(yd,'k');hold on;
%plot(0:k,y,'b');hold on;
% figure
% plot(u,'b.');hold on;
% figure
% plot(fai);hold on;

