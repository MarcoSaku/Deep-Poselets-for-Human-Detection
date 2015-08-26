__author__ = 'marcosaviano'

import cPickle

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


a=load_params('params.pkl')
print a


