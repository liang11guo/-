function [values]=fitin(BSgain,multigain,D2Dgain,D2DarrayGroup,pc,CUEarrayGroup,CUEBSarrayGroup,P_BS_1,P_BS_2,N_0,CUEnum,D2Dnum,BSnum,vpm,vdm,vbm,vtm,pd)
%FIT �˴���ʾ�йش˺�����ժҪ
%   ����������Ӧ�Ⱥ���ֵ



%      vtm(s,:)=comparatortemp(channelnum,D2Dnum,CUEnum,pc(s,:),BSnum,vbm,t,vdm,vpm,multigain,BSgain,pd(s,:),N_0);%����õ�vpm�ŵ����

    values=funin(BSgain,D2Dgain,D2DarrayGroup,N_0,CUEnum,D2Dnum,pd,vpm,vdm,pc,vbm,BSnum);   


 %����ͬһ��վ�Ϲ��ʵıȽϿ��Ƿ����㲻���ڻ�վ�ṩ���ܹ���

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

 
 %��һ������CUE�������ʵ�����
powerlimit=1;
        for cuecount=1:CUEnum
            cuenoise=0;
            cuenoisein=0;
            d2dnoise=0;
            for cuen=1:CUEnum
                if cuen~=cuecount&&CUEarrayGroup(1,cuen)==CUEarrayGroup(1,cuecount)
                  %��һ��ָ������Աȵ�CUE�Ƿ�ռ��ͬһ���ŵ�
                  %��ν��н�һ���Ļ���ѡ�񣬾��Ǵ��û��Ƿ�����ͬһ��վ������ͬһ��վ����һ���������������һ��
                  if CUEBSarrayGroup(1,cuecount)==CUEBSarrayGroup(1,cuen)
                      %�����ͬһ��վͬһ�ŵ��������Ҫ���и����ж�
                     if vtm(1,cuecount)>vtm(1,cuen)
                         cuenoisein=cuenoisein+pc(1,cuen)*(BSgain(CUEBSarrayGroup(1,cuen)*2-1,cuecount)^2);
                     end

                  else
                      %�����ǲ�ͬ��վͬ�ŵ�֮���CUE�û�֮��ĸ���
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


