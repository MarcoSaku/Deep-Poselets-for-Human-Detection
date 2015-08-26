function [config]=init
	% Add the paths for the object type configurations.
    %addpath C:\Users\Marco\Desktop\ProgettoRCF\picheto-poselets-bow-156c00e7c1ef\detector\categories\
    addpath ./source
    
    % Select an object type configuration to load.
    config.obj_config = config_person;
    
    % Path to corresponding directories.
    %%VOC2012 path
	config.PATH_JPEGIMAGES	= 'C:\Users\Marco\Desktop\ProgettoRCF\VOCdevkit\VOC2012\JPEGImages\';
	config.PATH_XML_ANNOTATIONS = './annotations\person\';
    %config.PATH_POSELET_OUT_BASE = 'C:\Users\Marco\Desktop\ProgettoRCF\picheto-poselets-bow-156c00e7c1ef\data\person\pselets\';
    
    % Path to other categories (used for negative examples)
    config.PATH_OTHER_XML_ANNOTATIONS = { './annotations\aeroplane/', ...
                                          '.\annotations\boat/', ... %'/home/esteban/imagenes-rv/annotations/car/', ...
                                          '.\annotations/cow/', ...                                 
                                          '.\annotations/pottedplant/', ...
                                          '.\annotations/bottle/', ...
                                          '.\annotations/cat/', ... %'/home/esteban/imagenes-rv/annotations/diningtable/', '/home/esteban/imagenes-rv/annotations/motorbike/', '/home/esteban/imagenes-rv/annotations/train/', ...
                                          '.\annotations/bird/', ... %'/home/esteban/imagenes-rv/annotations/bus/', '/home/esteban/imagenes-rv/annotations/chair/', '/home/esteban/imagenes-rv/annotations/dog/', ...
                                          '.\annotations\train/', ...
                                          '.\annotations\car/', ...
                                          '.\annotations\diningtable/', ...
                                          };
    
         
    
	% Height is 1.5 times width:
    config.POSELET_PATCH_WIDTH = 61; 
	config.SEED_PATCH_ASPECT_RATIO = 1.0;
	config.SEED_MIN_WIDTH_PX = 50;
    config.NEG_MIN_WIDTH=50;
    config.MIN_POSELET_PATCH=50;
    config.SEED_MIN_KEYPOINTS = 3;
    config.SEED_MAX_KEYPOINTS = 10;
    config.PROCRUSTES_DIST_THRESH = 0.3;% Samples with more than this
                                        % value for procrustes distance
                                        % are discarded.
                                        
    config.POSELET_PATCH_MARGIN_FACTOR = 0.1; % Margin to add to the
                                              % minimal bounding box.
    config.POSELET_PATCH_SIZE = 61;    % Width to which to scale the
                                        % patches before calculating HoG.
    config.NEAREST_TRAINING_EXAMPLES = 700;    
    config.NEGATIVE_PATCHES_PER_CATEGORY = 112;
    config.MIN_ROT_THRESH = pi*1/4;     % A sample that is rotated +/- more than this is discarded.
    config.VISUAL_DIST_WEIGHT = 0.1;    % Weight of visual distance relative to Procruster's distance.       
    
   
    %%Set PATH for cuda, python and pylearn2
    setenv('PATH', 'C:\SciSoft\WinPython-64bit-2.7.9.3\python-2.7.9.amd64;C:\SciSoft\TDM-GCC-64\bin;c:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v6.5\bin;C:\Users\Marco\AppData\Local\Theano\compiledir_Windows-8-6.2.9200-Intel64_Family_6_Model_61_Stepping_4_GenuineIntel-2.7.9-64\cuda_convnet;');
    
end