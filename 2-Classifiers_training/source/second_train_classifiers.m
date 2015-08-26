%Collect false positives and retrain the classifiers
function [ classifiers ] = second_train_classifiers( classifiers,num_classifiers,config )
    for i=1:num_classifiers
        disp ('')
        display(['Retraining classifier ' num2str(i) '/' num2str(num_classifiers)])
        n_train=400;
        class=retrain_deep_classifier(classifiers{i},n_train, config);    
        classifiers{i}=class;
    end
end
