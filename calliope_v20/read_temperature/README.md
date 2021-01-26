# Read Temperature

In this example, the temperature from the microcontroller and the motion sensor (BMX055) is displayed. 
Note that the Calliope mini uses different pins for the I2C interface. 

## Building


After compiling, go to the obj directory and create a hex file with the following command: 

     arm-none-eabi-objcopy -O ihex  read_temperature read_temperature.hex

and then download the hex file to the board via USB. 

