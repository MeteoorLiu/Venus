clear all
clc
close all
%*******for training*******% 
    
Root ='D:\Background Subtraction\NewExperiment\Git-SUMC\dataset\';
subdir = dir(Root);
length1 = length(subdir);
for i=1:length1
    if( isequal( subdir( i ).name, '.' )||isequal( subdir( i ).name, '..')||~subdir( i ).isdir)               % �����Ŀ¼�����
        continue;
    end
    subroot = fullfile(Root, subdir( i ).name );
    finaldir = dir(subroot);
    length2 = length(finaldir);
    for j=1:length2
        if( isequal( finaldir( j ).name, '.' )||isequal( finaldir( j ).name, '..')||~finaldir( j ).isdir)               % �����Ŀ¼�����
            continue;
        end
        trainpath = fullfile(subroot, finaldir( j ).name );
        outputname = strcat('training on the \20', subdir(i).name, '/', finaldir(j).name, '\20 dataset', '\n');
        fprintf(outputname);
        matrix(trainpath);
    end
end


function matrix(path)
    baseTrainNum=400;%set the number of training frames

    fpernum1=baseTrainNum;

    img_w=256;% soure image width
    img_h=256;% soure image height

    poolnum=35;%set the num of supporting blocks pool
    refnum=20;%set the supporting blocks num
    
    trainPath = strcat(path, '/trainraw/');
    filename = dir(strcat(trainPath, '*.jpg')); % load the training frames

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
     
    save_path_r = strcat(path,'\DBLKr.mat');
    save_path_g = strcat(path,'\DBLKg.mat');
    save_path_b = strcat(path,'\DBLKb.mat');
    
    save(save_path_r,'DBLKr');
    save(save_path_g,'DBLKg');
    save(save_path_b,'DBLKb');

end
