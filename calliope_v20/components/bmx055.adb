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
package body BMX055  is

   function Read_Register (This : BMX055_Accelerometer'Class;
                           Addr : Register_Addresss) return UInt8;

   procedure Write_Register (This : BMX055_Accelerometer'Class;
                             Addr : Register_Addresss;
                             Val  : UInt8);

   -------------------
   -- Read_Register --
   -------------------

   function Read_Register (This : BMX055_Accelerometer'Class;
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

   procedure Write_Register (This : BMX055_Accelerometer'Class;
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

   -------------
   --  Reset  --
   -------------

   procedure Soft_Reset (This : BMX055_Accelerometer) is
   begin
      Write_Register(This, BGW_SOFTRESET, 16#B6#);
   end Soft_Reset;

   -----------------------
   --  Check_Device_Id  --
   -----------------------

   function Check_Device_Id (This : BMX055_Accelerometer) return Boolean is
      Data   : I2C_Data (1 .. 1);
      Status : I2C_Status;
   begin
      This.Port.Mem_Read (Addr          => Device_Address,
                          Mem_Addr      => UInt16 (Who_Am_I),
                          Mem_Addr_Size => Memory_Size_8b,
                          Data          => Data,
                          Status        => Status);
      if Status = Ok then
         return Data (1) = Device_Id;
      else
         return False;
      end if;
   end Check_Device_Id;

   ------------------------
   --  Read_Temperature  --
   ------------------------

   function To_Temperature is new Ada.Unchecked_Conversion (UInt8, Integer_8);

   function Read_Temperature
     (This : BMX055_Accelerometer) return Temp_Celsius is
      Data   : UInt8;
   begin
      Data := Read_Register (This, ACCD_TEMP);
      return  23 + (To_Temperature (Data) / 2);
   end Read_Temperature;

end BMX055;
