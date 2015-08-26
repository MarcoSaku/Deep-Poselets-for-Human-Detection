##### Prelevo le immagini della categoria persona, le copio in una directory e creo il json contenente le bounding boxes ########
from pycocotools.coco import COCO
import numpy as np
import skimage.io as io
import matplotlib.pyplot as plt
import shutil
import json

# In[2]:

dataDir='..'
dataType='val2014'
annFile='%s/annotations/instances_%s.json'%(dataDir,dataType)


# In[3]:

# initialize COCO api for instance annotations
coco=COCO(annFile)

# get all images containing given categories, select one at random
catIds = coco.getCatIds(catNms=['person'])
imgIds = coco.getImgIds(catIds=catIds)

data=[]
for i in range(1,len(imgIds)):
	print "Processing image ",i,"/",len(imgIds)
	id_image=imgIds[i]
	img = coco.loadImgs(id_image)[0]
	print img['file_name']
	shutil.copy('%s/images/%s/%s'%(dataDir,dataType,img['file_name']),'../person_image')
	annIds = coco.getAnnIds(imgIds=id_image, catIds=catIds, iscrowd=None)
	anns = coco.loadAnns(annIds)
	bbox_list=[]
	for j in range(0,len(anns)):
		bbox_list.append(anns[j]['bbox'])
	data.append({'file_name':img['file_name'],'image_id':id_image,'bbox':bbox_list})

import io, json
with io.open('bboxes.json', 'w', encoding='utf-8') as f:
  f.write(unicode(json.dumps(data, ensure_ascii=False)))

