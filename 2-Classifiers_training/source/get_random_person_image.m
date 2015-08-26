function [ img_name ] = get_random_person_image( anns_files,config )
rand_file=randsample(anns_files,1);
obj_annotations = get_obj_annotations_from_xml(rand_file.name, config);
img_name=[config.PATH_JPEGIMAGES obj_annotations.image_filename '.jpg'];


end

