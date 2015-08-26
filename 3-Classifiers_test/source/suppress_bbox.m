function [ keep ] = suppress_bbox( bbox_clust )
thresh=0.5;
i=1;
keep=1:size(bbox_clust,1);
if size(bbox_clust,1)>1
    while i<(length(bbox_clust)-1)
        overlap=bounds_overlap(bbox_clust(i,:)',bbox_clust(i+1:end,:)');
        bbox_clust(i+find(overlap>thresh),:)=[];

        keep(i+find(overlap>thresh))=[];
        i=i+1;
    end
end



end

