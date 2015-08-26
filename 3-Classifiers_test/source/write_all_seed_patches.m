function write_all_seed_patches( classifiers,config )
warning off

if exist('img_seed_patch', 'dir')
    rmdir('img_seed_patch','s')
end
mkdir('img_seed_patch');
for i=1:length(classifiers)
    seed_patch=classifiers{i}.seed_patch;
    img = get_poselet_patch_img(seed_patch, config);
    % Write the file.
    imwrite(img, ['img_seed_patch/' num2str(i) '.jpg' ]);
end

end

