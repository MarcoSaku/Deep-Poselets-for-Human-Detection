import theano
from theano import tensor as T
from logistic_sgd import LogisticRegression
import numpy
 
rng = numpy.random.RandomState(23455)
# MODEL BUILDING
# Dichiarazione variabili simboliche
x = T.matrix('x')   # the data is presented as rasterized images
y = T.ivector('y')  # the labels are presented as 1D vector [int] labels
 
classifier = LogisticRegression(input=x, n_in=1, n_out=2)
cost = classifier.negative_log_likelihood(y)
 
g_W = T.grad(cost=cost, wrt=classifier.W)
g_b = T.grad(cost=cost, wrt=classifier.b)
 
updates = [(classifier.W, classifier.W - 0.015 * g_W),
                (classifier.b, classifier.b - 0.015 * g_b)]
 
train_model = theano.function([x,y],
           classifier.p_y_given_x,
           updates=updates,
           allow_input_downcast=True,on_unused_input='ignore')
 
#Open file containing data
with open("acts_score.txt") as f:
    scores=f.readline().split() # read first line
with open("acts_label.txt") as f:
    labels=f.readline().split() # read first line
 
#Convert scores to column vector
scores1=numpy.zeros((len(labels), 1))
scores1[:,0]=scores;
 
#Train the logistic regressor
for i in range(0,500):
    prob=train_model(scores1,labels)
 
#Write to file
out_file = open("../act_prob.txt","w")
for p in prob:
    s='%.8f' %p[1]+' '
    out_file.write(s)
 
out_file.close()
 
 
 

