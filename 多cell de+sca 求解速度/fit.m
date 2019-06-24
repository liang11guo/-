function [ values ] = fit( BSgain,multigain,D2Dgain,D2DarrayGroup,CUEarrayGroup,P_BS_1,N_0,CUEnum,D2Dnum,channelnum,totalnum,CUEBSarrayGroup ,powervalue,P_BS_2,BSnum)
pd_dbm=10;
pd=10^((pd_dbm-30)/10);
values=zeros(totalnum,1);
powerlimit=1;
%这里功率直接给与分配完成
for i=1:totalnum

   values(i,1)=fun(powervalue,BSgain,D2Dgain,D2DarrayGroup,i,N_0,pd,CUEnum,D2Dnum,CUEBSarrayGroup,CUEarrayGroup,BSnum);
end
%这一步是功率修正，但是多基站情况下要按照多基站修复

%首先建立用户排序表
vpm=zeros(totalnum,CUEnum);
%然后进行提取同一个信道同一个基站的CUE用户
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
          %CUE用户加入后进行排序
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
          %排序完成后加入到对应的数组中
          if mark~=0
          for p=1:mark
              vpm(totaloutside,y(p))=p;
          end
          end
       end
   end
end

for countnum=1:totalnum
%区分基站来进行计算
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
%这一步进行CUE传输速率的限制

for cuecount=1:CUEnum
    cuenoise=0;
    cuenoisein=0;
    d2dnoise=0;
    for cuen=1:CUEnum
        if cuen~=cuecount&&CUEarrayGroup(countnum,cuen)==CUEarrayGroup(countnum,cuecount)
          %这一步指出了与对比的CUE是否占用同一个信道
          %其次进行进一步的划分选择，就是此用户是否属于同一基站，属于同一基站的算一种情况，否则算另一种
          if CUEBSarrayGroup(countnum,cuecount)==CUEBSarrayGroup(countnum,cuen)
              %如果是同一基站同一信道的情况下要进行干扰判断
             %re=judge(countnum,cuecount,cuen,BSgain,multigain,D2Dgain,D2DarrayGroup,CUEarrayGroup,powervalue,CUEBSarrayGroup,CUEnum,D2Dnum,N_0,pd);
             
             if vpm(countnum,cuecount)>vpm(countnum,cuen)
                 cuenoisein=cuenoisein+powervalue(countnum,cuen)*(BSgain(CUEBSarrayGroup(countnum,cuen)*2-1,cuecount)^2);
             end
              
          else
              %这里是不同基站同信道之间的CUE用户之间的干扰
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


