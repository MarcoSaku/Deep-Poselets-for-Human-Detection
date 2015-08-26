function poselets=get_poselets(num_classifiers,anns_files,kp_count,config)
rand('twister', sum(100*clock));
display('Collect poselet-patches from random seed');
for i=1:num_classifiers
    display(['Classifier ' num2str(i)]);
    poselets{i}.seed_patch = get_random_seed_patch(anns_files, config,[7 10 11 8]);
    %Given the seed patch, get all the similar patches in the training set
    poselets{i}.poselet_patches = get_poselet_patches(poselets{i}.seed_patch, kp_count, anns_files, config);
    %pos_patches=get_poselet_patches(poselets{i}.seed_patch, kp_count, anns_files, config);
    display(['# poselets ' num2str(length(poselets{i}.poselet_patches))]);
end

%Remove the poselet-type with less than 750 samples
for i=1:length(poselets)
    if length(poselets{i}.poselet_patches)<500
        poselets{i}=[];
    end
end
poselets = poselets(~cellfun('isempty',poselets));



