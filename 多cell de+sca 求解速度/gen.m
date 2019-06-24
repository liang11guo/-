clc;
x=rand(50,1);
y=rand(50,1);
for i=1:50
   if sqrt((x(i,1)*1000)^2+(y(i,1)*1000)^2)<=450&&sqrt((x(i,1)*1000)^2+(y(i,1)*1000)^2)>330
       disp(x(i,1));
       disp(y(i,1));
   end
end