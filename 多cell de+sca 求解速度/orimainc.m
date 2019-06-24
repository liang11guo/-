function [orivalues,u,v,ud,vdd]=orimainc(vtm,BSgain,D2Dgain,multigain,D2DarrayGroup,CUEarrayGroup,CUEBSarrayGroup,pc,N_0,CUEnum,D2Dnum,BSnum,pd,vpm,vdm,vbm)
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
   orivalue=(u(1,i)*log(sinr)+v(1,i))/log(2);
   orivalues=orivalues+orivalue;
   cuenoise=0;
   d2dnoise=0;
end
                         
                         ud=zeros(1,CUEnum);
                         vdd=zeros(1,CUEnum);
                        for cuecount=1:CUEnum
                            cuenoise1=0;
                            cuenoisein=0;
                            d2dnoise1=0;
                       
                            for cuen=1:CUEnum
                                if cuen~=cuecount&&CUEarrayGroup(1,cuen)==CUEarrayGroup(1,cuecount)
                                  %这一步指出了与对比的CUE是否占用同一个信道
                                  %其次进行进一步的划分选择，就是此用户是否属于同一基站，属于同一基站的算一种情况，否则算另一种
                                  if CUEBSarrayGroup(1,cuecount)==CUEBSarrayGroup(1,cuen)
                                      %如果是同一基站同一信道的情况下要进行干扰判断
                                     if vtm(1,cuecount)>vtm(1,cuen)
                                         cuenoisein=cuenoisein+pc(1,cuen)*(BSgain(CUEBSarrayGroup(1,cuen)*2-1,cuecount)^2);
                                     end

                                  else
                                      %这里是不同基站同信道之间的CUE用户之间的干扰
                                      cuenoise1=pc(1,cuen)*(BSgain(CUEBSarrayGroup(1,cuen)*2-1,cuecount)^2)+cuenoise1;
                                  end
                                end
                            end
                            for d2dn=1:D2Dnum
                                if D2DarrayGroup(1,d2dn)==CUEarrayGroup(1,cuecount)
                                    d2dnoise1=pd(1,d2dn)*(multigain(cuecount,d2dn)^2)+d2dnoise1;
                                end
                            end
                            sinr1=(pc(1,cuecount)*BSgain(CUEBSarrayGroup(1,cuecount)*2-1,cuecount)^2);
                            sinr2=(cuenoise1+d2dnoise1+cuenoisein+(N_0^2));
                            sinr=sinr1/sinr2;
                            ud(1,cuecount)=sinr/(1+sinr);
                            vdd(1,cuecount)=log2(1+sinr)-ud(1,cuecount);
                        end

  
  

         
end

