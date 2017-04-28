#!/usr/bin/env python
#

import time
import sys
import spidev
import socket

tablename = socket.gethostname()
R100 = 100000.0
RrefA = 100.0
RrefB = 100.0
RrefC = 100.0
RrefD = 100.0
OffsetA = 0.0
OffsetB = 0.0
OffsetC = 0.0
OffsetD = 0.0

spi = spidev.SpiDev()
spi.open(0,0)

spi.max_speed_hz = 1000000

def buildReadCommand(channel):
    if (channel == 0):
      result = [0b00001100, 0b00000000, 0]
    if (channel == 1):
      result = [0b00001100, 0b10000000, 0]
    if (channel == 2):
      result = [0b00001101, 0b00000000, 0]
    if (channel == 3):
      result = [0b00001101, 0b10000000, 0]
    return result
    
def readAdc(channel):
    if ((channel > 3) or (channel < 0)):
        return -1
    mean = 0
    command = buildReadCommand(channel)
    values = []
    for x in range(0, 4000):
      r = spi.xfer2(command)
      r = int(r[1])*256.0+int(r[2])*1.0
      values.append(r)
    values.sort()
#    for x in range(0,500):
#      values.pop()
#      values.pop(0)
    for x in range(0,3500):
      values.pop(0)
    result = sum(values)/len(values)

    if (result < 1.0):
      result = 1.0
    return result

if __name__ == '__main__':
    try:
        while True:
            ch0 = readAdc(0)+OffsetA
            ch1 = readAdc(1)+OffsetB
            ch2 = readAdc(2)+OffsetC
            ch3 = readAdc(3)+OffsetD
            print "ch0 : ",str(ch0), " ch1 : ",str(ch1)," ch2 : ",str(ch2)," ch3 : ",str(ch3)
            scoreA = int(round(R100 * 100.0 / ( RrefA * (4095 / ch0 - 1) ), -2))
            scoreB = int(round(R100 * 100.0 / ( RrefB * (4095 / ch1 - 1) ), -2))
            scoreC = int(round(R100 * 100.0 / ( RrefC * (4095 / ch2 - 1) ), -2))
            scoreD = int(round(R100 * 100.0 / ( RrefD * (4095 / ch3 - 1) ), -2))
            CSV = tablename + "," + str(scoreA) + "," + str(scoreB) + "," + str(scoreC) + "," + str(scoreD)
            print CSV
#            print "CH0: ", str(ch0), "/", str(points0), "- CH1: ", str(ch1), "/", str(points1), "- CH2: ", str(ch2), "/", str(points2), "- CH3: ", str(ch3), "/", str(points3)
            scoresfile = open("/var/www/html/scores.csv","w")
            scoresfile.write(CSV)
            scoresfile.close()
            time.sleep(0.5)
    except KeyboardInterrupt:
        spi.close()
        sys.exit(0)
