function [act_win] = detect_deep_poselet_in_image_1svm(img,img_name, classifier, config)
% Convert image to double precision.
act_win=hit_list;
img = double(img);

% Input image dimensions.
img_width = size(img,2);
img_height = size(img,1);

% Detection window constant dimensions.
win_dims = [61 61];
win_move=15;
% Initial scale for the whole image.
%s = config.POSELET_PATCH_WIDTH / config.SEED_MIN_WIDTH_PX;
%s=36/15;
%s = 1.2;
scales=[1.2 1 0.8 0.6 0.4 0.2];

num_acts=0;
s=1;

% Start scanning on top left of the image.
while s<=length(scales)
    if exist('acts', 'dir')
        rmdir('acts','s');
        rehash();
    end
    patch_per_scale=0;
    mkdir('acts');
   % display(['Scale = ' num2str(scales(s))]);
    % Scale the image.
    im1 = mex_imresize(img, floor(img_height*scales(s)), floor(img_width*scales(s)));
    tl = [1 1];
    
    i_img=0;im_height=0;
    tot_bounds=[];
    while tl(1) + win_dims(1) <= size(im1,1)
        im_width=0;
        while tl(2) + win_dims(2) <= size(im1,2)
            im_width=im_width+1;
            i_img=i_img+1;
            %                 % Get the image patch under the window.
            impatch = im1( tl(1):(tl(1)+win_dims(1)-1), tl(2):(tl(2)+win_dims(2)-1),: );
            bounds=[tl(2);tl(1);60;60];
            tot_bounds=[tot_bounds bounds];
            imwrite(uint8(impatch),['acts/' num2str(i_img) '.jpg']);
            
            tl(2) = tl(2) + win_move;
            patch_per_scale=patch_per_scale+1;
            %                 %fprintf('.');
        end
        % Move the window down and back left.
        %tl(1) = tl(1) + config.SLIDING_WINDOW_OFFSET_PX(1);
        im_height=im_height+1;
        tl(1) = tl(1) + win_move;
        tl(2) = 1;
        % fprintf('\n');
    end
    if patch_per_scale>0
        [status,cmdout] = system('cd deep_net-python && python deepnet_256-extract.py ../acts/');
        fclose('all');
        %time=toc
        if status ~=0
            error(['Python Error: ' cmdout])
        end
        if exist('deep_vectors.txt','file')
            fileID = fopen('deep_vectors.txt');
            features256 = textscan(fileID,'%f64');
            deep256_vectors=zeros(i_img,256);
            for i=1:i_img
                deep256_vectors(i,:)=features256{1}(((i-1)*256)+1:(i*256));
            end
            act_win.file_name=img_name;
            fclose(fileID);
            
            [predicted_label,svm_score] = svmclassify(classifier.svm,deep256_vectors);
            if find(predicted_label==1)
                index=find(predicted_label==1);
                mat_pred=reshape(predicted_label,im_width,im_height)';
                [n_row,n_col]=find(mat_pred==1);
                for k=1:length(find(predicted_label==1))
                    if (abs(svm_score(index(k)))) > (abs(classifier.ksc))
                    %    if (abs(svm_score(index(k)))) > 0
                        num_acts=num_acts+1;
                        act_win.score(num_acts,1)=abs(svm_score(index(k)));%act_win.poselet_id(num_acts,1)=h;
                        act_win.bounds(1,num_acts)=tot_bounds(1,index(k))/scales(s);act_win.bounds(2,num_acts)=tot_bounds(2,index(k))/scales(s);
                        act_win.bounds(3,num_acts)=win_dims(2)/scales(s);act_win.bounds(4,num_acts)=win_dims(1)/scales(s);
                        act_win.scale(num_acts,1)=scales(s);
                    end
                end
            end
            
        end
    end
    s=s+1;    
    act_win.size=num_acts;
    act_win.src_idx={};
    act_win.image_id=zeros(num_acts,1);
end
end