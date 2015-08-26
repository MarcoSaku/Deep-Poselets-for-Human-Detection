function [ patches ] = get_random_patches_from_other_cats(patches_per_cat, config )

    %patches = cell( size(config.PATH_OTHER_XML_ANNOTATIONS)*patches_per_cat );
    patches = cell(1, size(config.PATH_OTHER_XML_ANNOTATIONS,2)*patches_per_cat );
    rand('state',sum(100.*clock));
    for i=1:size(config.PATH_OTHER_XML_ANNOTATIONS,2)
       
        file_listing = dir(config.PATH_OTHER_XML_ANNOTATIONS{i});
        file_listing = file_listing(3:end);
        
        for j=1:patches_per_cat
            patches{(i-1)*patches_per_cat + j} = get_random_patch(file_listing, config.PATH_OTHER_XML_ANNOTATIONS{i}, config);
        end
        
    end

end

