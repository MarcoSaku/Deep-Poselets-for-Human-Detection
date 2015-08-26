function [config]=init
	%path to r-cnn
	addpath 'C:\Users\Marco\Desktop\ProgettoRCF\rcnn'
	startup
	% Add the paths for the object type configurations.
    addpath './source'
        
    % Select an object type configuration to load.
    config.obj_config = config_person;
    
    % Path to corresponding directories.
	config.PATH_JPEGIMAGES	= 'C:\Users\Marco\Desktop\ProgettoRCF\VOCdevkit\VOC2012\JPEGImages\';
	config.PATH_XML_ANNOTATIONS = 'C:\Users\Marco\Desktop\ProgettoRCF\picheto-poselets-bow-156c00e7c1ef\annotations\person\';
    %config.PATH_POSELET_OUT_BASE = 'C:\Users\Marco\Desktop\ProgettoRCF\picheto-poselets-bow-156c00e7c1ef\data\person\poselets\';
    
    % Path to other categories (used for negative examples)
    config.PATH_OTHER_XML_ANNOTATIONS = { 'C:\Users\Marco\Desktop\ProgettoRCF\picheto-poselets-bow-156c00e7c1ef\annotations\aeroplane/', ...
                                          'C:\Users\Marco\Desktop\ProgettoRCF\picheto-poselets-bow-156c00e7c1ef\annotations\boat/', ... %'/home/esteban/imagenes-rv/annotations/car/', ...
                                          'C:\Users\Marco\Desktop\ProgettoRCF\picheto-poselets-bow-156c00e7c1ef\annotations/cow/', ...                                 
                                          'C:\Users\Marco\Desktop\ProgettoRCF\picheto-poselets-bow-156c00e7c1ef\annotations/pottedplant/', ...
                                          'C:\Users\Marco\Desktop\ProgettoRCF\picheto-poselets-bow-156c00e7c1ef\annotations/bottle/', ...
                                          'C:\Users\Marco\Desktop\ProgettoRCF\picheto-poselets-bow-156c00e7c1ef\annotations/cat/', ... %'/home/esteban/imagenes-rv/annotations/diningtable/', '/home/esteban/imagenes-rv/annotations/motorbike/', '/home/esteban/imagenes-rv/annotations/train/', ...
                                          'C:\Users\Marco\Desktop\ProgettoRCF\picheto-poselets-bow-156c00e7c1ef\annotations/bird/', ... %'/home/esteban/imagenes-rv/annotations/bus/', '/home/esteban/imagenes-rv/annotations/chair/', '/home/esteban/imagenes-rv/annotations/dog/', ...
                                          'C:\Users\Marco\Desktop\ProgettoRCF\picheto-poselets-bow-156c00e7c1ef\annotations\train/', ...
                                          'C:\Users\Marco\Desktop\ProgettoRCF\picheto-poselets-bow-156c00e7c1ef\annotations\car/', ...
                                          'C:\Users\Marco\Desktop\ProgettoRCF\picheto-poselets-bow-156c00e7c1ef\annotations\diningtable/', ...
                                          };
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    config.GREEDY_CLUSTER_THRESH=30;
    config.CLUSTER_BOUNDS_DIST_TYPE=0;
    config.DEBUG=0;
    config.HYP_CLUSTER_MAXNUM=100;
    config.CLUSTER_HITS_CUTOFF=0.6;
    config.CLASSES={'aeroplane','bicycle','bird','boat','bottle','bus','car','cat','chair','cow','diningtable','dog','horse','motorbike','person','pottedplant','sheep','sofa','train','tvmonitor'};
    config.CROP_PREDICTED_OBJ_BOUNDS_TO_IMG=1;
    config.KL_USE_WEIGHTED_DISTANCE=0;
     config.TORSO_ASPECT_RATIO=1.5;
     
     for i=1:length(config.CLASSES)
        config_file = sprintf('config_%s',config.CLASSES{i});
        if exist(config_file,'file')
           config.K(i) = eval(config_file);
           disp(sprintf('configuring %s',config.CLASSES{i}));
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
    setenv('PATH', 'C:\SciSoft\WinPython-64bit-2.7.9.3\python-2.7.9.amd64;C:\SciSoft\TDM-GCC-64\bin;c:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v6.5\bin;C:\Users\Marco\AppData\Local\Theano\compiledir_Windows-8-6.2.9200-Intel64_Family_6_Model_61_Stepping_4_GenuineIntel-2.7.9-64\cuda_convnet;');
    
    
    
    
	
end