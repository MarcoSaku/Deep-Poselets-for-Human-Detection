function [img] = get_activation_img(act_img,img_name,scale, config)

    % Read whole source image
    img = imread(img_name);
    img=imresize(img,scale);
    % Get xmax and ymax
    xmax=0;
    ymax=0;
    xmax = act_img.x + act_img.height - 1;
    ymax = act_img.y + act_img.width - 1;

    % Crop image so as to leave the patch only
    img = img(	act_img.x:xmax, ...
                act_img.y:ymax, ...
                :);


end