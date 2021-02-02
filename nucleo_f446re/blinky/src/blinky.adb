
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
--  AdaCore (https://www.adacore.com/)
--  Ada Drivers Library (https://github.com/AdaCore/Ada_Drivers_Library)
--  Packages: Blinky, STM32.Board (for F446ZE, in
--            Ada_Drivers_Library/boards/stm32_common/nucleo_f446ze)

with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);
--  The "last chance handler" is the user-defined routine that is called when
--  an exception is propagated. We need it in the executable, therefore it
--  must be somewhere in the closure of the context clauses.

with STM32.GPIO;        use STM32.GPIO;
with STM32.Device;      use STM32.Device;
with STM32.Board;       use STM32.Board;
with Ada.Real_Time; use Ada.Real_Time;

procedure Blinky is

   Period : constant Time_Span := Milliseconds (500);  -- arbitrary

   Next_Release : Time := Clock;

   User_LED : GPIO_Point renames PA5;

   All_LEDs : GPIO_Points := (1=> User_LED);


begin
   --  Initialize the user LED.
   --  NOTE: DO NOT USE the LED initialization from STM32.Board, since
   --  the version of STM32.Board used here is the F446ZE board, which
   --  has three user LEDs, which are connected differently.
   Enable_Clock (All_LEDs);

   Configure_IO
     (All_LEDs,
      (Mode_Out,
       Resistors   => Floating,
       Output_Type => Push_Pull,
       Speed       => Speed_100MHz));

   --  The connection to the user button is the same though ...
   Configure_User_Button_GPIO;

   loop
      --   Button pressed => User_Button_Point.Set = False!
      if User_Button_Point.Set then
         --  User button not pressed ... toggle the LED
         STM32.GPIO.Toggle (All_LEDs);
      end if;

      Next_Release := Next_Release + Period;
      delay until Next_Release;
   end loop;
end Blinky;
