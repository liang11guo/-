function [ re ] = judge( countnum,cuecount,cuen,BSgain,multigain,D2Dgain,D2DarrayGroup,CUEarrayGroup,powervalue,CUEBSarrayGroup ,CUEnum,D2Dnum,N_0,pd)
%������и��ŵıȽϲ������壬1���ڼ��飬2���ڼ���cue���룬3���ڼ���cue���бȶ�
cuenoise1in=0;
cuenoise1out=0;
cuenoise2in=0;
cuenoise2out=0;
d2dnoise1=0;
d2dnoise2=0;
for i=1:CUEnum
    %����ȷ��ͬһ�ŵ�
    if i~=cuen&&CUEarrayGroup(countnum,i)==CUEarrayGroup(countnum,cuen)
        %���ȷ���Ƿ���ͬһ����վ
        if CUEBSarrayGroup(countnum,cuen)==CUEBSarrayGroup(countnum,i)
            cuenoise1in=cuenoise1in+powervalue(countnum,i)*(BSgain(CUEBSarrayGroup(countnum,cuecount)*2-1,cuecount)^2);
            cuenoise2in=cuenoise2in+powervalue(countnum,i)*(BSgain(CUEBSarrayGroup(countnum,cuecount)*2-1,cuen)^2);
        else
            %����һ����վͬ�ŵ�����ļ���
            cuenoise1out=cuenoise1out+powervalue(countnum,i)*(BSgain(CUEBSarrayGroup(countnum,i)*2-1,cuecount)^2);
            cuenoise2out=cuenoise2out+powervalue(countnum,i)*(BSgain(CUEBSarrayGroup(countnum,i)*2-1,cuen)^2);
            
        end
        
        
    end
    
end
for j=1:D2Dnum
    if CUEarrayGroup(countnum,cuen)==D2DarrayGroup(countnum,j)
        %ͬ�ŵ���D2D����
        d2dnoise1=d2dnoise1+pd*(multigain(cuecount,j)^2);
        d2dnoise2=d2dnoise2+pd*(multigain(cuen,j)^2);
    end
end
re=0;
re1=(powervalue(countnum,cuen)*(BSgain(CUEBSarrayGroup(countnum,cuecount)*2-1,cuecount)^2))/(cuenoise1in+cuenoise1out+d2dnoise1+(N_0^2));
re2= (powervalue(countnum,cuen)*(BSgain(CUEBSarrayGroup(countnum,cuecount)*2-1,cuen)^2))/(cuenoise2in+cuenoise2out+d2dnoise2+(N_0^2));
if re1>=re2
    re=1;
end


end

