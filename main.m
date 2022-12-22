clear;

m = 1;
k = 100;
g = 1;
betta = 0;
gamma = 1;
N = 21;
a = -1;
b = 1;
dt = 0.01;

X = linspace(a,b,N);
V = struct;
V.x = zeros(2,N)
V.y = zeros(2,N)

t_max = 1000
num_steps = t_max/dt;

u = struct;
u.x = []
u.y = []

y = @(x) 10*x^2-10;
xx = @(x) x

for ind = 1:N
    u.x = [u.x; X(ind)];
    u.y = [u.y; y(X(ind))];
end

l0 = sqrt((u.y(2) - u.y(1))^2 + (u.x(2)-u.x(1))^2)/2;


fig1 = figure
h = animatedline(u.x, u.y, "Color", "red", "Marker", "o")
ax = gca
ax.XGrid = "on"
ax.YGrid = "on"

ax.XLabel.String = "x";
ax.YLabel.String = "y";
axis("equal")


for i = 1:num_steps
    for ind = 1:N
        if ind == 1
            V.x(i+1,ind) = 0;
            V.y(i+1,ind) = 0;
            
        elseif ind == N
            V.x(i+1,ind) = 0;
            V.y(i+1,ind) = 0;
            
        else
            lR = sqrt((u.x(ind) - u.x(ind+1))^2 + (u.y(ind)-u.y(ind+1))^2);
            lL = sqrt((u.x(ind) - u.x(ind-1))^2 + (u.y(ind)-u.y(ind-1))^2);
            FR = -(lR - l0) * k;
            FL = -(lL - l0) * k;
            
            
            frxR = ((V.x(i, ind+1)-V.x(i, ind))*(u.x(ind+1)-u.x(ind))+(V.y(i, ind+1)-V.y(i, ind))*(u.y(ind+1)-u.y(ind)))/lR * (u.x(ind+1) - u.x(ind));
            fryR = ((V.x(i, ind+1)-V.x(i, ind))*(u.x(ind+1)-u.x(ind))+(V.y(i, ind+1)-V.y(i, ind))*(u.y(ind+1)-u.y(ind)))/lR * (u.y(ind+1) - u.y(ind));
   
            frxL = ((V.x(i, ind-1)-V.x(i, ind))*(u.x(ind-1)-u.x(ind))+(V.y(i, ind-1)-V.y(i, ind))*(u.y(ind-1)-u.y(ind)))/lL * (u.x(ind-1) - u.x(ind));
            fryL = ((V.x(i, ind-1)-V.x(i, ind))*(u.x(ind-1)-u.x(ind))+(V.y(i, ind-1)-V.y(i, ind))*(u.y(ind-1)-u.y(ind)))/lL * (u.y(ind-1) - u.y(ind));
            
            stx = -(frxR + frxL);
            
            sty = -(fryR + fryL);
            
            F.x = (u.x(ind) - u.x(ind+1))/lR*FR + (u.x(ind) - u.x(ind-1))*FL/lL - betta * (stx) - gamma*V.x(i, ind);
            F.y = (u.y(ind) - u.y(ind+1))/lR*FR + (u.y(ind) - u.y(ind-1))*FL/lL - m*g - betta * (sty) - gamma*V.y(i,ind);
            
            V.x(i+1,ind) = V.x(i,ind) + F.x/m*dt;
            V.y(i+1,ind) = V.y(i,ind) + F.y/m*dt;
            
        end
            
        u.x = u.x + V.x(i+1, :)'.*dt;
        u.y = u.y + V.y(i+1, :)'.*dt;
        
        %absV = sum((V.x(i+1, :).*(V.y(i+1, :))).^2)
       
        
    end
    
    %plot(u.x, u.y, 'rd-')
    %title(["t = ", num2str(i*dt)])
    %axis([X(1),X(length(X)),-50,0]);
    
    addpoints(h, u.x, u.y);
    drawnow limitrate
    clearpoints(h);
end
drawnow



