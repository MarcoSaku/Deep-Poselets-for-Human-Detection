% function [ hyps ] = set_kps_gaussians( poselet_hits,classifiers )
% all_hyps=hypothesis;
% for i=1:length(classifiers)
%     all_hyps(i).mu=classifiers{i}.kps_mu;
%     all_hyps(i).sigma=classifiers{i}.kps_sigma;
%     all_hyps(i).coords_sum=classifiers{i}.coords_sum;
%     all_hyps(i).coords_sum2=classifiers{i}.coords_sum2;
%     all_hyps(i).w_sum=classifiers{i}.w_sum;
%     all_hyps(i).kps_label=classifiers{i}.kps_label;
% end
% 
% hyps = all_hyps(poselet_hits.poselet_id);
% ctr = poselet_hits.bounds(1:2,:) + poselet_hits.bounds(3:4,:)/2;
% for j=1:poselet_hits.size
%    hyps(j) = hyps(j).apply_xform(ctr(:,j)', min(poselet_hits.bounds(3:4,j)));
% end
% end
function [ hyps ] = set_kps_gaussians( poselet_hits,classifiers )
all_hyps=hypothesis;
 for i=1:length(classifiers)
    %kps_label{i}=classifiers{i}.kps_label;
    all_hyps(i).mu=classifiers{i}.kps_mu(:,:);
    all_hyps(i).sigma=classifiers{i}.kps_sigma(:,:);
    all_hyps(i).coords_sum=classifiers{i}.coords_sum(:,:);
    all_hyps(i).coords_sum2=classifiers{i}.coords_sum2(:,:);
    all_hyps(i).w_sum=classifiers{i}.w_sum(:,:);
   % all_hyps(i).kps_label=classifiers{i}.kps_label;
end

hyps = all_hyps(poselet_hits.poselet_id);

ctr = poselet_hits.bounds(1:2,:) + poselet_hits.bounds(3:4,:)/2;
for j=1:poselet_hits.size
    hyps(j) = hyps(j).apply_xform(ctr(:,j)', min(poselet_hits.bounds(3:4,j)));
end
end



% function [ hyps2 ] = set_kps_gaussians( poselet_hits,classifiers )
% all_hyps=hypothesis;
% for i=1:length(classifiers)
%     kps_label{i}=classifiers{i}.kps_label;
%     all_hyps(i).mu=classifiers{i}.kps_mu(kps_label{i},:);
%     all_hyps(i).sigma=classifiers{i}.kps_sigma(kps_label{i},:);
%     all_hyps(i).coords_sum=classifiers{i}.coords_sum(kps_label{i},:);
%     all_hyps(i).coords_sum2=classifiers{i}.coords_sum2(kps_label{i},:);
%     all_hyps(i).w_sum=classifiers{i}.w_sum(kps_label{i},:);
%     all_hyps(i).kps_label=classifiers{i}.kps_label;
% end
% 
% hyps = all_hyps(poselet_hits.poselet_id);
% kps_label=kps_label(poselet_hits.poselet_id);
% ctr = poselet_hits.bounds(1:2,:) + poselet_hits.bounds(3:4,:)/2;
% for j=1:poselet_hits.size
%     hyps(j) = hyps(j).apply_xform(ctr(:,j)', min(poselet_hits.bounds(3:4,j)));
% end
% hyps2=hypothesis;
% for i=1:length(hyps)
%     hyps2(i).mu=ones(20,2)*inf;hyps2(i).sigma=ones(20,2)*inf;hyps2(i).coords_sum=zeros(20,2);hyps2(i).coords_sum2=zeros(20,2);hyps2(i).w_sum=ones(20,2);
%     hyps2(i).mu(kps_label{i},:)=hyps(i).mu;
%     hyps2(i).sigma(kps_label{i},:)=hyps(i).sigma;
%     hyps2(i).coords_sum(kps_label{i},:)=hyps(i).coords_sum;
%     hyps2(i).coords_sum2(kps_label{i},:)=hyps(i).coords_sum2;
%     hyps2(i).w_sum(kps_label{i},:)=hyps(i).w_sum;
%     hyps2(i).rect=hyps(i).rect;
%     hyps2(i).kps_label=hyps(i).kps_label;
% end
% 
% end


