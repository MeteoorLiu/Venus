clear all
clc
clear all

%*******for detecting*******% 
img_root ='D:\Background Subtraction\NewExperiment\Git-SUMC\dataset\';
load_root = 'D:\Background Subtraction\NewExperiment\Git-SUMC\dataset\';
save_root = 'D:\Background Subtraction\NewExperiment\Git-SUMC\pre';

subdir = dir(img_root);
%sub_save_dir = dir(save_root);
length1 = length(subdir);
for i=1:length1
    if( isequal( subdir( i ).name, '.' )||isequal( subdir( i ).name, '..')||~subdir( i ).isdir)               % ï¿½ï¿½ï¿½ï¿½ï¿½Ä¿Â¼ï¿½ï¿½ï¿½ï¿½ï¿½
        continue;
    end
    subroot = fullfile(img_root, subdir( i ).name );
    sub_load_root = fullfile(load_root, subdir( i ).name );
    sub_save_root = fullfile(save_root, subdir( i ).name );
    finaldir = dir(subroot);

    length2 = length(finaldir);
    for j=1:length2
        if( isequal( finaldir( j ).name, '.' )||isequal( finaldir( j ).name, '..')||~finaldir( j ).isdir)               % ï¿½ï¿½ï¿½ï¿½ï¿½Ä¿Â¼ï¿½ï¿½ï¿½ï¿½ï¿½
            continue;
        end
        imgpath = fullfile(subroot, finaldir( j ).name );
        load_path = fullfile(sub_load_root, finaldir( j ).name );
        save_path = fullfile(sub_save_root, finaldir( j ).name );
        submatrix(imgpath,load_path,save_path,finaldir( j ).name);
    end
end

function submatrix(imgpath, load_path, save_path, filename)
    img_w=256;% soure image width
    img_h=256;% soure image height

    af=3.5;%threshold (C)for Gaussian model
    sigema=0.8;%threshold 
    poolnum=35;
    BTh1=16500000000000;
    BTh2=7;

    load_path_r = strcat(load_path,'\DBLKr.mat');
    load_path_g = strcat(load_path,'\DBLKg.mat');
    load_path_b = strcat(load_path,'\DBLKb.mat');
    load (load_path_r);%load the background model
    load (load_path_g);
    load (load_path_b);
    
    testpath = strcat(imgpath, '\Testraw\');
    img_list = dir(testpath);
    img_num = length(img_list);

    for i=3:img_num %¼Ó2ÊÇÒòÎªlistÀïÓÐ'.'ºÍ'..'
        test_t=i;%testing frame

        framet=imread([testpath,img_list(test_t).name]);
        [m,n,l]=size(framet);
        
        m_start=1;
        m_end=m;
        n_start=1;
        n_end=fix(n/3);
        imgt=framet(m_start:m_end,n_start:n_end,:);
        IItest=imresize(imgt,[img_w img_h]);
   
        IIr=double(IItest(:,:,1)); % three-channel segmentation
        IIg=double(IItest(:,:,2)); 
        IIb=double(IItest(:,:,3)); 
        
        m_start=1;
        m_end=m;
        n_start=1+fix(n/3);
        n_end=2*fix(n/3);
        imgguide=framet(m_start:m_end,n_start:n_end,:);
        JJguide=imresize(imgguide,[img_w img_h]);
   
        JJr=double(JJguide(:,:,1))*0; % three-channel segmentation
        JJr(find(JJguide(:,:,1)>20))=1;% ï¿½ï¿½STAMï¿½Ö¸ï¿½ï¿½ï¿½Í³Ò»Îªï¿½ï¿½ÖµÍ¼
%       JJg=double(JJSTAM(:,:,2))*0; 
%       JJg(find(JJSTAM(:,:,2)>0))=1;
%       JJb=double(JJSTAM(:,:,3))*0; 
%       JJb(find(JJSTAM(:,:,3)>0))=1;
        JJg=JJr;
        JJb=JJr;
        
        %*******Foreground Segmentation CPB*****************%
%         tic
%          IIBr_CPB=subncc1(JJr,IIr,DBLKr,af,BTh1);%ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½JJrï¿½ï¿½ï¿½STAMï¿½Ñ¾ï¿½ï¿½Ö¸ï¿½ï¿½ï¿½ÉµÄ½ï¿½ï¿½ï¿½ï¿½Îªï¿½Î¿ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
%         toc
% 	  
%         IIBg_CPB=subncc1(JJg,IIg,DBLKg,af,BTh1);
%         IIBb_CPB=subncc1(JJb,IIb,DBLKb,af,BTh1);
%         IIB_CPB=IIBr_CPB+IIBg_CPB+IIBb_CPB;% the result    
      
         tempname=strsplit(img_list(test_t).name,'.');
%         if exist(strcat(save_path,'/CPB'),'dir')==0
%             mkdir(strcat(save_path,'/CPB/'));
%         end
%         %mkdir(strcat(save_path,'/CPB/'));
%         CPB_save_path = strcat(save_path,'/CPB/',tempname{1},'.bmp');% save the result for stage 1
%         imwrite(IIB_CPB,CPB_save_path);
        
        %*******Foreground Segmentation stage 1*****************%
        IIBr=subncc1(JJr,IIr,DBLKr,af,BTh2);%ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½JJrï¿½ï¿½ï¿½STAMï¿½Ñ¾ï¿½ï¿½Ö¸ï¿½ï¿½ï¿½ÉµÄ½ï¿½ï¿½ï¿½ï¿½Îªï¿½Î¿ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
        IIBg=subncc1(JJg,IIg,DBLKg,af,BTh2);
        IIBb=subncc1(JJb,IIb,DBLKb,af,BTh2);
        IIB_stage1=IIBr+IIBg+IIBb;% the result    
      
%         tempname=strsplit(img_list(test_t).name,'.');
%         if exist(strcat(save_path,'/stage1'),'dir')==0
%             mkdir(strcat(save_path,'/stage1/'));
%         end
%         %mkdir(strcat(save_path,'/stage1/'));
%         seg1_save_path = strcat(save_path,'/stage1/',tempname{1},'.bmp');% save the result for stage 1
%         imwrite(IIB_stage1,seg1_save_path);
        
        %*******Foreground Segmentation stage 2*****************%
        IIBr_stage2=BlockReplacement(DBLKr,IIr,IIB_stage1,JJr,img_w,img_h,af,poolnum);
        IIBg_stage2=BlockReplacement(DBLKg,IIg,IIB_stage1,JJg,img_w,img_h,af,poolnum);
        IIBb_stage2=BlockReplacement(DBLKb,IIb,IIB_stage1,JJb,img_w,img_h,af,poolnum);
        IIB_stage2=IIBr_stage2+IIBg_stage2+IIBb_stage2;
        
%         median_stage2=median_filter(IIB_stage2,3);
%         %tempname=strsplit(img_list(test_t).name,'.');
%         if exist(strcat(save_path,'/stage2'),'dir')==0
%             mkdir(strcat(save_path,'/stage2/'));
%         end
%         %mkdir(strcat(save_path,'/stage2/'));
%         seg2_save_path = strcat(save_path,'/stage2/',tempname{1},'.bmp');% save the result for stage 1
%         imwrite(median_stage2,seg2_save_path);
        
        %*******Foreground Segmentation stage 3*****************%
        IIBr_stage3=Getrsigementation(DBLKr,IIr,IIBr_stage2,JJr,img_w,img_h,sigema,poolnum);
        IIBg_stage3=Getrsigementation(DBLKg,IIg,IIBg_stage2,JJg,img_w,img_h,sigema,poolnum);
        IIBb_stage3=Getrsigementation(DBLKb,IIb,IIBb_stage2,JJb,img_w,img_h,sigema,poolnum);
        IIB_stage3=IIBr_stage3+IIBg_stage3+IIBb_stage3;
        
        final_stage3=median_filter(IIB_stage3,3);
        
        m_start=1;
        m_end=m;
        n_start=1+2*fix(n/3);
        n_end=3*fix(n/3);
        gtt=framet(m_start:m_end,n_start:n_end,:);
        gt=imresize(gtt,[img_w img_h]);
        
        Plus=zeros(img_h,4*img_w,l);
        Plus=uint8(Plus);
    
        for c=1:l
            for j=1:img_h
                for k=1:img_w
                    Plus(j,k,c)=IItest(j,k,c);
                end
            end
    
            for j=1:img_h
                for k=(img_w+1):(2*img_w)
                    Plus(j,k,c)=final_stage3(j,k-img_w);
                end
            end
            
            for j=1:img_h
                for k=(2*img_w+1):(3*img_w)
                    Plus(j,k,c)=JJguide(j,k-2*img_w);
                end
            end
            
            for j=1:img_h
                for k=(3*img_w+1):(4*img_w)
                    Plus(j,k,c)=gt(j,k-3*img_w);
                end
            end
        end
        
        %tempname=strsplit(img_list(test_t).name,'.');
        if exist(strcat(save_path,'/stage3'),'dir')==0
            mkdir(strcat(save_path,'/stage3/'));
        end
        seg3_save_path = strcat(save_path,'/stage3/',tempname{1},'.png');% save the result for stage 1
        imwrite(Plus,seg3_save_path);
        
        printinfo = strcat('this is the %d-th frame of stage3 in',32,filename,'\n');
        fprintf(printinfo,test_t);
        
    end
end