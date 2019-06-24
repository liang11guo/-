%首先我们先对初始群体进行初始化，初始化首先最主要的就是形成个体编码参数设置，D2D的数量为15个，CUE的数量为15个，信道数量10个，关于信道增益部分交给一个程序去生成。
%1,信道增益只考虑瑞利衰弱，所以只需要模拟一组距离，然后同过各个基站距离的负4次幂来进行确定信道的增益情况即可
%首先先生成初始的环境,初始的群体基数是50.
%这里基站组数修改成了三个基站，所以基站的使用方面要增加
clc;
load CoordinatesOfCUE.txt;
load CoordinatesOfD2DD.txt;
load CoordinatesOfD2DR.txt;
load CoordinatesOfBS.txt;
BSnum=4;%基站数目为四个效果明显
CUEnum=10;%cue用户数量为10
D2Dnum=15;%d2d用户对数量为15
channelnum=17;%信道数量为10
totalnum=50;%群体的数量为50
gen=10000;%迭代10000代；
pd_dbm=10;
pd=10^((pd_dbm-30)/10);
 P_BS_1_dbm=43;
 P_BS_2_dbm=30;
 P_BS_1=10^((P_BS_1_dbm-30)/10);%这里计算了总功率
 P_BS_2=10^((P_BS_2_dbm-30)/10);
 BW = 1e7;
 N_0_dbm = -174 + 10*log10(BW);
 N_0 = 10^((N_0_dbm-30)/10);%这里是白噪声
 BSgain=zeros(BSnum*2,D2Dnum);%基站针对cue和d2d的增益，由于是三个基站，所以矩阵规模扩大
 D2DarrayGroup=zeros(totalnum,D2Dnum);%d2d占用信道情况
 CUEarrayGroup=zeros(totalnum,CUEnum);%cue占用信道的情况
 CUEBSarrayGroup=zeros(totalnum,CUEnum);%cue选取得基站具体情况
 multigain=zeros(CUEnum,D2Dnum);%cue与d2d之间的增益的情况
 D2Dgain=zeros(D2Dnum,D2Dnum);%d2d对之间的增益情况
 xbel=[];
ybel=[];
 %首先计算BS到各个d2d和cue之间的增益的情况
 for i=1:BSnum*2
     if mod(i,2)==1
         for j1=1:CUEnum
           BSgain(i,j1)=gain(CoordinatesOfBS(round(i/2),:),CoordinatesOfCUE(j1,:));  
         end    
     end
     if mod(i,2)==0
     for j=1:D2Dnum
       BSgain(i,j)=gain(CoordinatesOfBS(round(i/2),:),CoordinatesOfD2DR(j,:));
     end
     end
 end
 %BSgain计算完成后记录下，第一行是cue的,第二行是d2d的
for i=1 :CUEnum
    for j=1:D2Dnum
        value=gain(CoordinatesOfD2DD(j,:),CoordinatesOfCUE(i,:));
         multigain(i,j)=value;
    end
end
for di=1:D2Dnum
    for dj=1:D2Dnum
         D2Dgain(di,dj)=gain(CoordinatesOfD2DD(di,:),CoordinatesOfD2DR(dj,:));
    end
end 
%以上完成D2Dgain与multigain
%上式形成了一个初始的增益矩阵的情况，接着我们来初始化一下种群中Cue和D2D的情况
%初始化CUE中BS基站选择得情况
%首先群体基数我设定为50个
%随机分配了CUE与D2D的信道分配,但是有关CUE的分配情况需要考虑作用距离即如果距离太远的将不能进行分配；
%所以这里要建立一个矩阵用来记录每个CUE可以选择的基站的情况
BSCUE=zeros(CUEnum,BSnum);
for CUEcount=1:CUEnum
    for BScount=1:BSnum
        if BScount==1
            BSCUE(CUEcount,BScount)=1;
            continue;
        end
         distance=distvalue(CoordinatesOfCUE(CUEcount,:),CoordinatesOfBS(BScount,:));
        if BScount~=1&&distance<=300
            BSCUE(CUEcount,BScount)=1;
        end
    end
end
for i=1:totalnum
    for j=1:CUEnum
        CUEarrayGroup(i,j)=randi([1 channelnum],1,1);
        bsth=randi([1,BSnum],1,1);
        while BSCUE(j,bsth)==0
            bsth=randi([1,BSnum],1,1);
        end
        CUEBSarrayGroup(i,j)=bsth;
    end
    for j1=1:D2Dnum
        D2DarrayGroup(i,j1)=randi([1 channelnum],1,1);
    end
end
%这里CUE功率是直接进行分配处理的
powervalue=zeros(totalnum,CUEnum);
powervalue=powergenerate(CUEBSarrayGroup,P_BS_1,CUEnum,totalnum,powervalue,P_BS_2,BSnum);
fitvalue=fit(BSgain,multigain,D2Dgain,D2DarrayGroup,CUEarrayGroup,P_BS_1,N_0,CUEnum,D2Dnum,channelnum,totalnum,CUEBSarrayGroup,powervalue,P_BS_2,BSnum);
for cc=1:totalnum
   if fitvalue(cc,1)<0
         poweri=powerfix(powervalue,BSgain,D2Dgain,D2DarrayGroup,cc,N_0,pd,CUEnum,D2Dnum,CUEBSarrayGroup,CUEarrayGroup,multigain,P_BS_2,BSnum,totalnum,channelnum);
         powervalue(cc,:)=poweri;
%          opresult =fun(newpowervalue,BSgain,D2Dgain,newD2Darray,cc,N_0,pd,CUEnum,D2Dnum,newCUEBSarray,newCUEarray,multigain,P_BS_2,BSnum);
%         tempfitvalue(cc,1)=opresult;
    end
end
tempfitvalue=fit( BSgain,multigain,D2Dgain,D2DarrayGroup,CUEarrayGroup,P_BS_1,N_0,CUEnum,D2Dnum,channelnum,totalnum,CUEBSarrayGroup ,powervalue,P_BS_2,BSnum);
%形成初始环境之后要计算各个个体的适应函数,把初始状态下的各个参数放入
fbest=0;
genner=0;
whichone=0;
while genner<20000
[ newD2DarrayGroup,newCUEarrayGroup,fitvaluebest,newfitvalue,newCUEBSarrayGroup,newpowervalue] = DBcore( BSgain,multigain,D2Dgain,D2DarrayGroup,CUEarrayGroup,P_BS_1,N_0,CUEnum,D2Dnum,channelnum,totalnum,fitvalue,CUEBSarrayGroup,powervalue,P_BS_2,BSnum,BSCUE,genner);
D2DarrayGroup=newD2DarrayGroup;
CUEarrayGroup=newCUEarrayGroup;
fitvalue=newfitvalue;
 CUEBSarrayGroup = newCUEBSarrayGroup;
 powervalue=newpowervalue;
  %寻找当前最优
  whichone=0;
for which=1:totalnum
    if fitvalue(which,1)==fitvaluebest
        whichone=which;
        break;
    end
end
 fbest=fitvalue(whichone,1);
 fCUEarrayGroup(1,:)=CUEarrayGroup(whichone,:);
 fD2DarrayGroup(1,:)=D2DarrayGroup(whichone,:);
  fCUEBSarrayGroup(1,:)=CUEBSarrayGroup(whichone,:);
  fpc=powervalue(whichone,:);
 genner=genner+1;
 
 disp([fbest,genner]);
end
%上面的针对初试情况进行一次求解，这里将将初始情况下的信道拿出来，进行下面的功率求解
%首先拿出最优质的D2D，CUE，基站分配，以及目前的最大适应度。
disp(fbest);
pd=0.01*ones(1,15);
vtm=zeros(1,CUEnum);

for channeloutside=1:channelnum
       for BS=1:BSnum
           y=[];
           mark=0;
          for cueoutside=1:CUEnum
              if fCUEBSarrayGroup(1,cueoutside)==BS&&fCUEarrayGroup(1,cueoutside)==channeloutside
                  y(mark+1)=cueoutside;
                  mark=mark+1;
              end
          end
          %CUE用户加入后进行排序
          if mark~=0&&mark~=1
              for w=1:mark
                  for in=1:mark-w
                      if judgein(1,y(in),y(in+1),BSgain,multigain,D2Dgain,fD2DarrayGroup,fCUEarrayGroup,fpc,fCUEBSarrayGroup,CUEnum,D2Dnum,N_0,pd)==0
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
              vtm(1,y(p))=p;
          end
          end
       end
end
%下面开始是sca部分
vbm=zeros(BSnum,CUEnum);
vdm=zeros(channelnum,D2Dnum);
vpm=zeros(channelnum,CUEnum);
for j1=1:D2Dnum                 %d2d用户占用的信道置1
        g=fD2DarrayGroup(1,j1);
         vdm(g,j1)=1;

end
for j=1:CUEnum                 %cue用户占用的信道置1
        f=fCUEarrayGroup(1,j);
        vpm(f,j)=1;
end
for j2=1:CUEnum
    h=fCUEBSarrayGroup(1,j2);
    vbm(h,j2)=1;
end

t=zeros(BSnum,channelnum);%用于记录同信道同基站用户个数
for i=1:BSnum
    for j=1:channelnum
        for c=1:CUEnum
            if vpm(j,c)==1&&vbm(i,c)==1    
                t(i,j)=t(i,j)+1;
            end
        end
    end
end

[firstvalue]=fitin(BSgain,multigain,D2Dgain,fD2DarrayGroup,fpc,fCUEarrayGroup,fCUEBSarrayGroup,P_BS_1,P_BS_2,N_0,CUEnum,D2Dnum,BSnum,vpm,vdm,vbm,vtm,pd);
  disp(firstvalue);
  [firstvalues,u,v,ud,vdd]=orimainc(vtm,BSgain,D2Dgain,multigain,fD2DarrayGroup,fCUEarrayGroup,fCUEBSarrayGroup,fpc,N_0,CUEnum,D2Dnum,BSnum,pd,vpm,vdm,vbm);

y=zeros(100000,1);
z=zeros(100000,1);
x=zeros(10000,CUEnum);
% xbel=[];
% ybel=[];
y(1,1)=firstvalue;
z(1,1)=firstvalues; %y(1,1)

x(1,:)=fpc(1,:);
s=2;
m=1;
while (z(s-1,1)-z(m,1))/z(m,1)<=0.05
    s=s+1;
    m=s-2;
    
    [newvalue,bestpc]=cvx_calculate(BSgain,multigain,D2Dgain,fCUEBSarrayGroup,fCUEarrayGroup,fD2DarrayGroup,BSnum,N_0,CUEnum,D2Dnum,channelnum,vpm,vdm,vtm,vbm,u,v,P_BS_1,P_BS_2,t,fpc,pd);
    ff=funin(BSgain,D2Dgain,fD2DarrayGroup,N_0,CUEnum,D2Dnum,pd,vpm,vdm,bestpc,vbm,BSnum);
%     ftest=testfun(multigain,BSgain,D2Dgain,D2DarrayGroup,N_0,CUEnum,D2Dnum,pd,vpm,vdm,bestpc,vbm,BSnum,fvtm,CUEarrayGroup,CUEBSarrayGroup);
    [newvalues]=fitin(BSgain,multigain,D2Dgain,fD2DarrayGroup,bestpc,fCUEarrayGroup,fCUEBSarrayGroup,P_BS_1,P_BS_2,N_0,CUEnum,D2Dnum,BSnum,vpm,vdm,vbm,vtm,pd);
%    
%     
%     
%     
    z(s-1,1)=newvalue;
%     x(s-1,:)=bestpd;
    y(s-1,1)=newvalues;
    x(s-1,:)=bestpc;
     [fvalues,u,v]=mainc(BSgain,D2Dgain,fD2DarrayGroup,bestpc,N_0,CUEnum,D2Dnum,BSnum,pd,vpm,vdm,vbm,u,v);
     
%      
%        [dvalue,bestpd]=cvx_calculate1(BSgain,multigain,D2Dgain,fCUEBSarrayGroup,fCUEarrayGroup,fD2DarrayGroup,BSnum,N_0,CUEnum,D2Dnum,channelnum,vpm,vdm,vtm,vbm,u,v,P_BS_1,P_BS_2,t,bestpc,ud,vdd,pd);
%             df=funout(BSgain,D2Dgain,fD2DarrayGroup,N_0,CUEnum,D2Dnum,bestpd,vpm,vdm,bestpc,vbm,BSnum);
%              [dnewvalues]=fitin(BSgain,multigain,D2Dgain,fD2DarrayGroup,bestpc,fCUEarrayGroup,fCUEBSarrayGroup,P_BS_1,P_BS_2,N_0,CUEnum,D2Dnum,BSnum,vpm,vdm,vbm,vtm,bestpd);
%        [dvalues,u,v]=mainc(BSgain,D2Dgain,fD2DarrayGroup,bestpc,N_0,CUEnum,D2Dnum,BSnum,pd,vpm,vdm,vbm,u,v);
%        if dvalue>=newvalue&&df>=ff
%                       z(s-1,1)=dvalues;
%                     x(s-1,:)=bestpd;
%                     y(s-1,1)=dvalue;
%                      pd=bestpd;
%                      ju=1;
%        end
       if newvalue-z(s-2,1)<=0.01
           break;
       end
   
     fpc=bestpc;
     disp(ff);

     
end
bestpcpower=zeros(1,10);
best=maxvalue(y);
for i=1:s
    if y(i,1)==best
        bestpcpower(1,:)=x(i,:);
    end
end

     disp(best);
disp(bestpcpower);

[twicevalue]=fitin(BSgain,multigain,D2Dgain,fD2DarrayGroup,bestpcpower,fCUEarrayGroup,fCUEBSarrayGroup,P_BS_1,P_BS_2,N_0,CUEnum,D2Dnum,BSnum,vpm,vdm,vbm,vtm,pd);
  disp(twicevalue);
  [secvalues,u,v,ud,vdd]=orimainc(vtm,BSgain,D2Dgain,multigain,fD2DarrayGroup,fCUEarrayGroup,fCUEBSarrayGroup,bestpcpower,N_0,CUEnum,D2Dnum,BSnum,pd,vpm,vdm,vbm);

y1=zeros(100000,1);
z1=zeros(100000,1);
x1=zeros(10000,D2Dnum);

y1(1,1)=twicevalue;
z1(1,1)=secvalues; %y(1,1)

x1(1,:)=pd(1,:);
s1=2;
m1=1;
while (z1(s1-1,1)-z1(m1,1))/z1(m1,1)<=0.05
    s1=s1+1;
    m1=s1-2;

       [dvalue,bestpd]=cvx_calculate1(BSgain,multigain,D2Dgain,fCUEBSarrayGroup,fCUEarrayGroup,fD2DarrayGroup,BSnum,N_0,CUEnum,D2Dnum,channelnum,vpm,vdm,vtm,vbm,u,v,P_BS_1,P_BS_2,t,bestpcpower,ud,vdd,pd);
       df=funout(BSgain,D2Dgain,fD2DarrayGroup,N_0,CUEnum,D2Dnum,bestpd,vpm,vdm,bestpcpower,vbm,BSnum);
       [dnewvalues]=fitin(BSgain,multigain,D2Dgain,fD2DarrayGroup,bestpcpower,fCUEarrayGroup,fCUEBSarrayGroup,P_BS_1,P_BS_2,N_0,CUEnum,D2Dnum,BSnum,vpm,vdm,vbm,vtm,bestpd);
      
        z1(s1-1,1)=dvalue;
    %     x(s-1,:)=bestpd;
        y1(s1-1,1)=dnewvalues;
        x1(s1-1,:)=bestpd;
         [dvalues,u,v]=mainc(BSgain,D2Dgain,fD2DarrayGroup,bestpcpower,N_0,CUEnum,D2Dnum,BSnum,bestpd,vpm,vdm,vbm,u,v);
       if dvalue-z1(s1-2,1)<=0.01
           break;
       end
   
     pd=bestpd;
     disp(df);

    
end
bestpdpower=zeros(1,D2Dnum);
dbest=maxvalue(y1);
 for i=1:s1
    if y1(i,1)==dbest
        bestpdpower(1,:)=x1(i,:);
    end
 end
     disp(dbest);
disp(bestpdpower);

