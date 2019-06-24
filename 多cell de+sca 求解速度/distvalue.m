function [ distance ] = distvalue( CUE,BS )
dist=sqrt((CUE(1,1)-BS(1,1))^2+(CUE(1,2)-BS(1,2))^2);
distance=dist*1000;

end

