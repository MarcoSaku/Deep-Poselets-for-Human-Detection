global config
config=init;
time=clock;
% Directory containing the output poselet images
path_pos='./image-poselets';
% Choose the category here
category = 'person';
% It is a parallel implementation: set the number of cores in NUM_CORE
NUM_CORE=12;

      
data_root = [config.DATA_DIR '/' category];
if exist(path_pos, 'dir')
    rmdir(path_pos,'s')
end
mkdir(path_pos,'true');
mkdir([path_pos '/false']);

for i=1:150
	mkdir([path_pos '/true/' num2str(i)])
end

disp(['Running on ' category]);

faster_detection = false;  % Set this to false to run slower but higher quality
interactive_visualization = false; % Enable browsing the results
enable_bigq = true; % enables context poselets

if faster_detection
    disp('Using parameters optimized for speed over accuracy.');
    config.DETECTION_IMG_MIN_NUM_PIX = 500^2;  % if the number of pixels in a detection image is < DETECTION_IMG_SIDE^2, scales up the image to meet that threshold
    config.DETECTION_IMG_MAX_NUM_PIX = 750^2;
    config.PYRAMID_SCALE_RATIO = 2;
end

% Loads the SVMs for each poselet and the Hough voting params
clear output poselet_patches fg_masks;
load([data_root '/model.mat']); % model
if exist('output','var')
    model=output; clear output;
end
if ~enable_bigq
    model =rmfield(model,'bigq_weights');
    model =rmfield(model,'bigq_logit_coef');
    disp('Context is disabled.');
end
if ~enable_bigq || faster_detection
    disp('*******************************************************');
    disp('* NOTE: The code is running in faster but suboptimal mode.');
    disp('*       Before reporting comparison results, set faster_detection=false; enable_bigq=true;');
    disp('*******************************************************');
end
if interactive_visualization && (~exist('poselet_patches','var') || ~exist('fg_masks','var'))
    disp('Interactive visualization not supported for this category');
    interactive_visualization=false;
end
%directory containing the images containing people
img_dir=strcat(data_root,'/Coco_images/');
list=dir(img_dir);
file_list=setdiff({list.name},{'.','..','.DS_Store'})';

%
%Read the groundtruth from json file
disp('Parsing JSON...')
fname = 'bboxes-train.json';
fid = fopen(fname);
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
data = JSON.parse(str);
tot_image=size(data,2);
% Execute on each file in the directory
% PARALLEL IMPLEMENTATION
for f=1:NUM_CORE:tot_image
    img={};img_name=cell(1,NUM_CORE);height=[];width=[];channels=[];bounds_predictions={};poselet_hits={};im_name={};
    disp ' '
    for pp=0:NUM_CORE-1
        img_name{pp+1}=file_list(f+pp);
    end
    %img_name{1}=file_list(f);img_name{2}=file_list(f+1);img_name{3}=file_list(f+2);img_name{4}=file_list(f+3);
    parfor ff=1:NUM_CORE
        im_name{ff}=img_name{ff}{1};
        disp(['PROCESSING IMAGE ' num2str(f+ff-1) '/' num2str(tot_image)]);
        image_name=strcat(img_dir, im_name{ff});
        %im1.image_file{1}=image_name{1};
        img{ff} = imread(image_name);
        
        [height(ff),width(ff),channels(ff)]=size(img{ff});
        if channels(ff)==1
            img{ff} = repmat(img{ff},[1 1 3]);
        end
        %         %Estrazione bboox e poselet activations
        [bounds_predictions{ff},poselet_hits{ff}]=detect_objects_in_image(img{ff},model,config);
    end
    %matlabpool('close');
    %params.poselet_patches=poselet_patches;
    %params.all_torso_hits=torso_predictions;
    %params.all_poselet_hits=poselet_hits;
    %params.masks=fg_masks;
    
    %bounds_predictions.image_id(:)=1;
    %params.all_poselet_hits.image_id(:)=1;
    %%% Ordinamento bounds in base allo score
    for zf=1:NUM_CORE
        tot_bounds=size(bounds_predictions{zf}.bounds,2);
        %Ricerca immagine nel JSON
        found_im=0;
        k=0;
        
        while found_im==0 && k<tot_image
            k=k+1;
            if strcmp(data{k}.file_name, img_name{zf})
                found_im=1;
            end
            
        end
        
        if found_im==1
            tot_bbox=size(data{k}.bbox,2);
            j=1;
            pos_ok=zeros(tot_bounds,tot_bbox);
            while j<=tot_bbox
                bbox=cell2mat(data{k}.bbox{j});
                int_union=bounds_overlap(bbox,bounds_predictions{zf}.bounds);
                pos_ok(:,j)=int_union>0.5;
                j=j+1;
            end
            z=1;
            while z<=tot_bounds
                pos_true=pos_ok(z,:);
                ff=find(pos_true);
                if size(ff,2)==0
                    bound_ok=0;
                else
                    bound_ok=1;
                end
                n_pos_bound=size(bounds_predictions{zf}.src_idx{z},2);
                for ii=1:n_pos_bound
                    if bound_ok==1
                        pos_id=bounds_predictions{zf}.src_idx{z}(ii);
                        mm=find(indok==poselet_hits{zf}.poselet_id(pos_id));
                        if isempty(mm)
                            pos_bounds=poselet_hits{zf}.bounds(:,pos_id);
                            
                            x_pos=floor(pos_bounds(2):pos_bounds(2)+pos_bounds(4));
                            y_pos=floor(pos_bounds(1):pos_bounds(1)+pos_bounds(3));
                            y_pos=y_pos((y_pos<width(zf)) & (y_pos>0));
                            x_pos=x_pos((x_pos<height(zf)) & (x_pos>0));
                            img_pos=img{zf}(x_pos,y_pos,:);
                            %                     img_pos_res = imresize(img_pos,[61 61]);
                            %directory in cui inserire la poselet (in base a bbox=positivo/negativo)
                            
                            n_true=n_true+1;
                            
                            name=strcat([path_pos '/true/' num2str(poselet_hits{zf}.poselet_id(pos_id))],num2str(n_true),'.jpg');
                            %fprintf(fid_ytrue,'%d ',poselet_hits{zf}.poselet_id(pos_id));
                            else
                                 n_false=n_false+1;
                            
                                 name=strcat([path_pos '/false/'],num2str(n_false),'.jpg');
                            %                     fprintf(fid_yfalse,'%d ',poselet_hits.poselet_id(pos_id));
                            
                            %                     mean3=mean(mean(img_pos_res(:,:,:)));
                            %                     img_pos_res(:,:,1)=abs(img_pos_res(:,:,1) - mean3(1));
                            %                     img_pos_res(:,:,2)=abs(img_pos_res(:,:,2) - mean3(2));
                            %                     img_pos_res(:,:,3)=abs(img_pos_res(:,:,3) - mean3(3));
                            imwrite(img_pos,name);
                        end
                    end
                end
                
                z=z+1;
            end
        else
            disp('Image not present in json');
        end
        
        
    end
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     %browse_hits(bounds_predictions,im1,params);
end
% fid_yfalse = fclose(fid_yfalse);
%fid_ytrue = fclose(fid_ytrue);
%timespent=toc


