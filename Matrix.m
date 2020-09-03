clear all
clc
close all
%*******for training*******% 
trainPath ='D:\Background Subtraction\PETS2001\Intersection\trainraw4.1\';
filename = dir('D:\Background Subtraction\PETS2001\Intersection\trainraw4.1\*.jpg'); % load the training frames

baseTrainNum=400;%set the number of training frames

fpernum1=baseTrainNum;

img_w=256;% soure image width
img_h=256;% soure image height

poolnum=35;%set the num of supporting blocks pool
refnum=20;%set the supporting blocks num 

DBr=zeros(img_w,img_h,fpernum1,'single');
DBLKr=zeros(img_w/8,img_h/8,poolnum,5,'single');% to save the training reuslts

DBg=zeros(img_w,img_h,fpernum1,'single');%
DBLKg=zeros(img_w/8,img_h/8,poolnum,5,'single');% to save the training reuslts


DBb=zeros(img_w,img_h,fpernum1,'single');%
DBLKb=zeros(img_w/8,img_h/8,poolnum,5,'single');% to save the training reuslts

idx=baseTrainNum;

 for t=1:idx % training the framse
         img=imread([trainPath,filename(t).name]);
         II=imresize(img,[img_w img_h]);
		 
         IIr=II(:,:,1);
         DBr(:,:,t)=IIr;%three-channel segmentation
        
         
         IIg=II(:,:,2);
         DBg(:,:,t)=IIg;
 
         IIb=II(:,:,3);
         DBb(:,:,t)=IIb;
                   
   end
   
    tic
     DBLKr=trainncc2(DBr,poolnum);
    toc;
 	 DBLKg=trainncc2(DBg,poolnum);
	 DBLKb=trainncc2(DBb,poolnum);%the background model
   
    save DBLKr DBLKr
    save DBLKg DBLKg
    save DBLKb DBLKb
    
  
 