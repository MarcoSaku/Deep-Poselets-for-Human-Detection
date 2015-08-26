function write_poselets_images( poselet_patches,config)
if exist('poselets_image', 'dir')
    rmdir('poselets_image','s')
end
mkdir('poselets_image');
for i=1:length(poselet_patches)
    img_name=[config.PATH_JPEGIMAGES poselet_patches{i}.obj_annotations.image_filename '.jpg'];
    img=imread(img_name);
    img_name=['poselets_image/' num2str(i) '.jpg'];
    imwrite(img,img_name)
end



end

