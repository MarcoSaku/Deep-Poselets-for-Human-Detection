function [ deep256_vectors,retrain_svm ] = collect_false_positive( classifier,config )
    retrain_svm=true;
   % for j=1:5
    neg_patches = get_random_patches_from_other_cats(80, config);

    [deep256_vectors_neg]=get_deep_vectors(neg_patches,config);

    label = svmclassify(classifier.svm,deep256_vectors_neg);

    deep256_vectors=deep256_vectors_neg(find(label==1),:);
    if length(find(label))==0
        retrain_svm=false;
    end
    %end
end
