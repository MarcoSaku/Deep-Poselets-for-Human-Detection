%% Initialization
warning off
global config;
config=init();
load anns;
[ rcnn_model,net ]=my_rcnn_init();
load mat-files/classifiers_face12-400;load mat-files/classifiers_face13-400;load mat-files/classifiers_face1-400;load mat-files/classifiers_frontal22-400;load mat-files/classifiers_frontal41-400
classifiers=[classifiers_face12 classifiers_face13 classifiers_face1 classifiers_frontal22];
for i=1:length(classifiers)
    classifiers{i}=get_bboxes( classifiers{i},config );
end
write_files=false;
start_full_rcnn=false;
start_rcnn=true;
% classifier=classifiers{9};
% img_name=[config.PATH_JPEGIMAGES classifier.poselet_patches{359}.obj_annotations.image_filename '.jpg'];

% img_name=get_random_person_image(anns_files,config);
% img = imread( img_name);figure;imshow(img);

img_name='images\4.jpg';
img=imread(img_name);imshow(img);
t1=tic;t2=tic;
[poselet_hits]=detect_deep_poselet_in_image(img,img_name, classifiers, config);
fprintf('Time to detect poselets in image %.3fs\n',toc(t1));
if poselet_hits.size>0
    [srt,srtd]=sort(abs(poselet_hits.score),'descend');
    poselet_hits.score = poselet_hits.score(srtd,1);
    poselet_hits.bounds=poselet_hits.bounds(:,srtd);
    poselet_hits.scale=poselet_hits.scale(srtd,1);
    
    poselet_hits.poselet_id=poselet_hits.poselet_id(srtd,1);
    
    poselet_hits = nonmax_suppress_hits(poselet_hits);    
    
    for i=1:poselet_hits.size
        poselet_hits.score(i,1)=abs(poselet_hits.score(i,1))*classifiers{poselet_hits.poselet_id(i,1)}.accuracy;
    end
     
    
    hyps=set_kps_gaussians(poselet_hits,classifiers);
    cluster_labels = cluster_poselet_hits(poselet_hits,hyps,config);
    [scores_clust,ord_clust]=write_clusters(img,cluster_labels,poselet_hits,write_files);
    [bbox_clust]=set_bbox(poselet_hits,classifiers,cluster_labels,img);
    bbox_clust=bbox_clust(ord_clust,:);
    keep=suppress_bbox(bbox_clust);
    fprintf('Time to detect bounding boxes in image %.3fs\n',toc(t2));
    show_boxes(img,bbox_clust(keep,:),scores_clust(keep));
    
    if start_rcnn
        my_rcnn_demo(img,rcnn_model,net,bbox_clust(:,:));
    end
    
    if start_full_rcnn
        my_rcnn_demo(img,rcnn_model,net);
    end
    if write_files
        write_activations(poselet_hits,img_name)
        write_activations_indirs(poselet_hits,img_name)
    end

end