function [ poweri ] = powerfix(powervalue,BSgain,D2Dgain,D2DarrayGroup,countnum,N_0,pd,CUEnum,D2Dnum,CUEBSarrayGroup,CUEarrayGroup,multigain,P_BS_2,BSnum,totalnum,channelnum)
for ft=1:CUEnum*10
    %���Ƚ����û������
vpm=zeros(totalnum,CUEnum);
%Ȼ�������ȡͬһ���ŵ�ͬһ����վ��CUE�û�
   for channeloutside=1:channelnum
       for BS=1:BSnum
           y=[];
           mark=0;
          for cueoutside=1:CUEnum
              if CUEBSarrayGroup(countnum,cueoutside)==BS&&CUEarrayGroup(countnum,cueoutside)==channeloutside
                  y(mark+1)=cueoutside;
                  mark=mark+1;
              end
          end
          %CUE�û�������������
          if mark~=0&&mark~=1
              for w=1:mark
                  for in=1:mark-w
                      if judge(countnum,y(in),y(in+1),BSgain,multigain,D2Dgain,D2DarrayGroup,CUEarrayGroup,powervalue,CUEBSarrayGroup,CUEnum,D2Dnum,N_0,pd)==0;
                          temp=y(in);
                          y(in)=y(in+1);
                          y(in+1)=temp;
                      end
                  end
              end
          end
          %������ɺ���뵽��Ӧ��������
          if mark~=0
          for p=1:mark
              vpm(countnum,y(p))=p;
          end
          end
       end
   end
    %��Ը�����CUE���й����ϵ�����
    vcpsize=0;
    vcp=zeros(CUEnum,1);
    for vcps=1:CUEnum
        if vpm(countnum,vcps)>vcpsize
            vcpsize=vpm(countnum,vcps);
        end
        vcp(vcps)=vcps;
    end
    for vc=1:CUEnum
        for vcin=1:CUEnum-vc
            if powervalue(countnum,vcp(vcin,1))>powervalue(countnum,vcp(vcin+1,1))
                tempvc=vcp(vcin,1);
                vcp(vcin,1)=vcp(vcin+1,1);
                vcp(vcin+1,1)=tempvc;
            end
        end
    end
    for arrcount=1:vcpsize
    for cuecount=1:CUEnum
    if vpm(countnum,vcp(cuecount))==arrcount
    cuenoise=0;
    cuenoisein=0;
    d2dnoise=0;
    for cuen=1:CUEnum
        if cuen~=cuecount&&CUEarrayGroup(countnum,vcp(cuen,1))==CUEarrayGroup(countnum,vcp(cuecount,1))
          %��һ��ָ������Աȵ�CUE�Ƿ�ռ��ͬһ���ŵ�
          %��ν��н�һ���Ļ���ѡ�񣬾��Ǵ��û��Ƿ�����ͬһ��վ������ͬһ��վ����һ���������������һ��
          if CUEBSarrayGroup(countnum,vcp(cuecount,1))==CUEBSarrayGroup(countnum,vcp(cuen,1))
              %�����ͬһ��վͬһ�ŵ��������Ҫ���и����ж�
             if vpm(countnum,vcp(cuecount,1))>vpm(countnum,vcp(cuen,1))
                 cuenoisein=cuenoisein+powervalue(countnum,vcp(cuen,1))*(BSgain(CUEBSarrayGroup(countnum,vcp(cuen,1))*2-1,vcp(cuecount,1))^2);
             end
              
          else
              %�����ǲ�ͬ��վͬ�ŵ�֮���CUE�û�֮��ĸ���
              cuenoise=powervalue(countnum,vcp(cuen,1))*(BSgain(CUEBSarrayGroup(countnum,vcp(cuen,1))*2-1,vcp(cuecount,1))^2)+cuenoise;
          end
        end
    end
    for d2dn=1:D2Dnum
        if D2DarrayGroup(countnum,d2dn)==CUEarrayGroup(countnum,vcp(cuecount,1))
            d2dnoise=pd*(multigain(vcp(cuecount,1),d2dn)^2)+d2dnoise;
        end
    end
    %sinr1=(powervalue(countnum,cuecount)*BSgain(CUEBSarrayGroup(countnum,cuecount)*2-1,cuecount)^2);
    sinr2=(cuenoise+d2dnoise+cuenoisein+(N_0^2));
    sinr1=(BSgain(CUEBSarrayGroup(countnum,vcp(cuecount,1))*2-1,vcp(cuecount,1))^2);
    val=sinr2/sinr1;
    if isnan(val)||val==inf||val>15
        continue;
    end
%     if val<powervalue(countnum,cuecount)
    powervalue(countnum,vcp(cuecount,1))=val;
%     end
   end
   end
   end
end
poweri=powervalue(countnum,:);

end

