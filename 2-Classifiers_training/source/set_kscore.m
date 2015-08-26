%Set the minimum score of classifier to classify a sample as positive
function [ classifiers ] = set_kscore( classifiers,num_classifiers,config )

for i=1:num_classifiers
    display(['Setting kscore classifier ' num2str(i)])
    n_train=400;
    [deep256_vectors_pos]=get_deep_vectors(classifiers{i}.poselet_patches(1:n_train),config);
    [label,svm_score] = svmclassify(classifiers{i}.svm,deep256_vectors_pos);
    svm_score=sort(svm_score,'ascend');
    if isempty(svm_score(svm_score<0))
        classifiers{i}=[];
        classifiers = classifiers(~cellfun('isempty',classifiers));

    else
    classifiers{i}.kscores=svm_score(svm_score<0);    
    classifiers{i}.ksc= classifiers{i}.kscores(floor((length(classifiers{i}.kscores)*90)/100));
end
end
