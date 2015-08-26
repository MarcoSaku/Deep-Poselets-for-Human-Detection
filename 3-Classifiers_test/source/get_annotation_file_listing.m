function [object_annotations]=get_annotation_file_listing(config)
    % Get (xml) file listing
	object_annotations = dir(config.PATH_XML_ANNOTATIONS);
	% Leave out ./ and ../ :
	object_annotations = object_annotations(3:end);
    
end