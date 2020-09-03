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
                    std=DBLK(x,y,k,4);%the background model:��
             
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
                    std=DBLK(x,y,k,4);%the background model:��
             
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
                    std=DBLK(x,y,k,4);%the background model:��
             
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
                    std=DBLK(x,y,k,4);%the background model:��
             
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