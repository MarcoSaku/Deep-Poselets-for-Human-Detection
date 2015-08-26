#Test the deep-net on validation set
__author__ = 'Marco'
__author__ = 'Marco'

import theano
from theano import tensor as T
import math
import numpy as np
from mlp_test import HiddenLayer
from logistic_sgd_test import LogisticRegression
from convnet_layer_test import MyConvnetLayer
import numpy
from PIL import Image
import PIL
import cPickle



# FUNCTIONS salvataggio/caricamento parametri da file
#Save layers params in file
def save_params(params1,params2,params3,params4,params5,params6, file_path):
    f = file(file_path, 'wb')
    for obj in [params1, params2,params3,params4,params5,params6]:
        cPickle.dump(obj, f, protocol=cPickle.HIGHEST_PROTOCOL)
    f.close()

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


def indices(lst, element):
    result = []
    offset = -1
    while True:
        try:
            offset = lst.index(element, offset+1)
        except ValueError:
            return result
        result.append(offset)


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

def test_deep():
    dir_true='/home/0120000114/POSELETS-FINAL-4class/'
    dir_false='/home/0120000114/image_poselets-train-nofast/false/'
	
	n_train_set=600
    batch_size=200
    n_batch=n_train_set/batch_size   #numero di batch
    # Dichiarazione variabili simboliche
    loaded_params=load_params('params-momentum_weightdecay-NEW-BIg4class-01.pkl')
    W1 = theano.shared(loaded_params[0][0].get_value());B1 = theano.shared(loaded_params[0][1].get_value())
    W2=theano.shared(loaded_params[1][0].get_value());B2 = theano.shared(loaded_params[1][1].get_value())
    W3=theano.shared(loaded_params[2][0].get_value());B3 = theano.shared(loaded_params[2][1].get_value())
    W4=theano.shared(loaded_params[3][0].get_value());B4 = theano.shared(loaded_params[3][1].get_value())
    W5=theano.shared(loaded_params[4][0].get_value());B5 = theano.shared(loaded_params[4][1].get_value())
    W6=theano.shared(loaded_params[5][0].get_value());B6 = theano.shared(loaded_params[5][1].get_value())
    rng = numpy.random.RandomState(23455)
    x = T.tensor4('x')   # the data is presented as rasterized images
    y = T.ivector('y')  # the labels are presented as 1D vector [int] labels

    print "Building model..."
    layer0_input = x.reshape((batch_size, 3, 61, 61))
    # build symbolic expression that computes the convolution of input with filters in w
    conv_out1=MyConvnetLayer(W1,B1,input=layer0_input,filter_shape=(64, 3, 5, 5),image_shape=(batch_size, 3, 61, 61),conv_stride=(2,2),pool_stride=(2,2),poolsize=(3,3))

    conv_out2=MyConvnetLayer(W2,B2,input=conv_out1.output,filter_shape=(256, 64, 5, 5),image_shape=(batch_size, 64, 14, 14),conv_stride=(1,1))

    conv_out3=MyConvnetLayer(W3,B3,input=conv_out2.output,filter_shape=(128, 256, 3, 3),image_shape=(batch_size, 256, 10, 10),conv_stride=(1,1))

    conv_out4=MyConvnetLayer(W4,B4,input=conv_out3.output,filter_shape=(128, 128, 3, 3),image_shape=(batch_size, 128, 8, 8),conv_stride=(1,1))

    layer5_input = conv_out4.output.flatten(2)

    # construct a fully-connected sigmoidal layer
    full_5 = HiddenLayer(
            W5,B5,
            input=layer5_input,
            n_in=128 * 6 * 6,
            n_out=256,
            activation=T.tanh
    )
    # classify the values of the fully-connected sigmoidal layer
    full_5_softmax = LogisticRegression(W6,B6,input=full_5.output, n_in=256, n_out=5)
    weight_decay=1e-5
    # the cost we minimize during training is the NLL of the model

    prova=theano.function([x,y],
              y,
               #updates=updates,
               allow_input_downcast=True,on_unused_input='ignore'
            )

    validate_model=theano.function([x,y],
               [full_5_softmax.errors(y),full_5_softmax.y_pred],
               allow_input_downcast=True,on_unused_input='ignore'
            )

    # CARICAMENTO JSON CONTENENTI LE POSELET POSITIVE/NEGATIVE
    print "Loading data..."


    ytrue_b=[]
    for k in range(0,40):
        ytrue_b+=range(0,5)
        #ytrue_b+=[4]

    batch_cost=0;loss_cost=0;min_cost=0;
    print "Validating..."

    batch_err=0;
    for z in range(1,n_batch+1):
        images=np.zeros((batch_size,3,61,61),theano.config.floatX,'C')
        for p in range(1,41):
            for h in range(0,4):
                img_name=dir_true+str(h)+"/"+str((z-1)*40+p+18000)+".jpg"
                img = Image.open(img_name)
                img = img.resize((61,61), PIL.Image.ANTIALIAS)
                img=sub_mean(img)
                img = numpy.asarray(img, dtype=theano.config.floatX) / 256.
                img_ = img.transpose(2, 0, 1).reshape(1, 3, 61, 61)
                images[(p-1)*4+(p-1)+(h)]=img_
            img_name=dir_false+str((z-1)*40+p+80000)+".jpg"
            img = Image.open(img_name)
            img = img.resize((61,61), PIL.Image.ANTIALIAS)
            img=sub_mean(img)
            img = numpy.asarray(img, dtype=theano.config.floatX) / 256.
            img_ = img.transpose(2, 0, 1).reshape(1, 3, 61, 61)
            images[(p-1)*4+(p-1)+4]=img_

        val_error,predy = validate_model(images,ytrue_b)
        batch_err=batch_err+val_error*100
        print "   Batch",z,"/",n_batch,"   Validation error",val_error*100.
    print "Mean error ",batch_err/n_batch

if __name__ == '__main__':
    test_deep();




