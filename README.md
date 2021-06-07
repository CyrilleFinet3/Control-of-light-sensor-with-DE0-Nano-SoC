# Control of light sensor with DE0-Nano-SoC

This project is part of the Hardware/Software Platforms MA1 course at the Polytechnic Faculty of Mons(https://web.umons.ac.be/fpms/fr/). The goal of this project is to drive the BH1710FVI light sensor with the DE0-Nano-SoC board. 

* Group members: Deffrennes Théo (Theo.deffrennes@student.umons.ac.be) and Finet Cyrille (Cyrille.finet@student.umons.ac.be) 
* Project title: Control of a light sensor with the DE0-Nano-SoC board
* Academic year: 2020-2021

The project is mainly implemented with VHDL with a little bit of Verilog and C. The software used is "Quartus Prime Lite edition". 

### 1) BH1710FVI Light sensor and I2C protocol

The BH1710FVI is a digital ambient light sensor with an I2C bus interface. The sensor measures the illuminance in lux (1 lux=1 lumen/m^2). The detection range is from 1 to 65535 lux. Therefore, the data sent from the sensor are coded on 16 bits. 

I2C is a half-duplex bidirectional synchronous serial bus composed of 2 signal lines:
* SDA (Serial Data Line): bidirectional data line
* SCL (Serial Clock Line): bidirectional clock line

The I2C uses a master-slave(s) communication and in the frame of this tutorial, the master is the DE0-Nano-SoC and the slave is the light sensor. 
The scheme of the communication is as follows with first the writing operation (R/W = 0) and the reading operation (R/W = 1) on 2 bytes:

<p align="center">
  <img src="https://user-images.githubusercontent.com/79786800/118889273-2f049c00-b8fd-11eb-8f2f-35ef01ece9cb.png" />
</p>

The slave address of the light sensor is coded on 7 bits:"0100011". 
The opecode is explained in the instruction set architecture of the device and defines the type of resolution (Low, Mid, High) and if the measurement is made once or continuously. 


### 2) Implementation of the sensor with Quartus
The Altera Quartus EDA tool and the DE0 development kits will be used to interact with the periphery through a hardware driver. 
- The first thing to do is to download the DE0 nano SoC golden and open the file soc_system.qpf as project in Quartus.  In the downloaded golden file there is also the ghrd.v file which will the main file of the project. It is a Verilog file corresponding to the golden hardware. 
- Secondly, the routing (clock, reset, registers) configuration in the FPGA must be done with Platform Designer application on Quartus.  As the light captor uses 16 bits the read the data, two output register of 8 bits will be used and thus be added in Platform Designer. After this manipulation the ghrd.v file need to be updated with the modifications realised in Platform Designer. 
- Then, still on Quartus, the application Pin Planner has to be used to allocate the pin that will be used on the FPGA. One for the scl and the other for the sda. 
- After these manipulation the ghrd.v file need to be updated with the modifications realised in Platform Designer.

When these steps are achieved it is possible to create the vhdl code (light.vhd) corresponding to the sensor's operation. 

### 3) VHDL codes

The project included 2 main codes in VHDL:

* The I2C master driver (I2C_M.vhd) which defines the state machine of the I2C protocol.
* The Light bloc (light.vhd) that uses the I2C driver and transfers the data to two output registers of 8 bits for the software.

Testbenches are also included to verify that the codes are working properly.

#### 3.a) I2C master driver

The I2C master state machine is illustrated below. The code that has been implemented (I2C_M.vhd) follows the operation of the state machine. The entity of the driver defines multiple ports:

* clk : system clock (50 MHz)
* reset_n : 
* ena : 
* addr : 
* rw : 
* data_wr : 
* data_rd :
* busy :
* ack_error : 
* sda :
* scl : 


<p align="center">
  <img src="https://user-images.githubusercontent.com/79786800/121052583-cd787480-c7ba-11eb-9b0d-97f72eed8fcb.png" />
</p>


#### 3.b) Light bloc











