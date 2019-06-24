function [value] = fun(powervalue,BSgain,D2Dgain,D2DarrayGroup,num,N_0,pd,CUEnum,D2Dnum,CUEBSarrayGroup,CUEarrayGroup,BSnum)

value=0;
cuenoise=0;
d2dnoise=0;
for i=1:D2Dnum
   for bs=1:BSnum
       for j=1:CUEnum
           m=D2DarrayGroup(num,i);%表明是哪个信道
           if CUEBSarrayGroup(num,j)==bs&&CUEarrayGroup(num,j)==m
               cuenoise=powervalue(num,j)*(BSgain(bs*2,i)^2)+cuenoise;
           end
       end
   end
   for z=1:D2Dnum
       if z~=i
           m=D2DarrayGroup(num,i);%表明是哪个信道
           if D2DarrayGroup(num,z)==m
               d2dnoise=pd*(D2Dgain(i,z)^2)+d2dnoise;
           end
       end
   end 
   noise=(D2Dgain(i,i)^2)*pd/(cuenoise+d2dnoise+N_0^2);
   value=log2(1+noise)+value;
   cuenoise=0;
   d2dnoise=0;
end

end

