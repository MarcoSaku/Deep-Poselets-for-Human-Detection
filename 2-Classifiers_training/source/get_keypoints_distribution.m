%For each classifier get the keypoints distributions
function poselets= get_keypoints_distribution(poselets,config)
if exist('temp/keypoints_one', 'dir')
    rmdir('temp/keypoints_one','s');
end
mkdir('temp/keypoints_one');

kps_x_tot=[];kps_y_tot=[];
for i=1:length(poselets.poselet_patches)
    label=find(poselets.poselet_patches{i}.obj_annotations.kp.coords(:,1));
    kps_x=poselets.poselet_patches{i}.obj_annotations.kp.coords(:,1);
    kps_y=poselets.poselet_patches{i}.obj_annotations.kp.coords(:,2);
    kps_x=kps_x(1:20);kps_y=kps_y(1:20);
    kps_x=kps_x(find(kps_x));kps_y=kps_y(find(kps_y));
    
    patch_cent=poselets.poselet_patches{i}.patch.top_left+poselets.poselet_patches{i}.patch.hw./2;
    patch_center=patch_cent([2 1]);patch_center=repmat(patch_center,size(kps_x,1),1);
    
    kps_x_cent=kps_x-patch_center(:,1);
    kps_y_cent=kps_y-patch_center(:,2);
    
    kps_x_cent=normc(kps_x_cent);
    kps_y_cent=normc(kps_y_cent)*2;
    
    kpsx=zeros(20,1);kpsy=zeros(20,1);
    kpsx(label)=kps_x_cent;kpsy(label)=kps_y_cent;
    kps_x_tot=[kps_x_tot kpsx];kps_y_tot=[kps_y_tot kpsy];
    
    % plot(kps_x_cent,kps_y_cent,'o');axis ij;
end
    %kps_m=[13 14 17 18 19 1 4 7 10];
    kps_m=[1:20];
    kps_x_tot(kps_x_tot == 0) = NaN;kps_y_tot(kps_y_tot == 0) = NaN;
        
   
    kps_x_tot=kps_x_tot';kps_y_tot=kps_y_tot';
    
    
  %  f=figure;plot(kps_x_tot(:,kps_m),kps_y_tot(:,kps_m),'*');axis ij;axis equal
   
    
  %   xLimits = get(gca,'XLim');  %# Get the range of the x axis
  %   yLimits = get(gca,'YLim');  %# Get the range of the y axis
    
   
    
    hold on
    for k=kps_m
        obj{k} = gmdistribution.fit([kps_x_tot(:,k) kps_y_tot(:,k)],1);
        mu{k}=obj{k}.mu;sigma{k}=obj{k}.Sigma;
       % h = ezcontour(@(x,y)pdf(obj{k},[x y]),[xLimits yLimits],800);
        %h = ezsurf(@(x,y)pdf(obj{k},[x y]),[-1 1],[-1 1],500);
        kps_mu(k,:)=obj{k}.mu;kps_sigma(k,:)=diag(obj{k}.Sigma);
        %kps_mu(kp_points_lab(k),:)=obj{k}.mu;
        %kps_sigma(kp_points_lab(k),:)=diag(obj{k}.Sigma);
        
        %pause
    end
    poselets.kps_mu=kps_mu;
    poselets.kps_sigma=kps_sigma;
    
    coords_sum=zeros(20,2);coords_sum2=zeros(20,2);
    coords_sum(:,1)=sum(kps_x_tot);coords_sum(:,2)=sum(kps_y_tot);
    coords_sum2(:,1)=sum(kps_x_tot.^2);coords_sum2(:,2)=sum(kps_y_tot.^2);
    poselets.coords_sum=coords_sum;
    poselets.coords_sum2=coords_sum2;
    
    rect(1)=min(kps_x_tot(:));
    rect(2)=min(kps_y_tot(:));
    rect(3)=max(kps_x_tot(:));
    rect(4)=max(kps_y_tot(:));
    
    poselets.rect=rect;
    poselets.w_sum=ones(20,2);
    %poselets{j}.kps_label=kp_points_lab;
%     file_name=['temp/keypoints_one/' num2str(j) '.jpg'];
%     saveas(f,file_name);
%     
    
end















