function [ ] = show_boxes( img,boxes,scores_clusters )
figHandle=figure('name','My Boxes');
fprintf('\nPress uparrow to next box\nPress downarrow to previous box\nPress esc to close\n')
setappdata(0, 'varName', 1);
set(figHandle, 'KeyPressFcn',@(fig_obj , eventDat) myFunction(fig_obj, eventDat,img,boxes,scores_clusters));

plot_boxes(img,boxes,scores_clusters);
%for i=1:size(boxes,1)

%figure;imshow(img(y1:y2,x1:x2,:))
%end
end

function myFunction(fig_obj, eventDat,img,boxes,scores_clusters)

key = eventDat.Key;
if strcmp(key,'uparrow')
    i=getappdata(0, 'varName');
    if i<size(boxes,1)
        setappdata(0, 'varName', i+1);
        plot_boxes(img,boxes,scores_clusters);
    end
elseif strcmp(key,'downarrow')
    i=getappdata(0, 'varName');
    if i>1
        setappdata(0, 'varName', i-1);
        plot_boxes(img,boxes,scores_clusters)
    end
elseif strcmp(key,'escape')
    close(fig_obj);
else
    %plot_boxes(img,boxes,i,scores_clusters)
end
end

function plot_boxes(img,boxes,scores_clusters)
i=getappdata(0, 'varName');

clf;
x1=boxes(i,1);x2=boxes(i,3);
y1=boxes(i,2);y2=boxes(i,4);
% x1=mean(boxes(:,1));x2=mean(boxes(:,3));
% y1=mean(boxes(:,2));y2=mean(boxes(:,4));
% Show image
imshow(img);

% Plot on the same image (do not clear when running plot)
hold on;

% Draw bounds
rectangle(	'Position', ...
    [x1      ...
    y1      ...
    x2-x1     ...
    y2-y1],  ...
    'EdgeColor', 'blue','LineWidth',2,'LineStyle','--');
title(sprintf('Box %s/%s   Score=%s',num2str(i),num2str(size(boxes,1)),num2str(scores_clusters(i))));

end