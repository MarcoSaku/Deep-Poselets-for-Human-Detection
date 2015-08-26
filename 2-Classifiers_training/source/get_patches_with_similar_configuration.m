function [procr_dists,anns_flags] = get_patches_with_similar_configuration(seed_patch, kp_count, anns_files, config)

    % Find the annotations having at least the keypoints which are inside
    % the seed patch.
    required_kp_flags = seed_patch.patch.kp.present;
    anns_flags = find_annotations_having_keypoints(required_kp_flags, kp_count, config);
    anns_ids = find(anns_flags);
         
    
    % Get the ids of the keypoints inside the seed patch.
    seed_kp_ids = find(required_kp_flags);
    % Get the [x y] coordinates of the keypoints inside the seed patch.
    seed_kp_coords = seed_patch.obj_annotations.kp.coords(seed_kp_ids,(1:2));
       
    
    display(['   Scoring annotations containing these keypoints: ' config.obj_config.Labels{seed_kp_ids}]);
    % Get the procrustes distance and transformations for all of the 
    % annotations retrieved previously.
    procr_dists = zeros([1 size(anns_flags,2)]);
    
    % Filter and set the distance for all the flagged annotations.
    for ann_id=anns_ids
       % Get the annotation.
       ann_filename = anns_files(ann_id).name; 
       ann          = get_obj_annotations_from_xml(ann_filename, config);
       
       % Get the [x y] coords for the required keypoints.
       ann_kp_coords = ann.kp.coords(seed_kp_ids,(1:2));
       
       % Get the procrustes distance and transform for the current
       % annotation.
       % TODO: enable reflection. A renaming of keypoints is needed.
       [proc_dist, ~, transform] = procrustes(seed_kp_coords, ann_kp_coords, ...
                                                    'reflection', false);
                                                
       % Get the rotation angle in radians.
       rotation_angle = atan2( transform.T(1,2),transform.T(1,1) );
       
       if ( proc_dist > config.PROCRUSTES_DIST_THRESH )
           % If the distance exceeds the threshold, delete the flag for the
           % annotation.
           anns_flags(ann_id) = 0;
       
       % TODO: compute the visibility distance (...) and compare again.
       
       elseif( rotation_angle > config.MIN_ROT_THRESH )
           % If transformation exceeds rotation thresh, delete the flag.
           % Assumes no reflection.
           anns_flags(ann_id) = 0;
           
       % TODO: implement for reflection.
       
       else
           % Otherwise, store the values.
           procr_dists(ann_id) = proc_dist;
       end
       
       
       
    end
    
    
    
    
end