function [ score_clust,ord ] = write_clusters( img,cluster_labels,acts,write_files )
num_img=0;
if exist('temp/acts_clusters', 'dir')
    rmdir('temp/acts_clusters','s');
    rehash();
end
mkdir('temp/acts_clusters');

for i=1:max(cluster_labels)
     score(i)=sum(acts.score(cluster_labels==i));
end
[score_clust,ord]=sort(score,'descend');

if write_files==true
for i=1:max(cluster_labels)
    c=find(cluster_labels==ord(i))';
    dir_name=['temp/acts_clusters/' num2str(i) '/'];
    if ~exist(dir_name,'dir')
        mkdir(dir_name);
    end
    for j=c
        xmax = acts.bounds(1,j) + acts.bounds(3,j) - 1;
        ymax = acts.bounds(2,j) + acts.bounds(4,j) - 1;
        img_act = img(acts.bounds(2,j):ymax, acts.bounds(1,j):xmax, :);
        num_img=num_img+1;
        
        file_name=[dir_name num2str(j) '.jpg'];
        imwrite(uint8(img_act),file_name);
    end
end
end


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



