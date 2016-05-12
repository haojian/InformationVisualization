# run it with 'python script.py <infile.wav> <outfile.wav>'

import wave, sys

from scipy.signal import convolve, remez

from scipy import array

from struct import *



# design the filter coefficents

filt = remez(400, array([0, 100, 110, 500, 550, 22050]),

             array([0, 1, 0]), Hz = 44100)



# set up the input and output files

inFileName, outFileName = sys.argv[1:]

inFile = wave.open(inFileName, 'r')

outFile = wave.open(outFileName, 'w')

outFile.setparams(inFile.getparams())



# load each channel into a list

left = []; right = []

for x in xrange(inFile.getnframes()):

   inData = inFile.readframes(1)

   leftData, rightData = unpack('hh', inData)

   left.append(leftData); right.append(rightData)



# do the convolution (i.e. apply the filter)

newLeft = convolve(filt, array(left))

newRight = convolve(filt, array(right))



# write the new file out

for x in xrange(len(newLeft)):

   if x % 10000 is 0:

      print x, 'of', inFile.getnframes()

   outFile.writeframes(pack('hh', newLeft[x], newRight[x]))