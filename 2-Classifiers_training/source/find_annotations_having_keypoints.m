function [ annotations_flags ] = find_annotations_having_keypoints(required_kp_flags, kp_count, config)
% find_annotations_having_keypoints Gets the ids for the annotations having
% the given required keypoints.

    % Create a submatrix of kp_count, storing only the keypoints of
    % interest.
    kp_sub = kp_count( find(required_kp_flags), :);
    
    % Create a vector where positions with 1 will indicate the annotation
    % corresponding to that position has all the required keypoints.
    annotations_flags = zeros([1 size(kp_count,2)]);
    % Update the vector.
    for i=1:size(kp_sub,2)
        annotations_flags(1, i) = all(kp_sub(:,i));
    end
end

