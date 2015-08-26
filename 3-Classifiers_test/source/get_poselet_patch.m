function [poselet_patch,valid] = get_poselet_patch(ann_id, anns_files, seed_patch, config)
    %display('Getting a poselet patch...');
    xml_filename = anns_files(ann_id).name;

    obj_annotations = get_obj_annotations_from_xml(xml_filename, config);
    
    
    
    % Find the minimal bounding box around the keypoints in common with the
    % seed patch.
    
    % Find the ids of those keypoints.
    kp_in_ids    = find(seed_patch.patch.kp.present);
    % Get their [x y] coordinates.
    kp_in_coords = obj_annotations.kp.coords(kp_in_ids, (1:2));
    
    xmin = min(kp_in_coords(:,1));
    xmax = max(kp_in_coords(:,1));
    ymin = min(kp_in_coords(:,2));
    ymax = max(kp_in_coords(:,2));
    
    % Initial top left corner.
    top_left = [ymin xmin];
    
    % Initial dimensions.
    i_height = ymax - ymin;
    i_width  = xmax - xmin;
    
    % Get the aspect ratio for the minimal bounding box.
    aspect = i_height / i_width;
    
    height = i_height;
    width = i_width;
    
    % Update the corresponding dimension and top left corner to fit the
    % aspect ratio of the seed patch.
    if (aspect > config.SEED_PATCH_ASPECT_RATIO)
        % Grow horizontally
        width = (1 / config.SEED_PATCH_ASPECT_RATIO) * i_height;
        % Move the box to the left.
        top_left(2) = top_left(2) - ((width - i_width) / 2);
    else
        % Grow vertically
        height = config.SEED_PATCH_ASPECT_RATIO * i_width;
        % Move the box upwards.
        top_left(1) = top_left(1) - ((height - i_height) / 2);
    end
    assert(height > 0 && width > 0);
    hw = [height width];
       
    
    % Add a margin around.the bounding box.
    top_left = top_left - config.POSELET_PATCH_MARGIN_FACTOR * hw;
    hw = hw + 2 * config.POSELET_PATCH_MARGIN_FACTOR * hw;
    
    % Get image dimensions:
    img_filename = obj_annotations.image_filename;
    img = imread([config.PATH_JPEGIMAGES img_filename '.jpg']);
    
    im_height = size(img,1);
    im_width = size(img,2);
    
    
    % Is the computed patch inside the image?
    valid = true;
    %if ~all(top_left > 0)
    if (top_left(1)<1) || (top_left(2)<1)
        valid = false;
    elseif (top_left(1) + hw(1) > im_height)
        valid = false;
    elseif (top_left(2) + hw(2) > im_width)
        valid = false;
    elseif (hw(1)<config.MIN_POSELET_PATCH) || (hw(2)<config.MIN_POSELET_PATCH)
        valid=false;
    end
        
    poselet_patch.obj_annotations = obj_annotations;
    
    poselet_patch.patch.top_left = top_left;
    poselet_patch.patch.kp.present = seed_patch.patch.kp.present;
    poselet_patch.patch.hw = hw;
    poselet_patch.patch.valid = valid;
end