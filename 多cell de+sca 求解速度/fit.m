function [ values ] = fit( BSgain,multigain,D2Dgain,D2DarrayGroup,CUEarrayGroup,P_BS_1,N_0,CUEnum,D2Dnum,channelnum,totalnum,CUEBSarrayGroup ,powervalue,P_BS_2,BSnum)
pd_dbm=10;
pd=10^((pd_dbm-30)/10);
values=zeros(totalnum,1);
powerlimit=1;
%���﹦��ֱ�Ӹ���������
for i=1:totalnum

   values(i,1)=fun(powervalue,BSgain,D2Dgain,D2DarrayGroup,i,N_0,pd,CUEnum,D2Dnum,CUEBSarrayGroup,CUEarrayGroup,BSnum);
end
%��һ���ǹ������������Ƕ��վ�����Ҫ���ն��վ�޸�

%���Ƚ����û������
vpm=zeros(totalnum,CUEnum);
%Ȼ�������ȡͬһ���ŵ�ͬһ����վ��CUE�û�
for totaloutside=1:totalnum
   for channeloutside=1:channelnum
       for BS=1:BSnum
           y=[];
           mark=0;
          for cueoutside=1:CUEnum
              if CUEBSarrayGroup(totaloutside,cueoutside)==BS&&CUEarrayGroup(totaloutside,cueoutside)==channeloutside
                  y(mark+1)=cueoutside;
                  mark=mark+1;
              end
          end
          %CUE�û�������������
          if mark~=0&&mark~=1
              for w=1:mark
                  for in=1:mark-w
                      if judge(totaloutside,y(in),y(in+1),BSgain,multigain,D2Dgain,D2DarrayGroup,CUEarrayGroup,powervalue,CUEBSarrayGroup,CUEnum,D2Dnum,N_0,pd)==0;
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
              vpm(totaloutside,y(p))=p;
          end
          end
       end
   end
end

for countnum=1:totalnum
%���ֻ�վ�����м���
for bsf=1:BSnum
    wholepower=0;
    for countin=1:CUEnum
        if CUEBSarrayGroup(countnum,countin)==bsf
        wholepower=wholepower+powervalue(countnum,countin);
        end
    end
    if bsf==1
    if wholepower>P_BS_1&&values(countnum,1)>0
        values(countnum,1)=-values(countnum,1);
    end
    else
    if wholepower>P_BS_2&&values(countnum,1)>0
        values(countnum,1)=-values(countnum,1);
    end
    end 
end
%��һ������CUE�������ʵ�����

for cuecount=1:CUEnum
    cuenoise=0;
    cuenoisein=0;
    d2dnoise=0;
    for cuen=1:CUEnum
        if cuen~=cuecount&&CUEarrayGroup(countnum,cuen)==CUEarrayGroup(countnum,cuecount)
          %��һ��ָ������Աȵ�CUE�Ƿ�ռ��ͬһ���ŵ�
          %��ν��н�һ���Ļ���ѡ�񣬾��Ǵ��û��Ƿ�����ͬһ��վ������ͬһ��վ����һ���������������һ��
          if CUEBSarrayGroup(countnum,cuecount)==CUEBSarrayGroup(countnum,cuen)
              %�����ͬһ��վͬһ�ŵ��������Ҫ���и����ж�
             %re=judge(countnum,cuecount,cuen,BSgain,multigain,D2Dgain,D2DarrayGroup,CUEarrayGroup,powervalue,CUEBSarrayGroup,CUEnum,D2Dnum,N_0,pd);
             
             if vpm(countnum,cuecount)>vpm(countnum,cuen)
                 cuenoisein=cuenoisein+powervalue(countnum,cuen)*(BSgain(CUEBSarrayGroup(countnum,cuen)*2-1,cuecount)^2);
             end
              
          else
              %�����ǲ�ͬ��վͬ�ŵ�֮���CUE�û�֮��ĸ���
              cuenoise=powervalue(countnum,cuen)*(BSgain(CUEBSarrayGroup(countnum,cuen)*2-1,cuecount)^2)+cuenoise;
          end
        end
    end
    for d2dn=1:D2Dnum
        if D2DarrayGroup(countnum,d2dn)==CUEarrayGroup(countnum,cuecount)
            d2dnoise=pd*(multigain(cuecount,d2dn)^2)+d2dnoise;
        end
    end
    sinr1=(powervalue(countnum,cuecount)*BSgain(CUEBSarrayGroup(countnum,cuecount)*2-1,cuecount)^2);
    sinr2=(cuenoise+d2dnoise+cuenoisein+(N_0^2));
    sinr=sinr1/sinr2;
    if sinr<powerlimit
        if values(countnum,1)>0
        values(countnum,1)=-values(countnum,1);
        break;
        end
    end
end

end
end


