function [poselet_patches] = get_poselet_patches(seed_patch, kp_count, anns_files, config)


    % Get the procr. distance and flags indicating which patches have
    % similar spatial configuration to that of the seed patch.
    [procr_dists,anns_flags] = get_patches_with_similar_configuration(seed_patch, kp_count, anns_files, config);

    % Get an array containing the annotation ids of those which have
    % similar configuration. Sorted in ascending order (first is better).
    sorted_valid_dists_idx = get_sorted_anns_ids_above_dist_thresh(procr_dists, anns_flags, config);



    % Set a limit for the patches to be computed.
    annotation_limit = min( size(sorted_valid_dists_idx,2), config.NEAREST_TRAINING_EXAMPLES );

    % Array for storing the poselet patches (preallocate memory).
    %poselet_patches = cell(1,annotation_limit);
    %display(['Getting ' annotation_limit ' poselet patches.']);

    % Get the poselet patches.
    i=1;j=0;z=1;
    while (i<=annotation_limit) && (z<=length(sorted_valid_dists_idx))
        z=z+j;
        pos_valid=false;j=0;
        while (pos_valid==false) && (z+j)<=length(sorted_valid_dists_idx)
            ann_id=sorted_valid_dists_idx(z+j);
            [pos_patch,pos_valid] = get_poselet_patch(ann_id, anns_files, seed_patch, config);
            if pos_valid==true
                poselet_patches{i}=pos_patch;
            end
            j=j+1;
            
        end
        i=i+1;
    end

end