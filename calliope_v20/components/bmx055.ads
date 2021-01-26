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

with HAL;        use HAL;
with HAL.I2C;    use HAL.I2C;
with Interfaces; use Interfaces;


package BMX055 is

   type BMX055_Accelerometer (Port : not null Any_I2C_Port)
   is tagged limited private;

   procedure Soft_Reset (This : BMX055_Accelerometer);

   function Check_Device_Id (This : BMX055_Accelerometer) return Boolean;

   subtype Temp_Celsius is Integer_8;

   function Read_Temperature
     (This : BMX055_Accelerometer) return Temp_Celsius;

private
   type BMX055_Accelerometer (Port : not null Any_I2C_Port) is tagged limited
     null record;

   type Register_Addresss is new UInt8;


   Device_Id      : constant := 16#FA#;

   Who_Am_I       : constant Register_Addresss := 16#00#;

   ACCD_TEMP      : constant Register_Addresss := 16#08#;
   BGW_SOFTRESET  : constant Register_Addresss := 16#14#;

   Device_Address : constant I2C_Address := 16#30#;

end BMX055;
