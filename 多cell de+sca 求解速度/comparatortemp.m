function [ newvtm ] = comparatortemp(channelnum,D2Dnum,cuenum,pc,BSnum,vbm,t,vdm,vpm,multigain,BSgain,pdpower,N_0)
%������һ��ͨ�õ�SIC����ıȽϺ������ú�����ԭ����vpmת�����µĴ���SIC����˳���vpm
vtm=ones(1,cuenum);
for i1=1:BSnum
    for j1=1:channelnum
        if t(i1,j1)~=0&&t(i1,j1)~=1
            count=0;
            temp=zeros(1,t(i1,j1));
            for m=1:cuenum
                if vbm(i1,m)==1&&vpm(j1,m)==1
                    count=count+1;
                    temp(1,count)=m;%temp�����Ķ�Ӧ�ŵ����

                end
            end



            for out=1:count-1
                for in=out+1:count

                           d2dk=0;
                           d2dj=0;
                        for one=1:D2Dnum%������ͬһ�ŵ������D2d����
                            if vdm(j1,one)==1
                                d2dk=d2dk+multigain(temp(1,out),one)^2*pdpower(1,one);
                                d2dj=d2dj+multigain(temp(1,in),one)^2*pdpower(1,one);
                            end
                        end
                        scuek=0;
                        scuej=0;
                        for s=1:cuenum%ͬһ��վͬһ�ŵ��ĸ���
                                if vbm(i1,s)==1&&vpm(j1,s)==1&&s~=temp(1,out)
                                    scuek=scuek+BSgain(i1*2-1,temp(1,out))*pc(1,s);
                                end
                                 if vbm(i1,s)==1&&vpm(j1,s)==1&&s~=temp(1,in)
                                    scuej=scuej+BSgain(i1*2-1,temp(1,in))*pc(1,s);
                                 end
                        end
                        dcuek=0;
                        dcuej=0;
                        for d=1:cuenum
                              if vpm(j1,d)~=0
                                   %ͬһ�ŵ���ͬ��վ�ĸ���
                                        if vbm(i1,d)==0
                                            dcuek=dcuek+BSgain(i1*2-1,temp(1,out))^2*pc(1,d);
                                             dcuej=dcuej+BSgain(i1*2-1,temp(1,in))^2*pc(1,d);
                                        end
                                 
                              end
                        end
                          re1=pc(1,temp(1,in))*BSgain(i1*2-1,temp(1,out))^2/(d2dk+scuek+dcuek+N_0^2);
                         re2=pc(1,temp(1,in))*BSgain(i1*2-1,temp(1,in))^2/(scuej+d2dj+dcuej+N_0^2);
                         if re2>=re1


%                         if BSgain(i1*2-1,temp(1,out))^2*(scuej+d2dj+dcuej+N_0^2)>=BSgain(i1*2-1,temp(1,in))^2*(d2dk+scuek+dcuek+N_0^2)
                            tempvalue=temp(1,in);
                            temp(1,in)=temp(1,out);
                            temp(1,out)=tempvalue;
                        end

                end
            end
        for z=1:count
            vtm(1,temp(1,z))=z;
        end
        end
    end
end
newvtm=vtm;
end