function [ powervalue ] = powergenerate( CUEBSarrayGroup,P_BS_1,CUEnum,totalnum,powervalue,P_BS_2,BSnum )
for i=1:totalnum
    flag=zeros(1,BSnum);%������¼ÿ����վ��֧�ֵ�CUE�û�����
    for count=1:CUEnum
       num=CUEBSarrayGroup(i,count);
       flag(1,num)=flag(1,num)+1;
    end
    %����ÿ����վ�û������Ѿ���¼���
    for countf=1:BSnum
        if flag(1,countf)==0
            continue;
        end
       if  flag(1,countf)==1
           if countf==1
           pro=rand(1,1);
           power=pro*P_BS_1;
           for cuecount=1:CUEnum
               if countf==CUEBSarrayGroup(i,cuecount)
               powervalue(i,cuecount)=power;
               end
           end
           end
           if countf~=1
                pro=rand(1,1);
           power=pro*P_BS_2;
           for cuecount=1:CUEnum
               if countf==CUEBSarrayGroup(i,cuecount)
               powervalue(i,cuecount)=power;
               end
           end
           end
       else
        pro=rand(1,flag(1,countf)-1);
        %��pro����ĸ��ʽ�������,С�ķ�ǰ��
        for out=1:flag(1,countf)-1
            for in=2:flag(1,countf)-out
                if pro(1,in)<pro(1,in-1)
                    tempvalue=pro(1,in);
                    pro(1,in)=pro(1,in-1);
                    pro(1,in-1)=tempvalue;
                end
            end
        end
        newpro=pro;
        for out2=1:flag(1,countf)-1
            if out2~=1
                newpro(1,out2)=pro(1,out2)-pro(1,out2-1);
            end
        end
        s=size(newpro);
        newpro(1,s(1,2)+1)=1-pro(1,s(1,2));
        countpro=1;
         for cuecount=1:CUEnum
               if countf==CUEBSarrayGroup(i,cuecount)&&countf==1
               powervalue(i,cuecount)=newpro(1,countpro)*P_BS_1;
               countpro=countpro+1;
               end
               if countf==CUEBSarrayGroup(i,cuecount)&&countf~=1
                powervalue(i,cuecount)=newpro(1,countpro)*P_BS_2;
                countpro=countpro+1;
               end
         end
        end
    end
end

end

