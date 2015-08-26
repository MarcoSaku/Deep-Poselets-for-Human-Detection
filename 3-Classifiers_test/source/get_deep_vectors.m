%mia function
function [deep256_vectors]=get_deep_vectors(poselet_patches,config)
    % write patch images in a directory
    write_poselet_patch_imgs(poselet_patches,config);
    % run deep-net in python
    [status,cmdout] = system('cd deep_net-python && python deepnet_256-extract.py ../img_patch/');
    fclose('all');
    % open and read .txt with feature vectors 
    if status~=0
        error_text=['Python Error ' cmdout];
        error(error_text);
    end
    fileID = fopen('deep_vectors.txt');
    features256 = textscan(fileID,'%f');
    format long
    fclose(fileID);
    %num_patch_pos=textscan(cmdout,'%d');
    % save feature vectors in a matrix (each column is a feature vector)
    deep256_vectors=zeros(length(poselet_patches),256);
    for i=1:length(poselet_patches)
        deep256_vectors(i,:)=features256{1}(((i-1)*256)+1:(i*256));
    end
   
end