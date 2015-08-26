function [img] = show_image_with_annotations(obj_annotations, config)

    % Read full image
    img = imread([config.PATH_JPEGIMAGES obj_annotations.image_filename '.jpg']);

    % Show image
    imshow(img);

    % Plot on the same image (do not clear when running plot)
    hold on;

    % Draw bounds
    rectangle(	'Position', [obj_annotations.bounding_box.xmin      ...
                             obj_annotations.bounding_box.ymin      ...
                             obj_annotations.bounding_box.width     ...
                             obj_annotations.bounding_box.height],  ...
                    'EdgeColor', 'green');

    % Draw keypoints as circles
    for i=1:config.obj_config.NumLabels
        if ( obj_annotations.kp.present(i) )
            color = 'red';
            if ~obj_annotations.kp.visible(i)
                color = 'yellow';
            end
            plot(obj_annotations.kp.coords(i,1), obj_annotations.kp.coords(i,2), 'o', 'MarkerSize', 3, 'Color', color);
        end
    end

    % Allow clearing the image later
    hold off;

end