with Libusb_Thin;
with Ada.Text_IO;
with Interfaces.C;
with Interfaces;
with Interfaces.C.Strings;
with System;
procedure Usb_Test is
   use Libusb_Thin;
   use Ada.Text_IO;
   use Interfaces.C;
   use Interfaces;
   use Interfaces.C.Strings;
   

   Busses         : Usb_Bus_Type_Access;
   Current_Bus    : Usb_Bus_Type_Access;
   Ret_Val        : Int;
   Current_Device : Usb_Device_Type_Access;
   Driver_Name : String(1 .. 256);
   Driver_Name_Ptr : System.Address := Driver_Name'Address;
begin
  Usb_Init;
  Ret_Val := Usb_Find_Busses;
  Put_Line("Usb_Find_Busses returns:" & Int'Image(Ret_Val));
  
  Ret_Val := Usb_Find_Devices;
  Put_Line("Usb_Find_Devices returns:" & Int'Image(Ret_Val));
  
  Busses := Usb_Get_Busses;
  
  Current_Bus := Busses;
  -- Go through every bus
  while Current_Bus.Next /= null loop
     Current_Device := Current_Bus.Devices;
     -- And every device on the bus
     while Current_Device /= null loop
	--Debug_Descriptor(Current_Device.Descriptor);
	Put("Found  device at address");
	Put_Line(Unsigned_16'Image(Current_Device.Descriptor.Vendor_ID));
	
	Current_Device := Current_Device.Next;
     end loop;
     Current_Bus := Current_Bus.Next;
  end loop;
end Usb_Test;
