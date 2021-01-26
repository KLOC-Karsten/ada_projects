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
--
--
--  Initial contribution by:
--  AdaCore
--  Ada Drivers Library (https://github.com/AdaCore/Ada_Drivers_Library)
--  Package: MMA8653

with Ada.Unchecked_Conversion;
package body LSM303AGR  is

   function Read_Register (This : LSM303AGR_Accelerometer'Class;
                           Addr : Register_Addresss) return UInt8;

   procedure Write_Register (This : LSM303AGR_Accelerometer'Class;
                             Addr : Register_Addresss;
                             Val  : UInt8);
   -------------------
   -- Read_Register --
   -------------------

   function Read_Register (This : LSM303AGR_Accelerometer'Class;
                           Addr : Register_Addresss) return UInt8
   is
      Data   : I2C_Data (1 .. 1);
      Status : I2C_Status;
   begin
      This.Port.Mem_Read (Addr          => Device_Address,
                          Mem_Addr      => UInt16 (Addr),
                          Mem_Addr_Size => Memory_Size_8b,
                          Data          => Data,
                          Status        => Status);

      if Status /= Ok then
         --  No error handling...
         raise Program_Error;
      end if;
      return Data (Data'First);
   end Read_Register;

   --------------------
   -- Write_Register --
   --------------------

   procedure Write_Register (This : LSM303AGR_Accelerometer'Class;
                             Addr : Register_Addresss;
                             Val  : UInt8)
   is
      Status : I2C_Status;
   begin
      This.Port.Mem_Write (Addr          => Device_Address,
                           Mem_Addr      => UInt16 (Addr),
                           Mem_Addr_Size => Memory_Size_8b,
                           Data          => (1 => Val),
                           Status        => Status);

      if Status /= Ok then
         --  No error handling...
         raise Program_Error;
      end if;
   end Write_Register;

   procedure Configure (This                : in out LSM303AGR_Accelerometer;
                        Dyna_Range          : Dynamic_Range;
                        Rate                : Data_Rate) is
   begin

      --  Place the device into normal (10 bit) mode, with all axes enabled at
      --  the nearest supported data rate to that requested.
      Write_Register (This, CTRL_REG1_A, Rate'Enum_Rep +  16#07#);

      --  Enable the DRDY1 interrupt on INT1 pin.
      Write_Register (This, CTRL_REG3_A, 16#10#);

      --  Select the g range to that requested, using little endian data format
      --  and disable self-test and high rate functions.
      Write_Register (This, CTRL_REG4_A, 16#80# + Dyna_Range'Enum_Rep);

   end Configure;

   ---------------------
   -- Check_Device_Id --
   ---------------------

   function Check_Device_Id (This : LSM303AGR_Accelerometer) return Boolean is
   begin
      return Read_Register (This, Who_Am_I) = Device_Id;
   exception
      when Program_Error => return False;
   end Check_Device_Id;


   ---------------------------------
   --  Enable_Temperature_Sensor  --
   ---------------------------------

   procedure Enable_Temperature_Sensor
     (This : LSM303AGR_Accelerometer; Enabled : Boolean)
   is
      Val : UInt8 := 0;
   begin
      if Enabled then
         Val := 2#1100_0000#;
      end if;
      Write_Register (This, TEMP_CFG_REG_A, Val);
   end Enable_Temperature_Sensor;

   function Get_Temp_Config
     (This : LSM303AGR_Accelerometer) return Uint8
   is
   begin
      return Read_Register (This, TEMP_CFG_REG_A);
   end Get_Temp_Config;

   function Get_Ctrl_Reg_4
     (This : LSM303AGR_Accelerometer) return Uint8
   is
   begin
      return Read_Register (This, CTRL_REG4_A);
   end Get_Ctrl_Reg_4;

   ------------------------
   --  Read_Temperature  --
   ------------------------

   function To_Temperature is new Ada.Unchecked_Conversion (UInt8, Integer_8);

   function Read_Temperature
     (This : LSM303AGR_Accelerometer) return Temp_Celsius
   is
      Status : I2C_Status;
      Data   : I2C_Data (1 .. 2);
   begin
      This.Port.Mem_Read (Addr          => Device_Address,
                          Mem_Addr      => UInt16 (OUT_TEMP_L_A + 16#80#),
                          Mem_Addr_Size => Memory_Size_8b,
                          Data          => Data,
                          Status        => Status);

      if Status /= Ok then
         --  No error handling...
         raise Program_Error;
      end if;

      return  Temp_Celsius (25 + To_Temperature (Data (2)));
   end Read_Temperature;



   ---------------
   -- Read_Data --
   ---------------

   function To_Axis_Data is new Ada.Unchecked_Conversion (UInt10, Axis_Data);

   function Read_Data (This : LSM303AGR_Accelerometer) return All_Axes_Data is
      function Convert (MSB, LSB : UInt8) return Axis_Data;

      -------------
      -- Convert --
      -------------

      function Convert (MSB, LSB : UInt8) return Axis_Data is
         Tmp : UInt10;
      begin
         Tmp := UInt10 (Shift_Right (LSB, 6));
         Tmp := Tmp or UInt10 (MSB) * 2**2;
         return To_Axis_Data (Tmp);
      end Convert;

      Status : I2C_Status;
      Data   : I2C_Data (1 .. 7);
      Ret    : All_Axes_Data;
   begin
      This.Port.Mem_Read (Addr          => Device_Address,
                          Mem_Addr      => UInt16 (DATA_STATUS + 16#80#),
                          Mem_Addr_Size => Memory_Size_8b,
                          Data          => Data,
                          Status        => Status);

      if Status /= Ok then
         --  No error handling...
         raise Program_Error;
      end if;
      Ret.X := Convert (Data (3), Data (2));
      Ret.Y := Convert (Data (5), Data (4));
      Ret.Z := Convert (Data (7), Data (6));
      return Ret;
   end Read_Data;

end LSM303AGR;
