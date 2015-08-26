function [img] = get_poselet_patch_img(poselet_patch, config)

    % Read whole source image
    img = imread([config.PATH_JPEGIMAGES poselet_patch.obj_annotations.image_filename '.jpg']);
    
    % Get xmax and ymax
    xmax = poselet_patch.patch.top_left(2) + poselet_patch.patch.hw(2) - 1;
    if xmax>=size(img,2)
        xmax=size(img,2)-1;
    end
    ymax = poselet_patch.patch.top_left(1) + poselet_patch.patch.hw(1) - 1;
    if ymax>=size(img,1)
        ymax=size(img,1)-1;
    end
    % Crop image so as to leave the patch only
    img = img(	poselet_patch.patch.top_left(1):ymax, ...
                poselet_patch.patch.top_left(2):xmax, ...
                :);


end