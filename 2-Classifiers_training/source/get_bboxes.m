%Get bounding box prediction for each poselet-classifier
function [ poselets ] = get_bboxes( poselets,config )
x=[];y=[];
for i=1:length(poselets.poselet_patches)
    %label=find(poselets.poselet_patches{i}.obj_annotations.kp.coords(:,1));
    
    x1=poselets.poselet_patches{i}.obj_annotations.bounding_box.xmin;
    y1=poselets.poselet_patches{i}.obj_annotations.bounding_box.ymin;
    width=poselets.poselet_patches{i}.obj_annotations.bounding_box.width;
    height=poselets.poselet_patches{i}.obj_annotations.bounding_box.height;
    x2=x1+width;
    y2=y1+height;
    
    patch_cent=poselets.poselet_patches{i}.patch.top_left+poselets.poselet_patches{i}.patch.hw./2;
    patch_center=patch_cent([2 1]);
    
    x1_cent=x1-patch_center(1);x2_cent=x2-patch_center(1);
    y1_cent=y1-patch_center(2);y2_cent=y2-patch_center(2);
    
    x=[x;x1_cent x2_cent];
    y=[y;y1_cent y2_cent];
%     xmin_cent=normc(xmin_cent);
%     kps_y_cent=normc(kp)*2;
%     
%     kpsx=zeros(20,1);kpsy=zeros(20,1);
%     kpsx(label)=kps_x_cent;kpsy(label)=kps_y_cent;
%     kps_x_tot=[kps_x_tot kpsx];kps_y_tot=[kps_y_tot kpsy];
%     
    % plot(kps_x_cent,kps_y_cent,'o');axis ij;
end
    %kps_m=[13 14 17 18 19 1 4 7 10];
    x_=normr(x)*1.3;
    y_=normr(y)*2.1;
    %plot(x,y,'*');axis ij;
    
    poselets.bbox(1)=mean(x_(:,1),1);
    poselets.bbox(2)=mean(y_(:,1),1);
    poselets.bbox(3)=mean(x_(:,2),1);
    poselets.bbox(4)=mean(y_(:,2),1);
    %poselets{j}.kps_label=kp_points_lab;
%     file_name=['keypoints_one/' num2str(j) '.jpg'];
%     saveas(f,file_name);
%     


end

