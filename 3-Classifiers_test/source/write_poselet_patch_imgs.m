%creata da me
function write_poselet_patch_imgs(poselet_patches, config)
warning off
%ommited_patches_idx = [];
%invalid_count = 0;
if exist('temp/img_patch', 'dir')
    rmdir('temp/img_patch','s')
    rehash();
end
mkdir('temp/img_patch');
for i=1:size(poselet_patches,2)
    % Get the poselet patch.
    poselet_patch = poselet_patches{i};
    
    % if(poselet_patch.patch.valid & (poselet_patch.patch.hw(1)>=30 | poselet_patch.patch.hw(2)>=30))
    % Get the image.
    img = get_poselet_patch_img(poselet_patch, config);
    % Write the file.
    imwrite(img, ['temp/img_patch/' num2str(i) '.jpg' ]);
    %else
    % ommited_patches_idx(end+1) = i;
    %invalid_count = invalid_count + 1;
    % end
end


%display(['Wrote ' num2str(size(poselet_patches,2) - invalid_count) ' files (' num2str(invalid_count) ' invalid patches ommited).']);
end