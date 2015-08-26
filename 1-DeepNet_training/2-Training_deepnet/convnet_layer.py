__author__ = 'marcosaviano'

import os
import sys
import time

import numpy
import theano
import theano.tensor as T
from theano.tensor.signal import downsample
from theano.tensor.nnet import conv
from theano.sandbox.cuda.basic_ops import gpu_contiguous
from pylearn2.sandbox.cuda_convnet.filter_acts import FilterActs
from pylearn2.sandbox.cuda_convnet.pool import MaxPool

class MyConvnetLayer(object):
    """Pool Layer of a convolutional network """

    def __init__(self, rng, input, filter_shape, image_shape, poolsize=(1, 1), conv_stride=(1, 1), pool_stride=None):
        if pool_stride==None:
            pool_stride=poolsize
        """
        Allocate a LeNetConvPoolLayer with shared variable internal parameters.

        :type rng: numpy.random.RandomState
        :param rng: a random number generator used to initialize weights

        :type input: theano.tensor.dtensor4
        :param input: symbolic image tensor, of shape image_shape

        :type filter_shape: tuple or list of length 4
        :param filter_shape: (number of filters, num input feature maps,
                              filter height, filter width)

        :type image_shape: tuple or list of length 4
        :param image_shape: (batch size, num input feature maps,
                             image height, image width)

        :type poolsize: tuple or list of length 2
        :param poolsize: the downsampling (pooling) factor (#rows, #cols)
        """

        assert image_shape[1] == filter_shape[1]
        self.input = input

        # there are "num input feature maps * filter height * filter width"
        # inputs to each hidden unit
        fan_in = numpy.prod(filter_shape[1:])
        # each unit in the lower layer receives a gradient from:
        # "num output feature maps * filter height * filter width" /
        # pooling size
        fan_out = (filter_shape[0] * numpy.prod(filter_shape[2:]) /
                   numpy.prod(poolsize))
        # initialize weights with random weights
        W_bound = numpy.sqrt(6. / (fan_in + fan_out))
        self.W = theano.shared(
            numpy.asarray(
                rng.uniform(low=-W_bound, high=W_bound, size=filter_shape),
                dtype=theano.config.floatX
            ),
            borrow=True
        )

        # the bias is a 1D tensor -- one bias per output feature map
        b_values = numpy.zeros((filter_shape[0],), dtype=theano.config.floatX)
        self.b = theano.shared(value=b_values, borrow=True)

        # # convolve input feature maps with filters
        # conv_out = conv.conv2d(
        #     input=input,
        #     filters=self.W,
        #     filter_shape=filter_shape,
        #     image_shape=image_shape,
        #     subsample=conv_stride
        # )
        input_shuffled = input.dimshuffle(1, 2, 3, 0) # bc01 to c01b
        filters_shuffled = self.W.dimshuffle(1, 2, 3, 0) # bc01 to c01b
        conv_op = FilterActs(stride=conv_stride[0], partial_sum=1)
        contiguous_input = gpu_contiguous(input_shuffled)
        contiguous_filters = gpu_contiguous(filters_shuffled)
        conv_out_shuffled = conv_op(contiguous_input, contiguous_filters)

        # downsample each feature map individually, using maxpooling
        # pooled_out = downsample.max_pool_2d(
        #     input=conv_out,
        #     ds=poolsize,
        #     ignore_border=True,
        #     st=pool_stride
        # )
        pool_op = MaxPool(ds=poolsize[0], stride=pool_stride[0])
        pooled_out_shuffled = pool_op(conv_out_shuffled)
        pooled_out = pooled_out_shuffled.dimshuffle(3, 0, 1, 2) # c01b to bc01


        # add the bias term. Since the bias is a vector (1D array), we first
        # reshape it to a tensor of shape (1, n_filters, 1, 1). Each bias will
        # thus be broadcasted across mini-batches and feature map
        # width & height
        self.output = T.tanh(pooled_out + self.b.dimshuffle('x', 0, 'x', 'x'))

        # store parameters of this layer
        self.params = [self.W, self.b]



