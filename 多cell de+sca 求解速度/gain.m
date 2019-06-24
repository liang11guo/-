function [value] = gain(coordinate1,coordinate2)
dist=sqrt((coordinate1(1,1)-coordinate2(1,1))^2+(coordinate1(1,2)-coordinate2(1,2))^2);
dist=dist*1000;
value=dist^(-4);
end
 