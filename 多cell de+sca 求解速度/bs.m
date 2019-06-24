i=0;
while i<5
a=rand(1,1);
b=rand(1,1);
distance=sqrt(a^2+b^2);
if distance*1000<500
    disp(distance)
    i=i+1;
    disp([a,b]);
end
end