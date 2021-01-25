--  Copyright (c) 2021, Karsten Lueth (kl@kloc-consulting.de)
--  All rights reserved.
--
--  Redistribution and use in source and binary forms, with or without
--  modification, are permitted provided that the following conditions are met:
--
--  1. Redistributions of source code must retain the above copyright notice,
--     this list of conditions and the following disclaimer.
--
--  2. Redistributions in binary form must reproduce the above copyright notice,
--     this list of conditions and the following disclaimer in the documentation
--     and/or other materials provided with the distribution.
--
--  3. Neither the name of the copyright holder nor the names of its
--     contributors may be used to endorse or promote products derived from
--     this software without specific prior written permission.
--
--  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
--  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
--  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
--  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
--  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
--  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
--  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
--  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
--  WHETHER IN CONTRACT, STRICT LIABILITY,
--  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
--  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

with HAL;        use HAL;
with HAL.I2C;    use HAL.I2C;
with Interfaces; use Interfaces;


package LSM303AGR is

   type LSM303AGR_Accelerometer (Port : not null Any_I2C_Port)
   is tagged limited private;

   type Dynamic_Range is (Two_G, Four_G, Heigh_G);

   type Data_Rate is (Hz_1, Hz_10, Hz_25, Hz_50, Hz_100, Hz_200, Hz_400);

   procedure Configure (This                : in out LSM303AGR_Accelerometer;
                        Dyna_Range          : Dynamic_Range;
                        Rate                : Data_Rate);

   function Check_Device_Id (This : LSM303AGR_Accelerometer) return Boolean;

   type Axis_Data is range -2 ** 9 .. 2 ** 9 - 1
     with Size => 10;

   type All_Axes_Data is record
      X, Y, Z : Axis_Data;
   end record;

   function Read_Data (This : LSM303AGR_Accelerometer) return All_Axes_Data;

   procedure Enable_Temperature_Sensor
    (This : LSM303AGR_Accelerometer; Enabled : Boolean);

   subtype Temp_Celsius is Integer_8;

   function Read_Temperature
     (This : LSM303AGR_Accelerometer) return Temp_Celsius;

   function Get_Temp_Config
     (This : LSM303AGR_Accelerometer) return Uint8;

   function Get_Ctrl_Reg_4
     (This : LSM303AGR_Accelerometer) return Uint8;

private
   type LSM303AGR_Accelerometer (Port : not null Any_I2C_Port) is tagged limited
     null record;

   type Register_Addresss is new UInt8;

   for Dynamic_Range use (Two_G   => 16#00#,
                          Four_G  => 16#10#,
                          Heigh_G => 16#20#);

   for Data_Rate use (Hz_1   => 16#10#,
                      Hz_10  => 16#20#,
                      Hz_25  => 16#30#,
                      Hz_50  => 16#40#,
                      Hz_100 => 16#50#,
                      Hz_200 => 16#60#,
                      Hz_400 => 16#70#);

   Device_Id      : constant := 16#33#;

   Who_Am_I       : constant Register_Addresss := 16#0F#;

   OUT_TEMP_L_A   : constant Register_Addresss := 16#0C#;
   OUT_TEMP_H_A   : constant Register_Addresss := 16#0D#;
   TEMP_CFG_REG_A : constant Register_Addresss := 16#1F#;
   CTRL_REG1_A    : constant Register_Addresss := 16#20#;
   CTRL_REG2_A    : constant Register_Addresss := 16#21#;
   CTRL_REG3_A    : constant Register_Addresss := 16#22#;
   CTRL_REG4_A    : constant Register_Addresss := 16#23#;
   CTRL_REG5_A    : constant Register_Addresss := 16#24#;
   CTRL_REG6_A    : constant Register_Addresss := 16#25#;
   DATA_STATUS    : constant Register_Addresss := 16#27#;
   OUT_X_LSB      : constant Register_Addresss := 16#28#;
   OUT_X_MSB      : constant Register_Addresss := 16#29#;
   OUT_Y_LSB      : constant Register_Addresss := 16#2A#;
   OUT_Y_MSB      : constant Register_Addresss := 16#2B#;
   OUT_Z_LSB      : constant Register_Addresss := 16#2C#;
   OUT_Z_MSB      : constant Register_Addresss := 16#2D#;

   Device_Address : constant I2C_Address := 16#32#;

end LSM303AGR;
