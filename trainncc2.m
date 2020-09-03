%*****the function to realize traning ******%
function DBLK=trainncc2(DB,poolnum)

[w,h,t]=size(DB);
ws=round(w/8);%set supporting block size, in CPB we set block size as 8x8
hs=round(h/8); 
wo=ones(1,ws)*8;
ho=ones(1,hs)*8;

DBLK=zeros(w,h,poolnum,5,'single');%added by myself
%DBLK=zeros(w,h,refnum,5,'single');%to save the traing results
TB=zeros(w,h,'single');

tt=t;%the number of training frames
DBL=zeros(ws,hs,tt,'single');%to save the divided blocks

%****** divide each training frame into blocks******%
ts=mat2cell(DB,wo,ho,tt);%divide each image of time t into (w/8*h/8) blocks
for x=1:ws
    for y=1:hs
      
        xyz=median(ts{x,y});% median value
        DBL(x,y,:)=median(xyz);
    end
end

%****select the supporting blocks Q for target pixel p*****%
for x=1:w
    fprintf('this is the %d-th row\n',x);
    for y=1:h
        
        substd=std(bsxfun(@minus,DBL,DB(x,y,:)),0,3); %first,comput the minus std
        substd(ceil(x/8),ceil(y/8))=10000;%avoiditself
        
        for k=1:poolnum %added by myself
        %for k=1:refnum 
            [xx,yy]=find(substd==min(substd(:))); %get the bolck Q region which std is small enough 
            DBLK(x,y,k,1)=xx(1);%the background model:u
            DBLK(x,y,k,2)=yy(1);%the background model:v
            qv=DBL(DBLK(x,y,k,1),DBLK(x,y,k,2),:);
            pv=DB(x,y,:);
            DBLK(x,y,k,3)=mean(DBL(DBLK(x,y,k,1),DBLK(x,y,k,2),:)-DB(x,y,:));%the background model:b
            DBLK(x,y,k,4)=std(DBL(DBLK(x,y,k,1),DBLK(x,y,k,2),:)-DB(x,y,:)); %the background model:¦Ò
			
            r=corrcoef(qv,pv);
            DBLK(x,y,k,5)=r(1,2)/2+0.5;%the correlation coefficient r
            substd(xx(1),yy(1))=10000;% avoid repetition
        end
      
            TB(x,y)=sum(DBLK(x,y,:,5));% the sum of correlation coefficient R_all
            substd(xx(1),yy(1))=10000;
    end
end

save TB TB



