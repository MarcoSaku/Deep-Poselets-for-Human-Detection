function [obj_annotations]=get_obj_annotations_from_xml(filename, config)
    % Get the internal xml representation for the chosen xml file
	xmldoc = xmlread([config.PATH_XML_ANNOTATIONS filename]);

    % Get needed XML nodes
    ximage = xmldoc.getElementsByTagName('image');
    xbounds = xmldoc.getElementsByTagName('visible_bounds');
    xkeypoints = xmldoc.getElementsByTagName('keypoint');


    % Save filename as string
    obj_annotations.xml_filename = filename;
    % Save image name as string
    obj_annotations.image_filename = char(ximage.item(0).getFirstChild.getData);

    % Save bounding box information as doubles
    obj_annotations.bounding_box.xmin  = str2double(xbounds.item(0).getAttribute('xmin'));
    obj_annotations.bounding_box.ymin  = str2double(xbounds.item(0).getAttribute('ymin'));
    obj_annotations.bounding_box.width = str2double(xbounds.item(0).getAttribute('width'));
    obj_annotations.bounding_box.height= str2double(xbounds.item(0).getAttribute('height'));

    % Initialize keypoint counts to zero (column vector)
    obj_annotations.kp.present = zeros([config.obj_config.NumLabels 1]);
    obj_annotations.kp.visible = zeros([config.obj_config.NumLabels 1]);
    obj_annotations.kp.coords  = zeros([config.obj_config.NumLabels 3]);


    i = 0;
    % Read all keypoint nodes
    while true
        if isempty(xkeypoints.item(i))
            break;
        end 

        item = xkeypoints.item(i);

        % Get the keypoint id from its name
        kp_name = char(item.getAttribute('name'));
        kp_id   = config.obj_config.(kp_name);

        % Set is as present
        obj_annotations.kp.present(kp_id) = 1;

        % Set its visibility
        obj_annotations.kp.visible(kp_id) = str2double(item.getAttribute('visible'));

        % Set its coordinates
        obj_annotations.kp.coords(kp_id, 1) = str2double(item.getAttribute('x'));
        obj_annotations.kp.coords(kp_id, 2) = str2double(item.getAttribute('y'));
        obj_annotations.kp.coords(kp_id, 3) = str2double(item.getAttribute('z'));

        i = i + 1;
    end

end