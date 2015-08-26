function [cluster_id] = final_cluster( clusters )
dist_thresh=0.2;
clusters.id=[1:clusters.size]';
if clusters.size==0
    cluster_id=[];
    return;
end

% cluster the hypotheses in a greedy fashion
hyp_clusters{1,1}.hit_id(1)=clusters.id(1);
hyp_clusters{1,1}.cluster_id(1)=1;


for j=2:clusters.size
    % decide whether to place j into an existing cluster or
    % start a new one
    dst=nan(length(hyp_clusters),1);
    for k=1:length(hyp_clusters)
        % check with at most NUM hits
        MAX_HITS_TO_CHECK = 7;
        if length(hyp_clusters{k}.hit_id)<MAX_HITS_TO_CHECK
            hits_to_check=1:length(hyp_clusters{k}.hit_id);
        else
            hits_to_check=round(linspace(1,length(hyp_clusters{k}.hit_id),MAX_HITS_TO_CHECK));
        end

        %dst_m=inf(1,length(hits_to_check));
        for m=1:length(hits_to_check)
           % hit_m=hyp_clusters{k}.hit_id(hits_to_check(m));

            %if isempty(dist_fn)
                % Slighly faster because avoids calls to hits_for_img.select
            %dst_m(m) = hyps_for_img(hyp_clusters{k}.hit_id(hits_to_check(m))).distance(hyps_for_img(j),config);
           
           dst_m(m)=bounds_overlap(clusters.bounds(:,hyp_clusters{k}.hit_id(hits_to_check(m))),clusters.bounds(:,j));
           
           % else
               % dst_m(m) = dist_fn(hyps_for_img([hit_m j]),hits_for_img.select([hit_m j]));
           % end

            if isinf(dst_m(m))
                break;
            end
        end
        dst(k)=max(dst_m);
%         if any(isinf(dst_m))
%             dst(k)=inf;
%         else
%             scores = hits_for_img.score(hyp_clusters{k}.hit_id(hits_to_check));
%             dst(k)=(dst_m*scores)/sum(scores);
%         end
    end
    
    
    if max(dst)>=dist_thresh
        mrg=find(dst==max(dst),1);
        %mrg=find(dst>=dist_thresh);
        cluster_id = clusters.id(j);
        %Add the activation only if the cluster doesn't already have an activation of the same poselet type
        %if ~ismember(poselet_id,hyp_clusters{mrg}.poselet_id)
            %hyp_clusters{mrg}.hit_id(end+1)=poselet_id;
            for v=1:length(mrg)
                hyp_clusters{mrg(v)}.hit_id(end+1)=j;
            end
        %end
    elseif length(hyp_clusters)<100
        % start a new cluster
        hyp_clusters{end+1,1}.hit_id(1)=clusters.id(j);
        hyp_clusters{end,1}.cluster_id(1)=j;
    end
    
end

% Convert from image index to global poselet index
cluster_id = zeros(clusters.size,1);
for k=1:length(hyp_clusters)
    cluster_id(hyp_clusters{k}.hit_id) = k;
end

end


function draw_hyp_onecolor(merge_hyps,hit,color)
global K;
keypts_range=[K.L_Hip K.R_Hip K.L_Shoulder K.R_Shoulder];
merge_hyps.draw(keypts_range,repmat(color,length(keypts_range),1),'-',1);
rectangle('position',[merge_hyps.rect(1:2) merge_hyps.rect(3:4)-merge_hyps.rect(1:2)],'edgecolor',color,'linestyle',':');
hit.draw_bounds(color);
end

function draw_cluster(hits,hyps, keypts)
global K;
MAX_HITS = 100;
if hits.size>MAX_HITS
    hits = hits.select(1:MAX_HITS);
    hyps = hyps(1:MAX_HITS);
end

kp_mu=reshape([hyps(:).mu],K.NumPrimaryKeypoints,2,[]);

colors = jet(length(keypts));
for k=1:length(keypts)
    num_samples=min(10,size(kp_mu,3));
    scatter(kp_mu(keypts(k),1,1:num_samples),kp_mu(keypts(k),2,1:num_samples),'.','MarkerEdgeColor',colors(k,:));
end
%    min_pt = [min(min(kp_mu(keypts,1,:))) min(min(kp_mu(keypts,2,:)))];
%    max_pt = [max(max(kp_mu(keypts,1,:))) max(max(kp_mu(keypts,2,:)))];
%    rectangle('position',[min_pt max_pt-min_pt],'edgecolor','r');
%    hits.draw_bounds;

end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Code copied from op_cluster2bounds to get get_bounds_predictions
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Predict object bounds from poselet bounds (this is copied from
%%%  poselet_detection folder)
%%%%%%%%%%%%%%%%%%%%%%%%%%

function [bounds,angle] = predict_bounds(poselet_bounds, poselet_angle, poselet2bounds)
    % Given part hits generates a list of torso predictions for each image

    scale = min(poselet_bounds(3:4)); % The poselet normalized coords go from -0.5 to 0.5 along the shorter dimension
    image2poselet_ctr = poselet_bounds(1:2)+poselet_bounds(3:4)/2;
    rad_angle = poselet_angle*pi/180;
    poselet_rot = [cos(rad_angle) sin(rad_angle); -sin(rad_angle) cos(rad_angle)];

    scaled_bounds = poselet2bounds.obj_bounds * scale;
    poselet2bounds_ctr = scaled_bounds(1:2) + scaled_bounds(3:4)/2;
    bounds_dims = scaled_bounds(3:4);

    image2bounds_ctr = image2poselet_ctr + poselet2bounds_ctr*poselet_rot;
    bounds = [image2bounds_ctr - bounds_dims/2 bounds_dims];
    angle = poselet_angle;
end


function [torso_bounds,torso_angle,torso_score]=compute_torso_bounds(hits_for_torso,hyps_for_torso)
    global K;
    % Get the expected location of the hips and shoulders to construct the torso bounds
    torso_kpts = [K.L_Shoulder K.R_Shoulder K.L_Hip K.R_Hip];

    kp_mu=reshape([hyps_for_torso(:).mu],size(hyps_for_torso(1).mu,1),2,[]);
    torso_score=sum(hits_for_torso.score);

    if 1
        for kp=1:length(torso_kpts)
            coords = reshape([kp_mu(torso_kpts(kp),1,:) kp_mu(torso_kpts(kp),2,:)],2,[]);
            mean_coords(kp,:) = sum([hits_for_torso.score hits_for_torso.score].*coords',1)/torso_score;
        end
    else
        kp_var=reshape([hyps_for_torso(:).sigma],size(hyps_for_torso(1).sigma,1),2,[]);
        for kp=1:length(torso_kpts)
              coords = shiftdim([kp_mu(torso_kpts(kp),1,:) kp_mu(torso_kpts(kp),2,:)],1)';
              var    = shiftdim([kp_var(torso_kpts(kp),1,:) kp_var(torso_kpts(kp),2,:)],1)';
              mean_coords(kp,:) =get_mode(coords,var,hits_for_torso.score);
        end
    end

    [torso_bounds,torso_angle] = torso_bounds_from_keypoints(mean_coords);
end


function md = get_mode(x,sigma,w)
%  x = [x; x+var; x-var];
%  w = [w; w/2; w/2];
%  md = (x'*w)/sum(w);

   w = w./sigma;
   md = (x'*w)/sum(w);
   return;


  [modes,mode_w] = meanshift(x, sigma.^2, w);
  md=modes(find(mode_w==max(mode_w),1),:);
end



function [modes,mode_w,mode_of_x] = meanshift(at, sigma2, w)

x = at;
[N,D] = size(x);

if N==1
   modes = at;
   mode_w = w;
   mode_of_x = 1;
   return;
end

THRESH = 1e-5;
MODE_EPS = 20;
MAX_ITERS = 100;

for iter=1:MAX_ITERS
    for i=1:N
       xdiff = (x - repmat(x(i,:),N,1))./sigma2;
       wt = w.*exp(-sum(xdiff.^2,2) / 2)./sqrt(prod(sigma2,2));

       sumw = sum(wt);
       if sumw>0
           nvalue(i,:) = sum(repmat(wt,1,D).*x,1)./sumw;
       else
           nvalue(i,:) = x(i,:);
       end
    end

    shift_sqrd_dist = sum((x - nvalue).^2,2);

    if mean(shift_sqrd_dist)<THRESH
        break;
    end

    x = nvalue;
end


[md,foo,mode_of_x] = unique(round(x*MODE_EPS),'rows');
modes = md./MODE_EPS;

% compute the weight of each mode
for i=1:size(modes,1)
    xdiff = (at - repmat(modes(i,:),N,1))./sigma2;
    dist = exp(-sum(xdiff.^2,2) / 2)./sqrt(prod(sigma2,2));
    mode_w(i,1) = w' * dist;
end
end






