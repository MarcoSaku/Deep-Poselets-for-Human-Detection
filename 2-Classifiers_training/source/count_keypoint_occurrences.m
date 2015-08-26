function [kp_count]=count_keypoint_occurrences(config)
    
    global annotation_file_listing
    annotation_file_listing = get_annotation_file_listing(config);
    
    % Iterate over (a subset of) the annotations
    annotations_to_check_idxs = 1:size(annotation_file_listing,1);
    
    % Initialize keypoint counts to zero
    kp_count = zeros([config.obj_config.NumLabels size(annotations_to_check_idxs,2)]);
    
    for i=1:size(kp_count,2)
        display(i)
        % Get a file to check
        annotation_file = annotation_file_listing(annotations_to_check_idxs(i));
        
        % Get the internal xml representation for the chosen xml file
        xdoc = xmlread([config.PATH_XML_ANNOTATIONS annotation_file.name]);
        
        % Get the keypoint xnodes
        xkeypoints = xdoc.getElementsByTagName('keypoint');
        
        % Read all keypoint nodes for the current annotation file
        j = 0; % Current keypoint index, starts from 0 because it is a java object.
        while true

            if isempty(xkeypoints.item(j))
                break;
            end

            item = xkeypoints.item(j);
            kp_name = char(item.getAttribute('name'));
            
            % Get the keypoint id from its name
            kp_id = config.obj_config.(kp_name);
            
            % Turn the counter to 1 for this keypoint, for the current
            % annotation.
            kp_count(kp_id, i) = 1;
            
            % Increment the current keypoint index.
            j = j + 1;
        end
        
    end


end