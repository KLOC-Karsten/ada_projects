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
--  Initial contribution by: Lancaster University
--  https://github.com/lancaster-university/microbit-dal
--  class MicroBitLightSensor

with MicroBit.IOs; use MicroBit.IOs;
with nRF.Device;
with nRF.GPIO; use nRF.GPIO;
with MicroBit.Time;

package body Light_Sensor  is

   Row_Pts : constant array (1..3) of nRF.GPIO.GPIO_Point :=
     (nRF.Device.P13, nRF.Device.P14, nRF.Device.P15);

   Light_Sensor_Min : constant Integer := 100;
   Light_Sensor_Max : constant Integer := 200;

   ---------------------
   --  Disable_Rows   --
   ---------------------

   procedure Disable_Rows is
      Conf : GPIO_Configuration;
      Pt   : GPIO_Point;
   begin
      Conf.Mode         := Mode_Out;
      Conf.Resistors    := No_Pull;
      Conf.Input_Buffer := Input_Buffer_Connect;
      Conf.Sense        := Sense_Disabled;

      for Index in Row_Pts'First .. Row_Pts'Last loop
         Pt := Row_Pts (Index);
         Pt.Configure_IO (Conf);
         Pt.Clear;
      end loop;
   end Disable_Rows;

   --------------
   --  Limit   --
   --------------

   function Limit(Value, Min, Max: Integer) return Integer is
   begin
      if Value < Min then
         return Min;
      elsif Value > Max then
         return Max;
      else
         return Value;
      end if;
   end Limit;

   ------------------
   --  Normalize   --
   ------------------

   function Normalize
     (Value: Integer;
      In_Min, In_Max : Integer;
      Out_Min, Out_Max : Integer) return Integer is
   begin
      return Out_Min +
        ( (((Value - In_Min) * (Out_Max - Out_min)) /
          (In_Max - In_Min)));
   end Normalize;

   --------------------------
   --  Read_Analog_Value   --
   --------------------------

   function Read_Analog_Value return Luminosity is
      Raw : MicroBit.IOs.Analog_Value;
      Inverted : Integer;
      Normalized : Integer;
      Col_Pin : constant Pin_Id := 3; -- Col 1
   begin
      MicroBit.IOs.Set (Col_Pin, True);
      MicroBit.Time.Delay_Ms(1);
      Raw := MicroBit.IOs.Analog (Col_Pin);
      MicroBit.IOs.Set (Col_Pin, True);

      Inverted := Limit (Integer (Raw), Light_Sensor_Min, Light_Sensor_Max);
      Inverted := (Light_Sensor_Max - Inverted) + Light_Sensor_Min;

      Normalized := Normalize (Value => Inverted,
                               In_Min => Light_Sensor_Min,
                               In_Max => Light_Sensor_Max,
                               Out_Min => Integer (Luminosity'First),
                               Out_Max => Integer (Luminosity'Last));

      return Luminosity (Normalized);

   end Read_Analog_Value;

   -------------
   --  Read   --
   -------------
   function Read return Luminosity is
   begin
      Disable_Rows;
      MicroBit.Time.Delay_Ms(5);
      return Read_Analog_Value;
   end Read;

end Light_Sensor;
