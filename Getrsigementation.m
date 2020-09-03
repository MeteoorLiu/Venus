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
                    std=DBLK(x,y,k,4);%the background model:锟斤拷
             
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
  
function Sq=GetMinFGSim(IItest,HoD,img_w,img_h,m,n) %以矩形框式扩张来寻找离（m，n）最近的数个前景像素，并计算相似度Sq
   
        S=0;
        FGnum=0;
        size=min(min(m,n),min(img_w-m,img_h-n));
        for k=1:size-1
          if FGnum<=20
            for i=m-k:m+k
                if i==m-k||i==m+k  %搜索矩形框的两边
                   for j=n-k:n+k
                       if HoD(i,j)>0
                           s1=abs(IItest(i,j)-IItest(m,n));
                           S=S+s1;
                           FGnum=FGnum+1;
                       end
                   end
                else %搜索矩形框的另两边
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