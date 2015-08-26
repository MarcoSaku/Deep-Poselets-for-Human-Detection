function [poselet_patch] = get_random_patch(anns_files, cat_xml_path, config)
    % Find an annotation with enough size
    rand('state',sum(100.*clock));
    enough_size = false;
    while ~enough_size
        % Get a random file from it
        rand_file = randsample(anns_files,1);

        % Get the bounding box and keypoint information from the annotation file
        obj_annotations = get_obj_annotations_from_xml_no_kp(rand_file.name, cat_xml_path, config);


        % Set the min height for the poselet patch
        SEED_MIN_HEIGHT_PX =  config.NEG_MIN_WIDTH * config.SEED_PATCH_ASPECT_RATIO;

        % Set the max dimensions from the bounding box size
        SEED_MAX_WIDTH_PX  = obj_annotations.bounding_box.width;
        SEED_MAX_HEIGHT_PX = obj_annotations.bounding_box.height;

        if(  config.NEG_MIN_WIDTH < obj_annotations.bounding_box.width  && ...
            SEED_MIN_HEIGHT_PX       < obj_annotations.bounding_box.height )
            enough_size = true;
        end

       
    end
    assert( config.NEG_MIN_WIDTH < SEED_MAX_WIDTH_PX);


    % Get a random size for the seed patch.
    % It cannot exceed the bounding box.
    hw = [0 0];

    ANNOT_ASPECT_RATIO = obj_annotations.bounding_box.height / ...
                         obj_annotations.bounding_box.width;

    if (ANNOT_ASPECT_RATIO >= config.SEED_PATCH_ASPECT_RATIO)
        % Random width:
        hw(2) =  config.NEG_MIN_WIDTH + ...
                  rand(1) * (SEED_MAX_WIDTH_PX -  config.NEG_MIN_WIDTH);
        % Derived height:
        hw(1) = config.SEED_PATCH_ASPECT_RATIO * hw(2);
    else
        % Random height:
        hw(1) = SEED_MIN_HEIGHT_PX + ...
                    rand(1) * (SEED_MAX_HEIGHT_PX - SEED_MIN_HEIGHT_PX);
        % Derived width:
        hw(2) = hw(1) / config.SEED_PATCH_ASPECT_RATIO;
    end
    assert( hw(2) >=  config.NEG_MIN_WIDTH && ...
            hw(2) <= SEED_MAX_WIDTH_PX        && ...
            hw(1) >= SEED_MIN_HEIGHT_PX       && ...
            hw(1) <= SEED_MAX_HEIGHT_PX       );




    % Get a random position for the box, inside the annotation bounding box
    remaining_px = [(SEED_MAX_HEIGHT_PX - hw(1)) ...
                    (SEED_MAX_WIDTH_PX - hw(2))];

    obj_annotations_top_left = [obj_annotations.bounding_box.ymin ...
                                obj_annotations.bounding_box.xmin];

    patch_top_left = obj_annotations_top_left + (remaining_px .* rand([1 2]));

    
    
    
    poselet_patch.obj_annotations  = obj_annotations;
    poselet_patch.patch.hw  = hw;
    poselet_patch.patch.top_left   = patch_top_left;
    poselet_patch.patch.valid = true;
end




function [obj_annotations]=get_obj_annotations_from_xml_no_kp(filename, cat_xml_path, config)
    % Get the internal xml representation for the chosen xml file
    xmldoc = xmlread([cat_xml_path filename]);

    % Get needed XML nodes
    ximage = xmldoc.getElementsByTagName('image');
    xbounds = xmldoc.getElementsByTagName('visible_bounds');


    % Save filename as string
    obj_annotations.xml_filename = filename;
    % Save image name as string
    obj_annotations.image_filename = char(ximage.item(0).getFirstChild.getData);

    % Save bounding box information as doubles
    obj_annotations.bounding_box.xmin  = str2double(xbounds.item(0).getAttribute('xmin'));
    obj_annotations.bounding_box.ymin  = str2double(xbounds.item(0).getAttribute('ymin'));
    obj_annotations.bounding_box.width = str2double(xbounds.item(0).getAttribute('width'));
    obj_annotations.bounding_box.height= str2double(xbounds.item(0).getAttribute('height'));

end