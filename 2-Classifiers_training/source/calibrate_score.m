%Get the probabilities of success of classifiers
function [ classifiers ] = calibrate_score( classifiers,config )
num_classifiers=length(classifiers);
acts_labels=cell(1,num_classifiers);
acts_scores=cell(1,num_classifiers);

for i=1:num_classifiers
    acts_label=[];acts_score=[];    
    p=1;
    n_train=floor((length(classifiers{i}.poselet_patches)*95)/100);
    k=n_train+1;
    classifiers{i}.calibration.k=k;
    disp ''
    while k<=n_train+1+10 && k<=length(classifiers{i}.poselet_patches)
        display(['Calibrate Classifier ' num2str(i) ' image ' num2str(p)])
        img_name=[config.PATH_JPEGIMAGES classifiers{i}.poselet_patches{k}.obj_annotations.image_filename '.jpg'];
        img = imread( img_name);
        %[img,img_name]=show_poselet_patch_with_annotations(poselets_hog{i}.poselet_patches{k}, config);
        [activations{i}{p}]=detect_deep_poselet_in_image_1svm(img,img_name, classifiers{i}, config);
        [acts_lab,acts_sc] = label_activations(activations{i}{p},classifiers{i}.poselet_patches{k},config);
        acts_label=[acts_label acts_lab];
        acts_score=[acts_score acts_sc];
       
        classifiers{i}.calibration.acts_label_1m{i}{p}=acts_lab;
        classifiers{i}.calibration.acts_score_1m{i}{p}=acts_sc;
        p=p+1;
        k=k+1;
    end
    classifiers{i}.calibration.acts_labels=acts_label;
    classifiers{i}.calibration.acts_scores=acts_score;
end


for z=1:length(classifiers)
    classifiers{z}.calibration.acts_label_1m = classifiers{z}.calibration.acts_label_1m(~cellfun('isempty',classifiers{z}.calibration.acts_label_1m));
    classifiers{z}.calibration.acts_score_1m = classifiers{z}.calibration.acts_score_1m(~cellfun('isempty',classifiers{z}.calibration.acts_score_1m));
end

%Train a linear regressor to convert scores to probabilities
probs=zeros(1,length(classifiers));
for k=1:length(classifiers)
    [X,j]=sort(abs(classifiers{k}.calibration.acts_scores'),'ascend');
        if ~isempty(X)
            Y=classifiers{k}.calibration.acts_labels(j)';
            B = glmfit(X,Y , 'binomial', 'link', 'logit');
            Z = B(1) + X * (B(2));
            Z = Logistic(B(1) + X * (B(2)));
            classifiers{k}.calibration.probability=mean(Z);
            probs(k)=mean(Z);
        end
end
[X,j]=sort(probs,'descend'); 
classifiers=classifiers(j);
 
end

