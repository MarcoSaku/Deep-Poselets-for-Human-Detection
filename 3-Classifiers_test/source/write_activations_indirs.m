function write_activations_indirs(acts,img_name)
num_img=0;
if exist('temp/det_acts_dirs', 'dir')
    rmdir('temp/det_acts_dirs','s');
    rehash();
end
mkdir('temp/det_acts_dirs');
% for i=1:size(acts,2)
%scale=acts{i}.scale;
%img = imread(acts.file_name);
img = imread(img_name);
s=1.0;
[height,width,ch]=size(img);
img=double(img);
img = mex_imresize(img, floor(height*s), floor(width*s));

[height,width,ch]=size(img);
%img=imresize(img,scale);
for i=1:acts.size
        xmax = acts.bounds(1,i) + acts.bounds(3,i) - 1;
        ymax = acts.bounds(2,i) + acts.bounds(4,i) - 1;
        img_act = img(acts.bounds(2,i):ymax, acts.bounds(1,i):xmax, :);
        num_img=num_img+1;
        dir_id=acts.poselet_id(i);dir_name=['temp/det_acts_dirs/' num2str(dir_id) '/'];
        if ~exist(dir_name,'dir')
            mkdir(dir_name);
        end
        file_name=[dir_name num2str(num_img) '.jpg'];
        imwrite(uint8(img_act),file_name);
    %end
end
%end


end









% 
% 
% 
% 
% function write_activations(acts)
% num_img=0;
% if exist('det_acts', 'dir')
%     rmdir('det_acts','s')
% end
% mkdir('det_acts');
% % for i=1:size(acts,2)
% %scale=acts{i}.scale;
% img = imread(acts.file_name);
% s=0.5;
% [height,width,ch]=size(img);
% img=double(img);
% img = mex_imresize(img, floor(height*s), floor(width*s));
% 
% [height,width,ch]=size(img);
% %img=imresize(img,scale);
% for i=1:acts.size
%     %act_img=acts(j);
%     %if acts.score(i)>0.5
%         %                  xmax = act_img.bounds(1) + act_img.bounds(3) - 1;
%         %                  ymax = act_img.bounds(2) + act_img.bounds(4) - 1;
%         %                  img_act = img(	act_img.bounds(1):xmax, act_img.bounds(2):ymax, :);
%         xmax = acts.bounds(1,i) + acts.bounds(3,i) - 1;
%         ymax = acts.bounds(2,i) + acts.bounds(4,i) - 1;
%         img_act = img(acts.bounds(2,i):ymax, acts.bounds(1,i):xmax, :);
%         num_img=num_img+1;
%         file_name=['det_acts/' num2str(num_img) '.jpg'];
%         imwrite(uint8(img_act),file_name);
%     %end
% end
% %end
% 
% 
% end

