clear;

u = struct;
u.x = [-1;-0.912977362469901;-0.825435598786988;-0.737231137819317;-0.648159638861973;-0.557911327650507;-0.465976322905351;-0.371414297989034;-0.272163227458814;-0.162047461426620;0.00183668290631786;0.165628758546945;0.275567566681028;0.374565497007633;0.468805771103459;0.560358952232373;0.650174954786129;0.738774153117805;0.826477506404825;0.913500989255511;1]
u.y = [0;-19.5213625811391;-37.0557183574867;-52.6132164906106;-66.2033278467701;-77.8346224921832;-87.5145713679742;-95.2493742213525;-101.043806890354;-104.901009997107;-106.819932345682;-104.908235757055;-101.057750380050;-95.2690120450200;-87.5384025200256;-77.8607251266494;-66.2294345559485;-52.6368058814146;-37.0741200351357;-19.5318721128172;0]
ball_x = 1+0.1;
ball_y = 0;
ball_v = 0;

N = length(u.x)

m = 1;
k = 2;
a = -1;
b = 1;
g = 4;
dt = 0.1;
l0 = 0.951314879522022;

V = struct;
V.x = zeros(2,N)
V.y = zeros(2,N)
X = linspace(a,b,N);


t_max = 100
num_steps = t_max/dt;
T = 0:dt:t_max-dt



Acc_right = [];
V_right = [];

fig1 = figure
ax = gca;

h = animatedline(ax, u.x, u.y, "Color", "red", "Marker", "o")
ax.XGrid = "on"
ax.YGrid = "on"
ax.XLabel.String = "x"
ax.YLabel.String = "y"
hold(ax, "on")
axis("equal")


ax.Title.String = "t = "

for i = 1:num_steps
    for ind = 1:N
        if ind == 1
            V.x(i+1,ind) = 0;
            V.y(i+1,ind) = 0;
            
        elseif ind == N
            lL = sqrt((u.x(ind) - u.x(ind-1))^2 + (u.y(ind)-u.y(ind-1))^2);
            FL = -(lL - l0) * k;
            F.x = (u.x(ind) - u.x(ind-1))*FL/lL;
            F.y = (u.y(ind) - u.y(ind-1))*FL/lL - m*g;
            
            V.x(i+1,ind) = V.x(i,ind) + F.x/m*dt;
            V.y(i+1,ind) = V.y(i,ind) + F.y/m*dt;
            ball_v = ball_v - g*dt;
            
            a_right = sqrt((F.x/m)^2 + (F.y/m)^2);
            v_right = sqrt((V.x(i,ind)/m)^2 + (V.y(i,ind)/m)^2);
            
            Acc_right = [Acc_right, a_right];
            
            V_right = [V_right, v_right];
     
        else
            lR = sqrt((u.x(ind) - u.x(ind+1))^2 + (u.y(ind)-u.y(ind+1))^2);
            lL = sqrt((u.x(ind) - u.x(ind-1))^2 + (u.y(ind)-u.y(ind-1))^2);
            FR = -(lR - l0) * k;
            FL = -(lL - l0) * k;
            F.x = (u.x(ind) - u.x(ind+1))/lR*FR + (u.x(ind) - u.x(ind-1))*FL/lL;
            F.y = (u.y(ind) - u.y(ind+1))/lR*FR + (u.y(ind) - u.y(ind-1))*FL/lL - m*g;
            
            V.x(i+1,ind) = V.x(i,ind) + F.x/m*dt;
            V.y(i+1,ind) = V.y(i,ind) + F.y/m*dt;
            
        end
            
        
        u.x(ind)
        V.x(i+1, ind)
        u.x(ind) = u.x(ind) + V.x(i+1, ind)*dt;
        u.y(ind) = u.y(ind) + V.y(i+1, ind)*dt;
        
    end
    
  
    
    ball_y = ball_y + ball_v*dt
   
    addpoints(h, u.x, u.y)

    plot(ax, ball_x, ball_y, "dg")
    
    drawnow

    clearpoints(h)
    
end

figure
hold on
grid on

plot(T, Acc_right, "rd--")
plot(T, V_right, "gd--")

legend("Acceleration", "Speed")
xlabel("time")
