#from pylab import *

#X = np.linspace(-np.pi, np.pi, 256,endpoint=True)
#C,S = np.cos(X), np.sin(X)

import matplotlib.pyplot as plt
import numpy as np
x = np.arange(0, 10, 0.2)
y = np.sin(x[0:5])
y = np.cos(x[5:10])
plt.plot(x, y)
plt.show()