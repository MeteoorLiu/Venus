clear all
clc
clear all

%*******for detecting*******% 
load DBLKr;%load the background model
load DBLKg;
load DBLKb;

img_w=256;% soure image width
img_h=256;% soure image height

af=2.5%threshold (C)for Gaussian model
sigema=0.8;%threshold 
poolnum=35;

TestPath='D:\Background Subtraction\LIMUandWF\CameraParameter\trainraw4.2\';
TestFileName = dir('D:\Background Subtraction\LIMUandWF\CameraParameter\trainraw4.2\*.jpg');%load the input frames

CPBMPath='D:\Background Subtraction\LIMUandWF\CameraParameter\trainraw4.2\subpreCS\';
CPBMFileName = dir('D:\Background Subtraction\LIMUandWF\CameraParameter\trainraw4.2\subpreCS\*.bmp');%load the CPB result

STAMPath='D:\Background Subtraction\LIMUandWF\CameraParameter\cascaderaw\';
STAMFileName = dir('D:\Background Subtraction\LIMUandWF\CameraParameter\cascaderaw\*.bmp');%load the STAM results

for t=1:301
     imgt=imread([TestPath,TestFileName(t).name]);
     IItest=imresize(imgt,[img_w img_h]);
     IIr=double(IItest(:,:,1)); % three-channel segmentation
     IIg=double(IItest(:,:,2)); 
     IIb=double(IItest(:,:,3)); 
     
     imgm=imread([CPBMPath,CPBMFileName(t).name]);
     cpbm=imresize(imgm,[img_w img_h]);
   
     imgS=imread([STAMPath,STAMFileName(t).name]);
     JJSTAM=imresize(imgS,[img_w img_h]);
     JJr=double(JJSTAM(:,:,1))*0; % three-channel segmentation
     JJr(find(JJSTAM(:,:,1)>20))=1;% ï¿½ï¿½STAMï¿½Ö¸ï¿½ï¿½ï¿½Í³Ò»Îªï¿½ï¿½ÖµÍ¼
%      JJg=double(JJSTAM(:,:,2))*0; 
%      JJg(find(JJSTAM(:,:,2)>0))=1;
%      JJb=double(JJSTAM(:,:,3))*0; 
%      JJb(find(JJSTAM(:,:,3)>0))=1;
    JJg=JJr;
    JJb=JJr;
  
     
     IIBr=zeros(img_w,img_h);
     IIBrHo=BlockReplacement(DBLKr,IIr,cpbm,JJr,img_w,img_h,af,poolnum);
     IIBr=Getrsigementation(DBLKr,IIr,IIBrHo,JJr,img_w,img_h,sigema,poolnum);
     
     IIBg=zeros(img_w,img_h);
     IIBgHo=BlockReplacement(DBLKg,IIg,cpbm,JJg,img_w,img_h,af,poolnum);
     IIBg=Getrsigementation(DBLKg,IIg,IIBgHo,JJg,img_w,img_h,sigema,poolnum);
     
     IIBb=zeros(img_w,img_h);
     IIBbHo=BlockReplacement(DBLKb,IIb,cpbm,JJb,img_w,img_h,af,poolnum);
     IIBb=Getrsigementation(DBLKb,IIb,IIBbHo,JJb,img_w,img_h,sigema,poolnum);
     IIB=IIBr+IIBg+IIBb;
     
     tempname=strsplit(TestFileName(t).name,'.');
     s=strcat(TestFileName(t).folder,'/HoD+CS/',tempname{1},'.bmp');% save the result
     imwrite(IIB,s);
     fprintf('this is the %d-th frame\n',t);
end


function [IIB]=BlockReplacement(DBLK,II,cpbm,JJSTAM,img_w,img_h,af,poolnum)
     IIB=cpbm;
     for x=1:img_w
         for y=1:img_h
             
%-----------in case of NaB----------            
            if cpbm(x,y)==0 && JJSTAM(x,y)~=0
                 
%---------finding the broken pairs part-------
                count1=0;
                blocknum=0;%added by myself
                steadynum=0;%added by myself
                Totalcc=0;%added by myself,which means the sum of correlation coefficient
          
                for k=1:poolnum % the number of supporting blocks Q in the pool is 30
            
                    if blocknum>=20 %added by myself
                       break
                    end
                    im=x;
                    jm=y;
                    xQ=DBLK(x,y,k,1);%the background model:u
                    yQ=DBLK(x,y,k,2);%the background model:v
                    mQr=DBLK(x,y,k,3);%the background model:b
                    std=DBLK(x,y,k,4);%the background model:ï¿½ï¿½
             
                    if sum(sum(JJSTAM((8*xQ-7):8*xQ,(8*yQ-7):8*yQ)))<7%this is added by myself,and it means the block is background
               
                       blocknum=blocknum+1;%added by myself,to count the number of blocks 
                          if abs(II((8*xQ-7):8*xQ,(8*yQ-7):8*yQ)-II(x,y)-mQr)<=std*af %determine the steady state of pair (p, Q)
                             steadynum=steadynum+1;
                             count1=count1+DBLK(im,jm,k,5);%compute the changing probability R
                          end
                     end
                end
                rbar=count1/steadynum; 
                
%----------detection part----------
                count1=0;
                blocknum=0;%added by myself
                for k=1:poolnum % the number of supporting blocks Q in the pool is 30
            
                    if blocknum>=20 %added by myself
                       break
                    end
                    im=x;
                    jm=y;
                    xQ=DBLK(x,y,k,1);%the background model:u
                    yQ=DBLK(x,y,k,2);%the background model:v
                    mQr=DBLK(x,y,k,3);%the background model:b
                    std=DBLK(x,y,k,4);%the background model:ï¿½ï¿½
             
                    if sum(sum(JJSTAM((8*xQ-7):8*xQ,(8*yQ-7):8*yQ)))<7 && DBLK(im,jm,k,5)<=rbar%it means the block is background or brocken
               
                       blocknum=blocknum+1;%added by myself,to count the number of blocks
                       Totalcc=Totalcc+DBLK(im,jm,k,5);%added by myself 
                       if abs(II((8*xQ-7):8*xQ,(8*yQ-7):8*yQ)-II(x,y)-mQr)>=std*af %determine the unsteady state of pair (p, Q)
                          count1=count1+DBLK(im,jm,k,5);%compute the changing probability R
                       end
                    end
                end
                if blocknum==0
                    IIB(im,jm)=255;
                else
                    if(count1>=Totalcc*0.5)% added by myself,to determine the state of target pixel p, R>R_all*0.5
                     %if(count1>TB(im,jm)*0.5)% determine the state of target pixel p, R>R_all*0.5
                       IIB(im,jm)=255; %foreground  
                    end
                end
            end
    
            
%-----------in case of NaE----------            
            if cpbm(x,y)~=0 && JJSTAM(x,y)==0
                 
%---------finding the broken pairs part-------
                count1=0;
                blocknum=0;%added by myself
                unsteadynum=0;%added by myself
                Totalcc=0;%added by myself,which means the sum of correlation coefficient
          
                for k=1:poolnum % the number of supporting blocks Q in the pool is 30
            
                    if blocknum>=20 %added by myself
                       break
                    end
                    im=x;
                    jm=y;
                    xQ=DBLK(x,y,k,1);%the background model:u
                    yQ=DBLK(x,y,k,2);%the background model:v
                    mQr=DBLK(x,y,k,3);%the background model:b
                    std=DBLK(x,y,k,4);%the background model:ï¿½ï¿½
             
                    if sum(sum(JJSTAM((8*xQ-7):8*xQ,(8*yQ-7):8*yQ)))<7%this is added by myself,and it means the block is background
               
                       blocknum=blocknum+1;%added by myself,to count the number of blocks 
                          if abs(II((8*xQ-7):8*xQ,(8*yQ-7):8*yQ)-II(x,y)-mQr)>=std*af %determine the unsteady state of pair (p, Q)
                             unsteadynum=unsteadynum+1;
                             count1=count1+DBLK(im,jm,k,5);%compute the changing probability R
                          end
                     end
                end
                rbar=count1/unsteadynum; 
                
%----------detection part----------
                count1=0;
                blocknum=0;%added by myself
                for k=1:poolnum % the number of supporting blocks Q in the pool is 30
            
                    if blocknum>=20 %added by myself
                       break
                    end
                    im=x;
                    jm=y;
                    xQ=DBLK(x,y,k,1);%the background model:u
                    yQ=DBLK(x,y,k,2);%the background model:v
                    mQr=DBLK(x,y,k,3);%the background model:b
                    std=DBLK(x,y,k,4);%the background model:ï¿½ï¿½
             
                    if sum(sum(JJSTAM((8*xQ-7):8*xQ,(8*yQ-7):8*yQ)))<7 && DBLK(im,jm,k,5)<=rbar%it means the block is background or brocken
               
                       blocknum=blocknum+1;%added by myself,to count the number of blocks
                       Totalcc=Totalcc+DBLK(im,jm,k,5);%added by myself 
                       if abs(II((8*xQ-7):8*xQ,(8*yQ-7):8*yQ)-II(x,y)-mQr)<=std*af %determine the unsteady state of pair (p, Q)
                          count1=count1+DBLK(im,jm,k,5);%compute the changing probability R
                       end
                    end
                end
                if blocknum==0
                    IIB(im,jm)=255;
                else
                    if(count1<=Totalcc*0.5)% added by myself,to determine the state of target pixel p, R>R_all*0.5
                    %if(count1>TB(im,jm)*0.5)% determine the state of target pixel p, R>R_all*0.5
                       IIB(im,jm)=0; %background  
                    end
                end
            end
         end
     end
end



function [IIB]=Getrsigementation(DBLK,IItest,HoD,JJSTAM,img_w,img_h,sigema,poolnum)
    IIB=HoD;
    for i=1:img_w
        for j=1:img_h
            if HoD(i,j)==0 &&JJSTAM(i,j)~=0
                blocknum=0;
                Totalcc=0;%means the sum of b
                Spq=GetMinFGSim(IItest,HoD,img_w,img_h,i,j);
                
                for k=1:poolnum % the number of supporting blocks Q in the pool is 30
            
                    if blocknum>=20 %added by myself
                       break
                    end
                    x=i;
                    y=j;
                    xQ=DBLK(x,y,k,1);%the background model:u
                    yQ=DBLK(x,y,k,2);%the background model:v
                    mQr=DBLK(x,y,k,3);%the background model:b
                    std=DBLK(x,y,k,4);%the background model:ï¿½ï¿½
             
                    if sum(sum(JJSTAM((8*xQ-7):8*xQ,(8*yQ-7):8*yQ)))<7%this is added by myself,and it means the block is background
                
                       Totalcc=Totalcc+abs(median(median(IItest((8*xQ-7):8*xQ,(8*yQ-7):8*yQ)))-IItest(x,y));%added by myself
               
                       blocknum=blocknum+1;%added by myself,to count the number of blocks
              
                    end
            
                end
                if blocknum~=0
                   Spb=Totalcc/blocknum;
                   if Spq<sigema*Spb
                      IIB(i,j)=255;
                   else
                      IIB(i,j)=0;
                   end
                else
                    IIB(i,j)=JJSTAM(i,j);
                end
            end
        end
    end
  end





function Sq=GetMinFGSim(IItest,HoD,img_w,img_h,m,n) %ÒÔ¾ØÐÎ¿òÊ½À©ÕÅÀ´Ñ°ÕÒÀë£¨m£¬n£©×î½üµÄÊý¸öÇ°¾°ÏñËØ£¬²¢¼ÆËãÏàËÆ¶ÈSq
   
        S=0;
        FGnum=0;
        size=min(min(m,n),min(img_w-m,img_h-n));
        for k=1:size-1
          if FGnum<=20
            for i=m-k:m+k
                if i==m-k||i==m+k  %ËÑË÷¾ØÐÎ¿òµÄÁ½±ß
                   for j=n-k:n+k
                       if HoD(i,j)>0
                           s1=abs(IItest(i,j)-IItest(m,n));
                           S=S+s1;
                           FGnum=FGnum+1;
                       end
                   end
                else %ËÑË÷¾ØÐÎ¿òµÄÁíÁ½±ß
                    if HoD(i,n-k)>0
                        s1=abs(IItest(i,n-k)-IItest(m,n));
                        S=S+s1;
                        FGnum=FGnum+1;
                    end
                    if HoD(i,n+k)>0
                        s1=abs(IItest(i,n+k)-IItest(m,n));
                        S=S+s1;
                        FGnum=FGnum+1;
                    end
                end
            end
          end
        end
        if FGnum~=0
           Sq=S/FGnum;
        else
           Sq=1000000;
        end
end