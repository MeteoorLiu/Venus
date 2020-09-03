%*****the function to realize detecting ******%
function IIB=subncc1(IIb,II,DBLK,af,BTh)
%load TB;%load R_all

IIB=im2bw(II)*0;
[w,h]=size(II);
ws=round(w/8);%set supporting block size, in CPB we set block size as 8x8
hs=round(h/8);
wo=ones(1,ws)*8;
ho=ones(1,hs)*8;
Block=8*8;% block size

DBS=zeros(ws,hs,'single');%to save the divided blocks

%****** divide each training frame into blocks******%
IIS=mat2cell(II,wo,ho);
for x=1:ws
    for y=1:hs
       DBS(x,y)=mean(mean(IIS{x,y}));
    end
end

%****detect the object*****%
for x=1:w
    for y=1:h
          count1=0;
          blocknum=0;%added by myself
          Totalcc=0;%added by myself,which means the sum of correlation coefficient
          
      for k=1:35 % the number of supporting blocks Q in the pool is 30
            
             if blocknum>=20 %added by myself
                 break
             end
             im=x;
             jm=y;
             xQ=DBLK(x,y,k,1);%the background model:u
             yQ=DBLK(x,y,k,2);%the background model:v
             mQr=DBLK(x,y,k,3);%the background model:b
             std=DBLK(x,y,k,4);%the background model:��
             
            if sum(sum(IIb((8*xQ-7):8*xQ,(8*yQ-7):8*yQ)))<BTh%this is added by myself,and it means the block is background
                
                Totalcc=Totalcc+DBLK(im,jm,k,5);%added by myself
                if abs(II((8*xQ-7):8*xQ,(8*yQ-7):8*yQ)-II(x,y)-mQr)>=std*af%determine the state of pair (p, Q)
                   count1=count1+DBLK(im,jm,k,5);%compute the changing probability R
                end
            
                blocknum=blocknum+1;%added by myself,to count the number of blocks
              
            end
            
      end
	  
      if blocknum==0
          IIB(im,jm)=IIb(im,jm);
      else
          if(count1>=Totalcc*0.5)% added by myself,to determine the state of target pixel p, R>R_all*0.5
          %if(count1>TB(im,jm)*0.5)% determine the state of target pixel p, R>R_all*0.5
               IIB(im,jm)=255; %foreground              
          end   
      end
	 
   end
end
%������Ϊ�˿��ӻ����? 
%{
    imshow(IIB);
    hold on;
    rectangle('Position',[79,154,3,3],'Edgecolor','r','LineWidth',1);
    blocknum=0;
    for k=1:30
        if blocknum>=20
            break
        end
        xQ=DBLK(155,80,k,1);
        yQ=DBLK(155,80,k,2);
        if sum(sum(IIb((8*xQ-7):8*xQ,(8*yQ-7):8*yQ)))<7
             rectangle('Position',[8*yQ-7,8*xQ-7,8,8],'Edgecolor','g','LineWidth',1);
             blocknum=blocknum+1;
        end
    end  
    1+1;
%}
    





