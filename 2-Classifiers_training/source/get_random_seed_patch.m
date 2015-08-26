%Return a random poselet-patch. 
%If you pass kps as third parameter of function, you will get a poselet-patch with that keypoints inside
%Otherwise the function returns a random poselet-patch with random keypoints
function [poselet_patch] = get_random_seed_patch(anns_files,config,kps)

    % Find patch with enough keypoints inside
    valid_patch = false;
    if nargin>2
        kps_match=zeros(33,1);
        kps_match(kps)=1;
        kps_check=true;
    else
        kps_check=false;
    end
    %%%%%%%%%%%%%%%%%%%%%%
    %% KEYPOINTS USED 
    %kps_match=zeros(33,1);
     %Poselet 16 - face1 (no R_Ear)
    %kps_match([13 14 17 15])=1;
    %
    %Poselet - Faccia-Intera -face12
    %kps_match([13 14 17 15 16])=1;
    %
    %Poselet - Faccia (no L_Ear) - face13
    %kps_match([13 14 17 16])=1;
    %
    %Poselet 144 - Busto-Testa Frontale-frontal2
    %kps_match([1 4 13 14 15 16 17 2 5])=1;
    %
    %Poselet 144 - Busto-Testa Frontale senza gomiti-frontal22
    %kps_match([1 4 13 14 15 16 17])=1;
    %
    %Poselet 97 - leg3
    %kps_match([8 11 18 19 12 9])=1;
    %
    %Poselet 86 - frontal4
    %kps_match([2 5 7 10 3 6 1 4])=1;
    %
    %Poselet 86 - frontal41 - Fianchi e ginocchia
    %kps_match([7 10 11 8])=1;
    %
    %%%%%%%%%%%%%%%%%%%%%%%
    while ~valid_patch
        
        % Find an annotation with enough size
        enough_size = false;
        while ~enough_size
            % Get a random file from it
            rand_file = randsample(anns_files,1);
        
            % Get the bounding box and keypoint information from the annotation file
            obj_annotations = get_obj_annotations_from_xml(rand_file.name, config);

            % Set the min height for the poselet patch
            SEED_MIN_HEIGHT_PX = config.SEED_MIN_WIDTH_PX * config.SEED_PATCH_ASPECT_RATIO;

            % Set the max dimensions from the bounding box size
            SEED_MAX_WIDTH_PX  = obj_annotations.bounding_box.width;
            SEED_MAX_HEIGHT_PX = obj_annotations.bounding_box.height;

            if( config.SEED_MIN_WIDTH_PX < obj_annotations.bounding_box.width  && ...
                SEED_MIN_HEIGHT_PX       < obj_annotations.bounding_box.height )
                enough_size = true;
            end
        end
        assert(config.SEED_MIN_WIDTH_PX < SEED_MAX_WIDTH_PX);


        % Get a random size for the seed patch.
        % It cannot exceed the bounding box.
        hw = [0 0];

        ANNOT_ASPECT_RATIO = obj_annotations.bounding_box.height / ...
                             obj_annotations.bounding_box.width;

        if (ANNOT_ASPECT_RATIO >= config.SEED_PATCH_ASPECT_RATIO)
            % Random width:
            hw(2) = config.SEED_MIN_WIDTH_PX + ...
                      rand(1) * (SEED_MAX_WIDTH_PX - config.SEED_MIN_WIDTH_PX);
            % Derived height:
            hw(1) = config.SEED_PATCH_ASPECT_RATIO * hw(2);
        else
            % Random height:
            hw(1) = SEED_MIN_HEIGHT_PX + ...
                        rand(1) * (SEED_MAX_HEIGHT_PX - SEED_MIN_HEIGHT_PX);
            % Derived width:
            hw(2) = hw(1) / config.SEED_PATCH_ASPECT_RATIO;
        end
        assert( hw(2) >= config.SEED_MIN_WIDTH_PX && ...
                hw(2) <= SEED_MAX_WIDTH_PX        && ...
                hw(1) >= SEED_MIN_HEIGHT_PX       && ...
                hw(1) <= SEED_MAX_HEIGHT_PX       );




        % Get a random position for the box, inside the annotation bounding box
        remaining_px = [(SEED_MAX_HEIGHT_PX - hw(1)) ...
                        (SEED_MAX_WIDTH_PX - hw(2))];

        obj_annotations_top_left = [obj_annotations.bounding_box.ymin ...
                                    obj_annotations.bounding_box.xmin];

        patch_top_left = obj_annotations_top_left + (remaining_px .* rand([1 2]));




        % Flag the keypoints inside the poselet patch (flag in in_box variable)
        xmax = patch_top_left(2) + hw(2);
        ymax = patch_top_left(1) + hw(1);

        gt_x = obj_annotations.kp.coords(:,1) > patch_top_left(2);
        lt_x = obj_annotations.kp.coords(:,1) < xmax;
        gt_y = obj_annotations.kp.coords(:,2) > patch_top_left(1);
        lt_y = obj_annotations.kp.coords(:,2) < ymax;

        in_x = gt_x .* lt_x;
        in_y = gt_y .* lt_y;

        in_box = in_x .* in_y;



        % Count the keypoints inside the poselet patch box.
        total_kps = sum(in_box);
        if ( total_kps >= config.SEED_MIN_KEYPOINTS && total_kps<=config.SEED_MAX_KEYPOINTS)                       
            if kps_check==true
                if in_box==kps_match
                    valid_patch = true;
                end
            else
                valid_patch=true;
            end
        end
    end
    %%% contorni patch
    kps_pos=find(in_box);
    A=obj_annotations.kp.coords(kps_pos,1);
    min1=min(A(A>0))-6;
    patch_top_left(2)=min1;
    B=obj_annotations.kp.coords(kps_pos,2);
    min2=min(B(B>0))-6;
    patch_top_left(1)=min2;
    max1=max(A);
    max2=max(B);
    distA=max1-min1;
    distB=max2-min2;
    hw(1)=max(distA,distB)+6;
    hw(2)=hw(1);
    %%%
    poselet_patch.obj_annotations  = obj_annotations;
    poselet_patch.patch.hw  = hw;
    poselet_patch.patch.top_left   = patch_top_left;
    poselet_patch.patch.kp.present = in_box;
end