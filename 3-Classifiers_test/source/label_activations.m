function [label_acts,score_acts] = label_activations(activations,seed_patch,config)

label_acts=false(1,activations.size);
score_acts=zeros(1,activations.size);
% Creazione immagine intera scalata
img_name=activations.file_name;
img = imread( img_name);

bbox_seed=[fliplr(seed_patch.patch.top_left) fliplr(seed_patch.patch.hw)]';
overlap=bounds_overlap_min(bbox_seed,activations.bounds);
score_acts=activations.score';
label_acts(find(overlap>0.5))=true;
end
