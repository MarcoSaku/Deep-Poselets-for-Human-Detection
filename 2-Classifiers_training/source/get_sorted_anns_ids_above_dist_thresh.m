function [sorted_valid_dists_idx] = get_sorted_anns_ids_above_dist_thresh(procr_dists, anns_flags, config)
    [~, sorted_dists_idx] = sort(procr_dists);
    
    sorted_anns_flags = anns_flags(sorted_dists_idx);
    
    sorted_valid_dists_idx = sorted_dists_idx(find(sorted_anns_flags));
end