function [ class ] = train_deep_classifier(poselet_patches,config )
    %get 256d feature vector from deep-net for positive batches
    [deep256_vectors_pos]=get_deep_vectors(poselet_patches,config);
    %get patches from other categories (background)
    %neg_patch_per_cat=floor((length(poselet_patches)/12))+6;
    neg_patch_per_cat=80;
    neg_patches = get_random_patches_from_other_cats(neg_patch_per_cat, config);
    %get 256d-array from deep-net for negative batches
    [deep256_vectors_neg]=get_deep_vectors(neg_patches,config);
    %Labels
    Y=[true(1,size(deep256_vectors_pos,1)) false(1,size(deep256_vectors_neg,1))]';
    %Training Data: each row is a sample
    X=[deep256_vectors_pos;deep256_vectors_neg];

    %train the svm
    options = optimset('maxiter',1000000000);
    svmStruct = svmtrain(X,Y,'Options',options);
    %save informations in class    
    class.svm = svmStruct;
    class.neg_patches_deep256=deep256_vectors_neg;   
end