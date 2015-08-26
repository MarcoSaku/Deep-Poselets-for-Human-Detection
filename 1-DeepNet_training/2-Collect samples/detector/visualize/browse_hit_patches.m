function ch=browse_hit_patches(all_hits,im,visualize_hit_fn,params)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Displays the hits in all_hits in a grid sorted by score and allows
%%% browsing
%%% 
%%% PARAMETERS:
%%%    all_hits:     A hit_list of hits, such as the predicted bounds or
%%%                  poselet activations
%%%
%%% OPTIONAL PARAMETERS:
%%%    im:           If the test images are not enrolled (i.e. 
%%%                  do not appear in the global 'im' variable, you will
%%%                  need to create an im for them. See the file
%%%                  demo_poselets.m for how to do this.
%%%    visualize_hit_fn: 
%%%                  Function to call when zooming on a hit
%%%
%%%    params:       Extra parameters, such as the list of detected
%%%                  poselets, torsos (for the person category), poselet
%%%                  masks and example poselets to help visualization. See
%%%                  demo_poselets.m for more.
%%%
%%% Copyright (C) 2009, Lubomir Bourdev and Jitendra Malik.
%%% This code is distributed with a non-commercial research license.
%%% Please see the license file license.txt included in the source directory.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('im','var')
   global im; 
end    

if ~exist('params','var')
   params=[]; 
end


MAX_THUMBS = 60;
[srt,srtd]=sort(all_hits.score,'descend');

cur_idx = 1;
refresh=true;
while 1
    if refresh
        cur_hit_span = srtd(cur_idx:min(cur_idx+MAX_THUMBS-1,all_hits.size));
        patches = hits2patches(all_hits.select(cur_hit_span),[64 96],'bilinear',im);
        [h,dims]=display_patches(patches);
        title(sprintf('hits %d - %d of %d',cur_idx,min(cur_idx+MAX_THUMBS-1,all_hits.size),all_hits.size));
        refresh=false;
    end
    [idx,ch] = get_grid_selection([size(patches,2) size(patches,1)],dims,MAX_THUMBS);

    switch ch
        case 27 % ESC
            return;
        case 29 % ->
            if cur_hit_span(end)<all_hits.size
                cur_idx=cur_idx+MAX_THUMBS;
                refresh=true;
            end
        case 28 % <-
            if cur_hit_span(1)>1
                cur_idx=cur_idx-MAX_THUMBS;
                refresh=true;
            end
        case 'g'
            answer = str2double(inputdlg('Enter hit index:'));
            if ~isempty(answer)
                answer = round(answer);
                if answer>0
                    cur_idx=max(1,min(all_hits.size,answer));
                    refresh=true;
                end
            end        
        otherwise
            if ch<=3
                if ~isnan(idx)
                    img=imread(image_file(all_hits.image_id(cur_hit_span(idx)),im));
                    if exist('visualize_hit_fn','var') && ~isempty(visualize_hit_fn)
                        visualize_hit_fn(all_hits.select(cur_hit_span(idx)),img,params);
                    else
                       cf=gcf;
                       figure(3); clf;
                       imshow(img);
                       all_hits.select(cur_hit_span(idx)).draw_bounds;
                       figure(cf);
                    end
                end
            else
               return; 
            end
    end
end % while 1

end



