function [ classifier ] = retrain_deep_classifier(classifier,n_train,config )
    [deep256_vectors_pos]=get_deep_vectors(classifier.poselet_patches(1:n_train),config);
    %get patches from other categories (background)
    %neg_patches = get_random_patches_from_other_cats(config.NEGATIVE_PATCHES_PER_CATEGORY, config);
    
    
    [deep256_vectors_neg1,retrain_svm]=collect_false_positive(classifier,config);

    deep256_vectors_neg=[classifier.neg_patches_deep256;deep256_vectors_neg1];
    %train the svm
    if  retrain_svm==true
        Y=[true(1,size(deep256_vectors_pos,1)) false(1,size(deep256_vectors_neg,1))]';
        X=[deep256_vectors_pos;deep256_vectors_neg];
        options = optimset('maxiter',1000000000);
        svm = svmtrain(X,Y,'Options',options);
        %svm = train_svm(deep256_vectors_pos, deep256_vectors_neg, config);
        %save informations in poselet
        classifier.svm = svm;
    end
end