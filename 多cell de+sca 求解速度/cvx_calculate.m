function [newvalues,newpc] = cvx_calculate(BSgain,multigain,D2Dgain,CUEBSarrayGroup,CUEarrayGroup,D2DarrayGroup,BSnum,N_0,CUEnum,D2Dnum,channelnum,vpm,vdm,vtm,vbm,ub,vb,P_BS_1,P_BS_2,t,fpc,pd)
%CVX_CALCULATE 此处显示有关此函数的摘要
%   此处显示详细说明


 
     cvx_begin 
     
  
        variable pc(1,10)

         values=0;
         cuenoise=0;
         d2dnoise=0;
%从这开始是求适应度函数值的公式
        expression cuenoise
        expression d2dnoise
 
       for tw=1:D2Dnum
           for bs=1:BSnum
               for jj=1:CUEnum
                   m=D2DarrayGroup(1,tw);%表明是哪个信道
                   if vbm(bs,jj)==1&&vpm(m,jj)==1
                       cuenoise=2^pc(1,jj)*(BSgain(bs*2,tw)^2)+cuenoise;
                   end
               end
           end
           for z1=1:D2Dnum
               if z1~=tw
                   m=D2DarrayGroup(1,tw);%表明是哪个信道
                   if vdm(m,z1)==1
                       d2dnoise=pd(1,z1)*(D2Dgain(tw,z1)^2)+d2dnoise;
                   end
               end
           end 
          
           sin=(D2Dgain(tw,tw)^2*pd(1,tw))/(cuenoise+d2dnoise+N_0^2);
    
           value=(ub(1,tw)*log(sin)+vb(1,tw))/log(2);
%            value=log(1+sin);
           values=values+value;
           cuenoise=0;
           d2dnoise=0;
      end
        
        vc=zeros(1,CUEnum);
              vd=zeros(1,D2Dnum);
            for s1=1:channelnum
                        for l1=1:CUEnum
                            if vpm(s1,l1)~=0
                                vc(1,l1)=vc(1,l1)+1;
                            end
                        end
                        for l2=1:D2Dnum
                            if vdm(s1,l2)~=0
                                vd(1,l2)=vd(1,l2)+1;
                            end
                        end
            end
%                         
                         sinr=zeros(1,10);
                         expression sinr(1,10)
                        for cuecount=1:CUEnum
                            cuenoise1=0;
                            cuenoisein=0;
                            d2dnoise1=0;
                            expression cuenoise1
                            expression cuenoisein
                            expression d2dnoise1
                            for cuen=1:CUEnum
                                if cuen~=cuecount&&CUEarrayGroup(1,cuen)==CUEarrayGroup(1,cuecount)
                                  %这一步指出了与对比的CUE是否占用同一个信道
                                  %其次进行进一步的划分选择，就是此用户是否属于同一基站，属于同一基站的算一种情况，否则算另一种
                                  if CUEBSarrayGroup(1,cuecount)==CUEBSarrayGroup(1,cuen)
                                      %如果是同一基站同一信道的情况下要进行干扰判断
                                     if vtm(1,cuecount)>vtm(1,cuen)
                                         cuenoisein=cuenoisein+2^pc(1,cuen)*(BSgain(CUEBSarrayGroup(1,cuen)*2-1,cuecount)^2);
                                     end

                                  else
                                      %这里是不同基站同信道之间的CUE用户之间的干扰
                                      cuenoise1=2^pc(1,cuen)*(BSgain(CUEBSarrayGroup(1,cuen)*2-1,cuecount)^2)+cuenoise1;
                                  end
                                end
                            end
                            for d2dn=1:D2Dnum
                                if D2DarrayGroup(1,d2dn)==CUEarrayGroup(1,cuecount)
                                    d2dnoise1=pd(1,d2dn)*(multigain(cuecount,d2dn)^2)+d2dnoise1;
                                end
                            end
                            sinr1=(2^pc(1,cuecount)*BSgain(CUEBSarrayGroup(1,cuecount)*2-1,cuecount)^2);
                            sinr2=(cuenoise1+d2dnoise1+cuenoisein+(N_0^2));
%                             sinr(1,cuecount)=ud(1,cuecount)*log(sinr1/sinr2)+vdd(1,cuecount);
                             sinr(1,cuecount)=sinr1/sinr2;
                        end
                          whole=zeros(BSnum,1);
                         expression whole(BSnum,1)
                      for bss=1:BSnum%每个基站上用户的功率和小于基站总功率
                       
                         for cou=1:CUEnum
                             if vbm(bss,cou)==1
                                 whole(bss,1)=whole(bss,1)+2^pc(1,cou);
                             end
                         end
                      end

        maximize (values)


        subject to 
%                    
                  
                     for bbs=1:BSnum
                         if bbs==1
                              whole(bbs,1)<=P_BS_1;
                         else
                              whole(bbs,1)<=P_BS_2;
                         end
                     end
                      
%                       速率的限制
                   
                             sinr>=1;
                       
                              
                     for l1=1:CUEnum
                             vc(1,l1)>=0&&vc(1,l1)<=1;
                     end
                     for l2=1:D2Dnum
                              vd(1,l2)>=0&&vd(1,l2)<=1;
                     end
% %                       
                        for i1=1:BSnum
                            for j1=1:channelnum
                                if t(i1,j1)~=0&&t(i1,j1)~=1
                                    count=t(i1,j1);
                                    for k=1:count
                                            for j=k+1:count
                                                hk=0;
                                                hj=0;
                                                for m=1:CUEnum
                                                    if vpm(j1,m)==1&&vtm(1,m)==k&&vbm(i1,m)==1
                                                        hk=m;
                                                    end
                                                    if vpm(j1,m)==1&&vtm(1,m)==j&&vbm(i1,m)==1
                                                        hj=m;
                                                    end
                                                end
  
                                                   d2dk=0;
                                               
                                                
                                                   expression d2dk;
                                                  
                                                for one=1:D2Dnum%这里求同一信道上面的D2d干扰
                                                    if vdm(j1,one)==1
                                                        d2dk=d2dk+(BSgain(i1*2-1,hj)^2*multigain(hk,one)^2-BSgain(i1*2-1,hk)^2*multigain(hj,one)^2)*pd(1,one);
                                                        
                                                    end
                                                end
                                                scuek=0;
                                                pm=0;
                                                expression scuek;
                                                expression pm;
                                               for bbs=1:BSnum%不同基站同一信道的干扰
                                                   if bbs~=i1
                                                        for s=1:CUEnum%k的增益
                                                            if vbm(bbs,s)==1&&vpm(j1,s)==1
                                                                pm=pm+2^pc(1,s);
                                                            end
                                                        end
                                                         scuek=scuek+BSgain(i1*2-1,hk)^2*BSgain(bbs*2-1,hj)^2*pm;
                                                   end
                                               end
                                               bcuej=0;
                                               pmc=0;
                                               pmb=0;
                                               expression bcuej;
                                               expression pmc;
                                               for bbc=1:BSnum%不同基站同一信道的干扰
                                                   if bbc~=i1
                                                        for s1=1:CUEnum%k的增益
                                                            if vbm(bbc,s1)==1&&vpm(j1,s1)==1
                                                                pmc=pmc+(log(2^pc(1,s1))-log(fpc(1,s1)));
                                                                 pmb=pmb+fpc(1,s1);
%                                                                  pmb=pmb+2^pc(1,s1);
                                                            end
                                                        end
                                                         bcuej=bcuej+(BSgain(i1*2-1,hj)^2*BSgain(bbc*2-1,hk)^2)*(pmc+pmb);
                                                   end
                                               end
                                               scuek-(BSgain(i1*2-1,hk)^2-BSgain(i1*2-1,hj)^2)*N_0^2+d2dk<=bcuej;
                                            end
                                    end
                                end
                            end
                        end
   
                            
                       
  
    cvx_end
    newvalues=values;
%     newpd=2.^pd;
    newpc=2.^pc;
end

