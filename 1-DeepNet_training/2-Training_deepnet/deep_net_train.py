#Training of Deep Net using 5 classes (4 poselet types + background)
__author__ = 'Marco'
__author__ = 'Marco'

import theano
from theano import tensor as T
import math
import numpy as np
from mlp import HiddenLayer
from logistic_sgd import LogisticRegression
from convnet_layer import MyConvnetLayer
import numpy
from PIL import Image
import PIL
import cPickle
from random import shuffle

#Directory which contain the samples
dir_true='/home/0120000114/POSELETS-FINAL-4class/'
dir_false='/home/0120000114/image_poselets-train-nofast/false/'

learning_rate=0.15
n_epochs=40
n_train_set=122400
batch_size=1700
n_batch=int(n_train_set/batch_size)   #numero di batch

# FUNCTIONS save/load parameters to/from file
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

#Subtract the mean from the image
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

#Weight update rule (using momentum and weightdecay)
def gradient_updates_momentum(cost, params, learning_rate, momentum,weight_decay):
    assert momentum < 1 and momentum >= 0
    # List of update steps for each parameter
    updates = []
    # Just gradient descent on cost
    for param in params:
        # For each parameter, we'll create a param_update shared variable.
        # This variable will keep track of the parameter's update step across iterations.
        # We initialize it to 0
        param_update = theano.shared(param.get_value()*0., broadcastable=param.broadcastable)
        # Each parameter is updated by taking a step in the direction of the gradient.
        # However, we also "mix in" the previous step according to the given momentum value.
        # Note that when updating param_update, we are using its old value and also the new gradient step.
        #updates.append((param, param - learning_rate*param_update))
        updates.append((param, param - learning_rate*param_update - param_update*weight_decay*learning_rate))
        # Note that we don't need to derive backpropagation to compute updates - just use T.grad!
        updates.append((param_update, momentum*param_update + (1. - momentum)*T.grad(cost, param)))
    return updates

# Theano symbolical variables declaration
rng = numpy.random.RandomState(23455)
x = T.tensor4('x')   # the data is presented as rasterized images
y = T.ivector('y')  # the labels are presented as 1D vector [int] labels
lr=T.fscalar('lr')   #learning rate

#Build the deep-net structure using Theano Framework
print "Building model..."
layer0_input = x.reshape((batch_size, 3, 61, 61))
# build symbolic expression that computes the convolution of input with filters in w
conv_out1=MyConvnetLayer(rng,input=layer0_input,filter_shape=(64, 3, 5, 5),image_shape=(batch_size, 3, 61, 61),conv_stride=(2,2),pool_stride=(2,2),poolsize=(3,3))

conv_out2=MyConvnetLayer(rng,input=conv_out1.output,filter_shape=(256, 64, 5, 5),image_shape=(batch_size, 64, 14, 14),conv_stride=(1,1))

conv_out3=MyConvnetLayer(rng,input=conv_out2.output,filter_shape=(128, 256, 3, 3),image_shape=(batch_size, 256, 10, 10),conv_stride=(1,1))

conv_out4=MyConvnetLayer(rng,input=conv_out3.output,filter_shape=(128, 128, 3, 3),image_shape=(batch_size, 128, 8, 8),conv_stride=(1,1))

layer5_input = conv_out4.output.flatten(2)

# construct a fully-connected sigmoidal layer
full_5 = HiddenLayer(
        rng,
        input=layer5_input,
        n_in=128 * 6 * 6,
        n_out=256,
        activation=T.tanh
)
# classify the values of the fully-connected sigmoidal layer
full_5_softmax = LogisticRegression(input=full_5.output, n_in=256, n_out=5)
weight_decay=1e-5
momentum=0.9

# Cost function for minibatch
cost = T.mean(T.nnet.categorical_crossentropy(full_5_softmax.p_y_given_x,y))
# Concatenation of the params
params=full_5_softmax.params + full_5.params + conv_out4.params + conv_out3.params + conv_out2.params + conv_out1.params

# create theano function to compute filtered images
train_model = theano.function([x,y,lr],
          [cost,full_5_softmax.p_y_given_x,full_5_softmax.y_pred,full_5_softmax.errors(y)],
          updates= gradient_updates_momentum(cost, params, lr, momentum,weight_decay),
          #updates=updates,
          allow_input_downcast=True,on_unused_input='ignore'
        )

#prova=theano.function([x,y,lr],
 #         y,
           #updates=updates,
  #         allow_input_downcast=True,on_unused_input='ignore'
   #     )

# Create the vector with labels
print "Loading data..."
ytrue_b1=[]
for k in range(0,250):
    ytrue_b1+=range(0,4)
ytrue_b1+=[4]*700
index_shuf = range(len(ytrue_b1))
shuffle(index_shuf)
ytrue_b=[];
for i in index_shuf:
    ytrue_b.append(ytrue_b1[i])


params_old=0;
batch_cost=0;loss_cost=0;batch_mean_cost=0;
print "Training..."

for epoch in range(1,n_epochs+1):
    old_batch_cost=batch_mean_cost; batch_cost=0;false=0;true=0;batch_val_error=0;
    for z in range(1,n_batch+1):
        images1=np.zeros((batch_size,3,61,61),theano.config.floatX,'C')
        ll=0
        for p in range(1,251):
            for h in range(0,4):
                img_name=dir_true+str(h)+"/"+str((z-1)*250+p)+".jpg"
                img = Image.open(img_name)
                img = img.resize((61,61), PIL.Image.ANTIALIAS)
                img=sub_mean(img)
                img = numpy.asarray(img, dtype=theano.config.floatX) / 256.
                img_ = img.transpose(2, 0, 1).reshape(1, 3, 61, 61)
                images1[(p-1)*3+(p-1)+(h)]=img_
                true=true+1;
        for ll in range(1,701):
            img_name=dir_false+str((z-1)*700+ll)+".jpg"
            img = Image.open(img_name)
            img = img.resize((61,61), PIL.Image.ANTIALIAS)
            img=sub_mean(img)
            img = numpy.asarray(img, dtype=theano.config.floatX) / 256.
            img_ = img.transpose(2, 0, 1).reshape(1, 3, 61, 61)
            images1[999+ll]=img_
            false=false+1;

        images=np.zeros((batch_size,3,61,61),theano.config.floatX,'C')
        j=0;
        for i in index_shuf:
            images[j]=images1[i]
            j=j+1
        loss_cost,py,predy,val_error = train_model(images,ytrue_b,learning_rate)
        print "  Epoch ",epoch,"/",n_epochs,"   Batch",z,"/",n_batch,"   loss cost=",loss_cost,"  val_err=",val_error*100.
        batch_val_error=batch_val_error+val_error
        batch_cost=batch_cost+loss_cost

        save_params(conv_out1.params,conv_out2.params,conv_out3.params,conv_out4.params,full_5.params,full_5_softmax.params,'params-momentum_weightdecay-NEW-BIg4class.pkl')

    batch_mean_cost=batch_cost/n_batch
    if epoch!=1:
        if (old_batch_cost-batch_mean_cost)<0.01:
            print "   Upgrading learning rate..."
            learning_rate=learning_rate * 0.2

    print "   Batch Validation error",(batch_val_error*100.)/n_batch
    print "   Old Batch Loss cost",old_batch_cost
    print "   Batch Loss cost",batch_mean_cost




