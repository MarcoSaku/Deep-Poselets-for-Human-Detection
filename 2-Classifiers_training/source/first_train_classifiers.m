%First train of poselet-classifiers
function [ classifiers ] = first_train_classifiers( poselets,num_classifiers,anns_files,kp_count,config)
i=1;
display('First classifier training');
while i<=num_classifiers    
    length_pos=length(poselets{i}.poselet_patches);
    display(['Training classifier ' num2str(i) '/' num2str(num_classifiers) ' #poselets ' num2str(length_pos)])
    n_train=400;
        
    class=train_deep_classifier(poselets{i}.poselet_patches(1:n_train), config);
    class.poselet_patches=poselets{i}.poselet_patches(1:length_pos);
    class.seed_patch=poselets{i}.seed_patch;
    classifiers{i}=class;
    i=i+1;
    %     end
end


end
