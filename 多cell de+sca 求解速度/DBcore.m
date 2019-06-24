function [ D2DarrayGroup,CUEarrayGroup,fitvaluebest,fitvalue,CUEBSarrayGroup,powervalue] = DBcore( BSgain,multigain,D2Dgain,D2DarrayGroup,CUEarrayGroup,P_BS_1,N_0,CUEnum,D2Dnum,channelnum,totalnum,fitvalue,CUEBSarrayGroup,powervalue,P_BS_2,BSnum,BSCUE,genner)
%首先应该随机选择三个个体,并且根据个体情况进行排序，用来完成变异部分的操作
pd_dbm=10;
pd=10^((pd_dbm-30)/10);
%这里用来存储变异个体也就是所说的中间量
changeGroupD=zeros(totalnum,D2Dnum);
changeGroupC=zeros(totalnum,CUEnum);
changeGroupCUEBS=zeros(totalnum,CUEnum);
changepowervalue=zeros(totalnum,CUEnum);
for i=1:totalnum
    array=zeros(1,3);
    for num=1:3
     if num==1
    array(1,num)=randi([1 totalnum],1,1);
     end
    if num==2
        array(1,num)=randi([1 totalnum],1,1);
        while array(1,num)==array(1,num-1)
             array(1,num)=randi([1 totalnum],1,1);
        end
    end
    if num==3
        array(1,num)=randi([1 totalnum],1,1);
         while array(1,num)==array(1,num-1)|| array(1,num)==array(1,num-2)
             array(1,num)=randi([1 totalnum],1,1);
        end
    end
   
    end
    
    %排序
    for j=1:2
        for k=1:3-j
            if fitvalue(array(1,k),1)<fitvalue(array(1,k+1),1)
                temp=array(1,k);
                array(1,k)=array(1,k+1);
                array(1,k+1)=temp;
            end
        end
    end
    %拍好序的array进行Fi的计算
   
%     Fi=0.1+0.8*((fitvalue(array(1,2),1)-fitvalue(array(1,1),1))/(fitvalue(array(1,3),1)-fitvalue(array(1,1),1)));
     Fi=0.1;
    changeGroupD(i,:)=D2DarrayGroup(array(1,1),:)+Fi*(D2DarrayGroup(array(1,2),:)-D2DarrayGroup(array(1,3),:));
    changeGroupC(i,:)=CUEarrayGroup(array(1,1),:)+Fi*(CUEarrayGroup(array(1,2),:)-CUEarrayGroup(array(1,3),:));
    changeGroupCUEBS(i,:)=CUEBSarrayGroup(array(1,1),:)+Fi*(CUEBSarrayGroup(array(1,2),:)-CUEBSarrayGroup(array(1,3),:));
    changepowervalue(i,:)=powervalue(array(1,1),:)+Fi*(powervalue(array(1,2),:)-powervalue(array(1,3),:));
    changeGroupD(i,:)=round(changeGroupD(i,:));
    changeGroupC(i,:)=round(changeGroupC(i,:));
    changeGroupCUEBS(i,:)=round(changeGroupCUEBS(i,:));
    %参数修正将越界参数修复
    for countc=1:CUEnum
         if changeGroupC(i,countc)>channelnum||changeGroupC(i,countc)<1
            changeGroupC(i,countc)=randi([1,channelnum],1,1);
         end
          if isnan(changeGroupC(i,countc))==1
           changeGroupC(i,countc)=randi([1,channelnum],1,1);
          end
      if changeGroupCUEBS(i,countc)>BSnum||changeGroupCUEBS(i,countc)<1
           bsth=randi([1,BSnum],1,1);
        while BSCUE(countc,bsth)==0
            bsth=randi([1,BSnum],1,1);
        end
        changeGroupCUEBS(i,countc)=bsth;
      end
      if isnan(changeGroupCUEBS(i,countc))==1
           bsth=randi([1,BSnum],1,1);
        while BSCUE(countc,bsth)==0
            bsth=randi([1,BSnum],1,1);
        end
        changeGroupCUEBS(i,countc)=bsth;
      end
      if changepowervalue(i,countc)<0||isnan(changepowervalue(i,countc))
          changepowervalue(i,countc)=P_BS_1*rand(1,1)*0.0001;
      end
%       if  isnan(changepowervalue(i,countc))
%           ac=powervalue(array(1,1),:);
%           bc=Fi*(powervalue(array(1,2),:)-powervalue(array(1,3),:));
%           disp(ac);
%           disp(bc);
%       end
    end
    for count=1:D2Dnum  
       if changeGroupD(i,count)>channelnum||changeGroupD(i,count)<1
           changeGroupD(i,count)=randi([1,channelnum],1,1);
       end
       if isnan(changeGroupD(i,count))==1
           changeGroupD(i,count)=randi([1,channelnum],1,1);
       end
    end
end
%交叉部分先进行交叉概率的计算,首先算出平均，最大，以及最小
% ftotal=0;
% fmax=0;
% fmin=10000000;
% for out=1:totalnum
%     ftotal=fitvalue(out,1)+ftotal;
%     if fitvalue(out,1)>fmax
%         fmax=fitvalue(out,1);
%     end
%     if fitvalue(out,1)<fmin
%         fmin=fitvalue(out,1);
%     end
% end
% faver=ftotal/totalnum;
% %存储交叉的概率cr
crarray=zeros(totalnum,1);
% for out=1:totalnum
%     if fitvalue(out,1)>faver
%        crarray(out,1)=0.1+0.5*((fitvalue(out,1)-fmin)/(fmax-fmin));
%     else
%         crarray(out,1)=0.1;
%     end
% end
crarray(:,1)=0.4;
%依据概率进行交叉
newD2Darray=zeros(totalnum,D2Dnum);
newCUEarray=zeros(totalnum,CUEnum);
newCUEBSarray=zeros(totalnum,CUEnum);
newpowervalue=zeros(totalnum,CUEnum);
for out=1:totalnum
    for inc=1:CUEnum
         probis=rand(1,1);
        if probis<crarray(out,1)
            newCUEarray(out,inc)=changeGroupC(out,inc);
            newCUEBSarray(out,inc)=changeGroupCUEBS(out,inc);
            newpowervalue(out,inc)=changepowervalue(out,inc);
        else
            newCUEarray(out,inc)=CUEarrayGroup(out,inc);
             newCUEBSarray(out,inc)=CUEBSarrayGroup(out,inc);
             newpowervalue(out,inc)=powervalue(out,inc);
        end
    end
    for in=1:D2Dnum
        probi=rand(1,1);
        if probi<crarray(out,1)
            newD2Darray(out,in)=changeGroupD(out,in);
        else
            newD2Darray(out,in)=D2DarrayGroup(out,in);
        end
    end
end
%形成新的匹配方式之后要进行对比到底哪个该留下来
%tempfitvalue=zeros(totalnum,1);
tempfitvalue=fit( BSgain,multigain,D2Dgain,newD2Darray,newCUEarray,P_BS_1,N_0,CUEnum,D2Dnum,channelnum,totalnum,newCUEBSarray ,newpowervalue,P_BS_2,BSnum);
%  if genner>0
% for cc=1:totalnum
%    if tempfitvalue(cc,1)<0
%          poweri=powerfix(newpowervalue,BSgain,D2Dgain,newD2Darray,cc,N_0,pd,CUEnum,D2Dnum,newCUEBSarray,newCUEarray,multigain,P_BS_2,BSnum,totalnum,channelnum);
%          newpowervalue(cc,:)=poweri;
% %          opresult =fun(newpowervalue,BSgain,D2Dgain,newD2Darray,cc,N_0,pd,CUEnum,D2Dnum,newCUEBSarray,newCUEarray,multigain,P_BS_2,BSnum);
% %         tempfitvalue(cc,1)=opresult;
%     end
% end
% tempfitvalue=fit( BSgain,multigain,D2Dgain,newD2Darray,newCUEarray,P_BS_1,N_0,CUEnum,D2Dnum,channelnum,totalnum,newCUEBSarray ,newpowervalue,P_BS_2,BSnum);
%  end
for out=1:totalnum
    if tempfitvalue(out)>fitvalue(out)&&tempfitvalue(out)>0
        D2DarrayGroup(out,:)=newD2Darray(out,:);
        CUEarrayGroup(out,:)=newCUEarray(out,:);
        CUEBSarrayGroup(out,:) =newCUEBSarray(out,:);
        powervalue(out,:)=newpowervalue(out,:);
        fitvalue(out)=tempfitvalue(out);
    end
     if tempfitvalue(out)<fitvalue(out)&&tempfitvalue(out)<0&&fitvalue(out)<0;
         D2DarrayGroup(out,:)=newD2Darray(out,:);
        CUEarrayGroup(out,:)=newCUEarray(out,:);
        CUEBSarrayGroup(out,:) =newCUEBSarray(out,:);
        powervalue(out,:)=newpowervalue(out,:);
        fitvalue(out)=tempfitvalue(out);
     end
end 
fitvaluebest=maxvalue(fitvalue);
end

