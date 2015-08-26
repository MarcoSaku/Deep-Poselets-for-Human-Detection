%MAIN SCRIPT TO TRAIN POSELET-CLASSIFIERS
warning off;
global config
config=init;
%%Load annotations from file if it is present
load anns;
% anns_files=dir(config.PATH_XML_ANNOTATIONS);
% anns_files([anns_files.isdir]) = [];
% display 'Counting Keypoints'
% kp_count=count_keypoint_occurrences(config);

num_classifiers=3; %number of classifiers to create
%Get poselets from Random Seed
poselets=get_poselets(num_classifiers,anns_files,kp_count,config);
num_classifiers=length(poselets);
%Train the classifiers for the first time
classifiers=first_train_classifiers(poselets,num_classifiers,anns_files,kp_count,config);
%Collect false positive and train the classifiers for the second time
classifiers=second_train_classifiers(classifiers,num_classifiers,config );
%Set the minimum score of classifier to classify a sample as positive

classifiers=set_kscore(classifiers,length(classifiers),config);
%classifiers2=calibrate_score(classifiers2,num_classifiers,config)
for i=1:length(classifiers)
    classifiers{i}= get_keypoints_distribution(classifiers{i},config);
end

for i=1:length(classifiers)
    classifiers{i}=get_bboxes( classifiers{i},config );
end
%Get confusion matrices and accuracy for each classifier
classifiers=classifier_accuracy(classifiers,config);


