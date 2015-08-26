# Extract 256d feature vector from image patch
__author__ = 'marcosaviano'

import theano
from theano import tensor as T
import sys
from mlp import HiddenLayer
import numpy as np
from convnet_layer import MyConvnetLayer
import numpy
from PIL import Image
import cPickle
import glob
import PIL
import os
import math


batch_size=1000

#Load layers params from file
def load_params(file_path):
    try:
        f = file(file_path, 'rb')
        loaded_objects = []
        for i in range(6):
            loaded_objects.append(cPickle.load(f))
        f.close()
        return loaded_objects
    except:
        print '... error loading data from file %s' % file_path

def sub_mean(im):
    r,g,b=im.split()
    rr = r.getdata(); gg = g.getdata(); bb = b.getdata();
    r_mean = np.mean(rr); g_mean = np.mean(gg); b_mean = np.mean(bb);
    r_meanM=np.full((61, 61), r_mean);g_meanM=np.full((61, 61), g_mean);b_meanM=np.full((61, 61), b_mean);
    r2=r-r_meanM;g2=g-g_meanM;b2=b-b_meanM;
    #r2=rr-r_mean; g2=gg-g_mean; b2=bb-b_mean;
    rgbArray = np.zeros((61,61,3), dtype=theano.config.floatX)
    rgbArray[:,:, 0] = r2; rgbArray[:,:, 1] = g2; rgbArray[:,:, 2] = b2;
    #img = Image.fromarray(rgbArray)
    return rgbArray

def extract_256array(img_dir):
    #print "Loading params..."
    loaded_params=load_params('params-momentum_weightdecay-NEW-BIg4class-01.pkl')
    num_images=len(glob.glob(img_dir + '*.jpg'))

    if batch_size==0:
        sys.exit()

    ## MODEL CNN
    # Dichiarazione variabile simbolica immagine input
    x = T.tensor4('x')   # the data is presented as rasterized images
    # Variabili simboliche per i parametri caricati da file
    W1 = theano.shared(loaded_params[0][0].get_value());B1 = theano.shared(loaded_params[0][1].get_value())
    W2=theano.shared(loaded_params[1][0].get_value());B2 = theano.shared(loaded_params[1][1].get_value())
    W3=theano.shared(loaded_params[2][0].get_value());B3 = theano.shared(loaded_params[2][1].get_value())
    W4=theano.shared(loaded_params[3][0].get_value());B4 = theano.shared(loaded_params[3][1].get_value())
    W5=theano.shared(loaded_params[4][0].get_value());B5 = theano.shared(loaded_params[4][1].get_value())

    #batch_size=1
    #print "Building model..."
    layer0_input = x.reshape((batch_size, 3, 61, 61))
    # build symbolic expression that computes the convolution of input with filters in w
    conv_out1=MyConvnetLayer(W1,B1,input=layer0_input,filter_shape=(64, 3, 5, 5),image_shape=(batch_size, 3, 61, 61),conv_stride=(2,2),pool_stride=(2,2),poolsize=(3,3))
    #
    conv_out2=MyConvnetLayer(W2,B2,input=conv_out1.output,filter_shape=(256, 64, 5, 5),image_shape=(batch_size, 64, 14, 14),conv_stride=(1,1))

    conv_out3=MyConvnetLayer(W3,B3,input=conv_out2.output,filter_shape=(128, 256, 3, 3),image_shape=(batch_size, 256, 10, 10),conv_stride=(1,1))

    conv_out4=MyConvnetLayer(W4,B4,input=conv_out3.output,filter_shape=(128, 128, 3, 3),image_shape=(batch_size, 128, 8, 8),conv_stride=(1,1))

    layer5_input = conv_out4.output.flatten(2)

    #construct a fully-connected sigmoidal layer
    full_5 = HiddenLayer(
             W5,B5,
             input=layer5_input,
             n_in=128 * 6 * 6,
             n_out=256,
             activation=T.tanh
    )

    # create theano function to compute filtered images
    f_layer5 = theano.function([x],
               full_5.output,
               allow_input_downcast=True,on_unused_input='ignore'
            )
    ## END MODEL CNN

    if num_images<batch_size:
        batchsize=num_images
    else:
        batchsize=batch_size


    num_batch=int(math.ceil(num_images/float(batchsize)))
    features=np.zeros((num_images,256),theano.config.floatX,'C')
    for j in range(1,num_batch+1):
        images=np.zeros((batch_size,3,61,61),theano.config.floatX,'C')

        i=0
        num_img_batch=min(batchsize,num_images-batchsize*(j-1))
        for i_img in range(1,num_img_batch+1):
            img_name=img_dir+str(i_img+batchsize*(j-1))+'.jpg'
            img = Image.open(img_name)
            img_res=img.resize((61,61), PIL.Image.ANTIALIAS)
            # dimensions are (height, width, channel)
            img_res=sub_mean(img_res)
            img_res = numpy.asarray(img_res, dtype=theano.config.floatX) / 256.
            # put image in 4D tensor of shape (1, 3, height, width)
            img_ = img_res.transpose(2, 0, 1).reshape(1, 3, 61, 61)
            images[i,:,:,:]=img_
            i=i+1

        feature_256=f_layer5(images)
        range_feat=range(batchsize*(j-1),batchsize*(j-1)+ num_img_batch)
        for k in range(0,num_img_batch):
            features[range_feat[k]]=feature_256[k]
    #print feature_256
    return features

if __name__ == '__main__':
    if os.path.exists("../temp/deep_vectors.txt"):
        os.remove("../temp/deep_vectors.txt")
    features=extract_256array(sys.argv[1])
    out_file = open("../temp/deep_vectors.txt","w")
    for ft in features:
        out_file.write(str(ft)[1:-1])
    out_file.close()
    print len(features)
