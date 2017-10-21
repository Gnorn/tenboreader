#!/usr/bin/env python
#

import os
import time
import sys
import spidev
import socket

R100 = 100000.0
RrefA = 100.0
RrefB = 100.0
RrefC = 100.0
RrefD = 100.0

spi = spidev.SpiDev()
spi.open(0,0)

spi.max_speed_hz = 1000000

def buildReadCommand(channel):
    if (channel == 3):
      result = [0b00001100, 0b00000000, 0]
    if (channel == 2):
      result = [0b00001100, 0b10000000, 0]
    if (channel == 1):
      result = [0b00001101, 0b00000000, 0]
    if (channel == 0):
      result = [0b00001101, 0b10000000, 0]
    return result
    
def readAdc(channel):
    if ((channel > 3) or (channel < 0)):
        return -1
    mean = 0
    command = buildReadCommand(channel)
    values = []
    for x in range(0, 10000):
      r = spi.xfer2(command)
      r = int(r[1])*256.0+int(r[2])*1.0
      values.append(r)
    values.sort()
#    for x in range(0,3990):
#      values.pop(0)
    result = sum(values[-100:])/len(values[-100:])

#    if (result < 1.0):
#      result = 1.0
    return result

if __name__ == '__main__':
    try:
      ch0 = readAdc(0)
      OffsetA = 4.0 - ch0
      ch1 = readAdc(1)
      OffsetB = 4.0 - ch1
      ch2 = readAdc(2)
      OffsetC = 4.0 - ch2
      ch3 = readAdc(3)
      OffsetD = 4.0 - ch3
      print "ch0 : ",str(ch0), " (offset : ",str(OffsetA),") - ch1 : ",str(ch1)," (offset : ",str(OffsetB),") - ch2 : ",str(ch2),"  (offset : ",str(OffsetC),") - ch3 : ",str(ch3)," (offset : ",str(OffsetD),")"  
      os.remove('/home/pi/offsetconfig.py')

      cfg = open('/home/pi/offsetconfig.py','w')
      cfgcontent = "#!/usr/bin/env python\nOffsetA = " + str(OffsetA) + "\nOffsetB = " + str(OffsetB) + "\nOffsetC = " + str(OffsetC) + "\nOffsetD = " + str(OffsetD) + "\n"
      cfg.write(cfgcontent)
      os.system('/home/pi/restartpoints.sh &')
      print "Done!"
    except KeyboardInterrupt:
        spi.close()
        sys.exit(0)
