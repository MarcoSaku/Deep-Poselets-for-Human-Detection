%Classify positive and negative patches and get the confusion matrix
function [ classifiers ] = classifier_accuracy( classifiers,config )
display('Calculating the confusion matrices');
n_train=400;
neg_patches = get_random_patches_from_other_cats(50, config);
[deep256_vectors_neg]=get_deep_vectors(neg_patches,config);

for i=1:length(classifiers)
    display(['Confusion matrix for classifier ' num2str(i)])
    [deep256_vectors_pos]=get_deep_vectors(classifiers{i}.poselet_patches(n_train:end),config);    
    [label,svm_score] = svmclassify(classifiers{i}.svm,deep256_vectors_pos);
    true_positive=length(find(label==1));
    false_negative=length(find(label==0));
    
    [label,svm_score] = svmclassify(classifiers{i}.svm,deep256_vectors_neg);
    false_positive=length(find(label==1));
    true_negative=length(find(label==0));
    
    classifiers{i}.conf_mat=[true_positive false_negative;false_positive true_negative];
    classifiers{i}.accuracy=(classifiers{i}.conf_mat(1,1)+classifiers{i}.conf_mat(2,2))/sum(classifiers{i}.conf_mat(:))*10;
end
end



