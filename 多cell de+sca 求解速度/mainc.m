function [orivalues,u,v]=mainc(BSgain,D2Dgain,D2DarrayGroup,pc,N_0,CUEnum,D2Dnum,BSnum,pd,vpm,vdm,vbm,ub,vb)
%MAINC 此处显示有关此函数的摘要
%  求解目标函数值
             

orivalues=0;
u=zeros(1,15);
v=zeros(1,15);
cuenoise=0;
d2dnoise=0;
for i=1:D2Dnum
   for bs=1:BSnum
       for j=1:CUEnum
           m=D2DarrayGroup(1,i);%表明是哪个信道
           if vbm(bs,j)==1&&vpm(m,j)==1
               cuenoise=pc(1,j)*(BSgain(bs*2,i)^2)+cuenoise;
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
   sinr=(D2Dgain(i,i)^2*pd(1,i))/(cuenoise+d2dnoise+N_0^2);
   u(1,i)=sinr/(1+sinr);
   v(1,i)=log2(1+sinr)-u(1,i);
   orivalue=(ub(1,i)*log(sinr)+vb(1,i))/log(2);
   orivalues=orivalues+orivalue;
   cuenoise=0;
   d2dnoise=0;
end
                    
end

