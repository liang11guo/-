function [values]=fitin(BSgain,multigain,D2Dgain,D2DarrayGroup,pc,CUEarrayGroup,CUEBSarrayGroup,P_BS_1,P_BS_2,N_0,CUEnum,D2Dnum,BSnum,vpm,vdm,vbm,vtm,pd)
%FIT 此处显示有关此函数的摘要
%   用来计算适应度函数值



%      vtm(s,:)=comparatortemp(channelnum,D2Dnum,CUEnum,pc(s,:),BSnum,vbm,t,vdm,vpm,multigain,BSgain,pd(s,:),N_0);%这里得到vpm信道情况

    values=funin(BSgain,D2Dgain,D2DarrayGroup,N_0,CUEnum,D2Dnum,pd,vpm,vdm,pc,vbm,BSnum);   


 %进行同一基站上功率的比较看是否满足不大于基站提供的总功率

     for bs=1:BSnum
         wholepower=0;
         for cou=1:CUEnum
             if CUEBSarrayGroup(1,cou)==bs
                 wholepower=wholepower+pc(1,cou);
             end
         end
         if bs==1
             if wholepower>P_BS_1&&values>0
                 values=-values;
             end
         else
             if wholepower>P_BS_2&&values>0
                 values=-values;
             end
         end
         
     end

 
 %这一步进行CUE传输速率的限制
powerlimit=1;
        for cuecount=1:CUEnum
            cuenoise=0;
            cuenoisein=0;
            d2dnoise=0;
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
                      cuenoise=pc(1,cuen)*(BSgain(CUEBSarrayGroup(1,cuen)*2-1,cuecount)^2)+cuenoise;
                  end
                end
            end
            for d2dn=1:D2Dnum
                if D2DarrayGroup(1,d2dn)==CUEarrayGroup(1,cuecount)
                    d2dnoise=pd(1,d2dn)*(multigain(cuecount,d2dn)^2)+d2dnoise;
                end
            end
            sinr1=(pc(1,cuecount)*BSgain(CUEBSarrayGroup(1,cuecount)*2-1,cuecount)^2);
            sinr2=(cuenoise+d2dnoise+cuenoisein+(N_0^2));
            sinr=sinr1/sinr2;
            if sinr<powerlimit
                if values>0
                values=-values;
                break;
                end
            end
        end
 

 
 end


