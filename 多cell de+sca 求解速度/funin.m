function [value] = funin(BSgain,D2Dgain,D2DarrayGroup,N_0,CUEnum,D2Dnum,pd,vpm,vdm,pcpower,vbm,BSnum)

value=0;
cuenoise=0;
d2dnoise=0;
for i=1:D2Dnum
   for bs=1:BSnum
       for j=1:CUEnum
           m=D2DarrayGroup(1,i);%表明是哪个信道
           if vbm(bs,j)==1&&vpm(m,j)==1
               cuenoise=pcpower(1,j)*(BSgain(bs*2,i)^2)+cuenoise;
           end
       end
   end
   for z=1:D2Dnum
       if z~=i
           m=D2DarrayGroup(1,i);%表明是哪个信道
           if vdm(m,z)==1
               d2dnoise=pd(1,z)*(D2Dgain(i,z)^2)+d2dnoise;
           end
       end
   end 
   noise=(D2Dgain(i,i)^2)*pd(1,i)/(cuenoise+d2dnoise+N_0^2);
   value=log2(1+noise)+value;
   cuenoise=0;
   d2dnoise=0;
end

end

