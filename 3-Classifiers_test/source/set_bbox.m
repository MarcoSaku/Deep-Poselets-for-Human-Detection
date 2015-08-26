function bbox_clust=set_bbox(poselet_hits,classifiers,cluster_labels,img)
ctr = poselet_hits.bounds(1:2,:) + poselet_hits.bounds(3:4,:)/2;ctr=ctr';

for i=1:max(cluster_labels)
    c=find(cluster_labels==i)';
    z=0;bboxes=[];
    for j=c
        scale=min(poselet_hits.bounds(3:4,j));
        bbox=classifiers{poselet_hits.poselet_id(j)}.bbox;
        bbox=bbox*scale;
        bbox(1)=bbox(1)+ctr(j,1);
        bbox(2)=bbox(2)+ctr(j,2);
        bbox(3)=bbox(3)+ctr(j,1);
        bbox(4)=bbox(4)+ctr(j,2);
        z=z+1;
        bboxes(z,:)=bbox;
    end
    w=poselet_hits.score(c);w=repmat(w,[1 4]);
    if length(c)>1
        bbox_clust(i,:)=double(wmean(bboxes,w));
        
    else
        bbox_clust(i,:)=bboxes;
    end
    if bbox_clust(i,1)<1
        bbox_clust(i,1)=1;
    end
    if bbox_clust(i,2)<1
        bbox_clust(i,2)=1;
    end
    if bbox_clust(i,3)>size(img,2)
        bbox_clust(i,3)=size(img,2)-1;
    end
    if bbox_clust(i,4)>size(img,1)
        bbox_clust(i,4)=size(img,1)-1;;
    end
    
end
end

