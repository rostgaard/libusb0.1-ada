--------------------------------------------------------------------------------
--                                                                            --
-- Libusb 0.1 bindings for Ada                                                --
-- Version: initial release                                                   --
-- Author: Kim Rostgaard Christensen (krc@retrospekt.dk)                      --
--                                                                            --
-- This file provides the needed specifications for using the the legacy usb  --
-- library (0.1). Remember to link your application to libusb by applying the --
-- -lusb switch to the linker                                                 --
--                                                                            --
-- Reading material:                                                          --
-- [1] http://www.beyondlogic.org/usbnutshell/usb1.shtml                      --
--                                                                            --
--------------------------------------------------------------------------------


with Interfaces.C;
with Interfaces;
with Interfaces.C.Strings;
with Interfaces.C.Pointers;
with System;
package Libusb_Thin is
   use Interfaces.C;
   use Interfaces;
   
   
   -- USB spec information
   -- This is all stuff grabbed from various USB specs and is pretty much
   -- not subject to change
   
   --    Device and/or Interface Class codes
   USB_CLASS_PER_INTERFACE : constant :=  0; -- For DeviceClass
   USB_CLASS_AUDIO	   : constant :=  1;
   USB_CLASS_COMM	   : constant :=  2;
   USB_CLASS_HID           : constant :=  3;
   USB_CLASS_PRINTER	   : constant :=  7;
   USB_CLASS_PTP           : constant :=  6;
   USB_CLASS_MASS_STORAGE  : constant :=  8;
   USB_CLASS_HUB           : constant :=  9;
   USB_CLASS_DATA          : constant := 10;
   USB_CLASS_VENDOR_SPEC   : constant := 16#ff#;
 

   --    Descriptor types
   USB_DT_DEVICE    : constant := 16#01#;
   USB_DT_CONFIG    : constant := 16#02#;
   USB_DT_STRING    : constant := 16#03#;
   USB_DT_INTERFACE : constant := 16#04#;
   USB_DT_ENDPOINT  : constant := 16#05#;

   USB_DT_HID       : constant := 16#21#;
   USB_DT_REPORT    : constant := 16#22#;
   USB_DT_PHYSICAL  : constant := 16#23#;
   USB_DT_HUB       : constant := 16#29#;


   --    Descriptor sizes per descriptor type

   USB_DT_DEVICE_SIZE         : constant := 18;
   USB_DT_CONFIG_SIZE         : constant :=  9;
   USB_DT_INTERFACE_SIZE      : constant :=  9;
   USB_DT_ENDPOINT_SIZE       : constant :=  7;
   USB_DT_ENDPOINT_AUDIO_SIZE : constant :=  9;	-- Audio extension
   USB_DT_HUB_NONVAR_SIZE     : constant :=  7;
     
     
   USB_ENDPOINT_ADDRESS_MASK : constant := 16#0f#; -- in bEndpointAddress
   USB_ENDPOINT_DIR_MASK     : constant := 16#80#;
   
   USB_ENDPOINT_TYPE_MASK        : constant :=16#03#;  -- in bmAttributes
   USB_ENDPOINT_TYPE_CONTROL     : constant := 0;
   USB_ENDPOINT_TYPE_ISOCHRONOUS : constant := 1;
   USB_ENDPOINT_TYPE_BULK        : constant := 2;
   USB_ENDPOINT_TYPE_INTERRUPT   : constant := 3;

   -- Interface descriptor
   USB_MAXINTERFACES : constant :=  32;
   USB_MAXENDPOINTS  : constant :=  32;
   USB_MAXCONFIG     : constant :=   8;
   USB_MAXALTSETTING : constant := 128;	-- Hard limit
     
   -- Standard requests
   USB_REQ_GET_STATUS        : constant := 16#00#;
   USB_REQ_CLEAR_FEATURE     : constant := 16#01#;
   -- 16#02# is reserved
   USB_REQ_SET_FEATURE       : constant := 16#03#;
   -- 16#04# is reserved
   USB_REQ_SET_ADDRESS       : constant := 16#05#;
   USB_REQ_GET_DESCRIPTOR    : constant := 16#06#;
   USB_REQ_SET_DESCRIPTOR    : constant := 16#07#;
   USB_REQ_GET_CONFIGURATION : constant := 16#08#;
   USB_REQ_SET_CONFIGURATION : constant := 16#09#;
   USB_REQ_GET_INTERFACE     : constant := 16#0A#;
   USB_REQ_SET_INTERFACE     : constant := 16#0B#;
   USB_REQ_SYNCH_FRAME       : constant := 16#0C#;

     
   --TODO
   --  USB_TYPE_STANDARD		(0x00 << 5)
   --  USB_TYPE_CLASS			(0x01 << 5)
   --  USB_TYPE_VENDOR			(0x02 << 5)
   --  USB_TYPE_RESERVED		(0x03 << 5)

   USB_RECIP_DEVICE    : constant := 16#00#;
   USB_RECIP_INTERFACE : constant := 16#01#;
   USB_RECIP_ENDPOINT  : constant := 16#02#;
   USB_RECIP_OTHER     : constant := 16#03#;

   -- Various libusb API related stuff
   
   USB_ENDPOINT_IN  : constant := 16#80#;
   USB_ENDPOINT_OUT : constant := 16#00#;

   -- Error codes
   USB_ERROR_BEGIN : constant := 500000;
     
   -- Type definitions
   type Usb_Bus_Type;
   type Usb_Bus_Type_Access is access all Usb_Bus_Type;
   type Usb_Device_Type;
   type Usb_Device_Type_Access is access all Usb_Device_Type;
   type File_Name_Type is array ( 1 .. 4097) of Char;
   type Device_Descriptor_Type;
   type Device_Descriptor_Type_Access is access all Device_Descriptor_Type;
   
   -- Defined in an internal OS struct. All we do is pass the address around
   -- so we don't really the to know the members anyway
   type Usb_Device_Handle_Type is new System.Address;

   -- ------------ --
   -- Record Types --
   -- ------------ --
   
   -- TODO change String type
   type Usb_Bus_Type Is 
      record
	 Next        : Usb_Bus_Type_Access;
	 Previous    : Usb_Bus_Type_Access;
	 Dirname     : String(1 ..4097);
	 Devices     : Usb_Device_Type_Access;
	 Location    : Unsigned_32;
	 Root_Device : Usb_Device_Type_Access;
      end record;
   
   type Device_Descriptor_Type is
      record
	 B_Length            : Unsigned_8; -- u_int8_t  bLength;
	 B_Descriptor_Type   : Unsigned_8; -- u_int8_t  bDescriptorType;

	 Bcd_USB             : Unsigned_16;	 -- u_int16_t bcdUSB;
	 B_Device_Class      : Unsigned_8; -- u_int8_t  bDeviceClass;
	 B_Device_Sub_Class  : Unsigned_8; -- u_int8_t  bDeviceSubClass;
	 B_Device_Protocol   : Unsigned_8; -- u_int8_t  bDeviceProtocol;
	 B_Max_Packet_Size   : Unsigned_8; -- u_int8_t  bMaxPacketSize0;
	 Vendor_ID           : Unsigned_16; -- u_int16_t idVendor;
	 Product_ID          : Unsigned_16; -- u_int16_t idProduct;
	 Bcd_Device          : Unsigned_16; -- u_int16_t bcdDevice;
	 I_Manufacturer      : Unsigned_8; -- u_int8_t  iManufacturer;
	 I_Product           : Unsigned_8; -- u_int8_t  iProduct;
	 I_Serial_Number     : Unsigned_8; -- u_int8_t  iSerialNumber;
	 B_Num_Configs       : Unsigned_8; -- u_int8_t  bNumConfigurations
      end record;
	   
   
   -- TODO Change from string to char array - or dedicated type
   -- struct usb_device
   -- PATH_MAX is defined in linux/limits.h (4096 including nul)
   type Usb_Device_Type is 
      record 
	 Next         : Usb_Device_Type_Access;
	 Previous     : Usb_Device_Type_Access;
	 Filename     : String(1 ..4097); -- char filename[PATH_MAX + 1];
	 USB_Bus      : USB_Bus_Type_Access; -- struct usb_bus *bus;
	 Descriptor   : Device_Descriptor_Type;-- struct usb_device_descriptor
	                                       -- descriptor;
	 Config       : System.Address; -- struct usb_config_descriptor *config;
	 Dev_Ptr      : System.Address; -- Void *dev;
	 Device_Number: Unsigned_8; -- U_Int8_T devnum;
	 Number_Of_Children : Unsigned_Char; -- Unsigned char num_children;
	 Children : System.Address; --struct usb_device **children;
      end record;
   
   type Usb_Configuration_Descriptor is
      record
	 B_Length               : Unsigned_8 ;
	 B_Descriptor_Type      : Unsigned_8;
	 W_Total_Length         : Unsigned_16;
	 B_Number_Of_Interfaces : Unsigned_8;
	 B_Configuration_Value  : Unsigned_8;
	 I_Configuration        : Unsigned_8;
	 BM_Attributes          : Unsigned_8;
	 Max_Power              : Unsigned_8;
	 -- struct usb_interface *interface;
	 -- unsigned char *extra;	/* Extra descriptors */
	 -- int extralen;
	 
      end record;
   
   
   -- ------------- --
   -- Core features --
   -- ------------- --
   
   -- Just like the name implies, usb_init sets up some internal structures. 
   -- usb_init must be called before any other libusb functions.
   procedure Usb_Init;
   pragma Import (C, Usb_Init, "usb_init");
   
   -- int usb_find_busses(void);
   -- usb_find_busses will find all of the busses on the system. 
   -- Returns the number of changes since previous call to this function
   -- (total of new busses and busses removed).
   function Usb_Find_Busses return Int;
   pragma Import (C, Usb_Find_Busses, "usb_find_busses");
     
   -- usb_find_devices -- Find all devices on all USB devices
   -- int usb_find_devices(void);
   --    usb_find_devices will find all of the devices on each bus. 
   -- This should be called after usb_find_busses. 
   -- Returns the number of changes since the previous call to this function
   -- (total of new device and devices removed).
   function Usb_Find_Devices return Int;
   pragma Import (C, Usb_Find_Devices, "usb_find_devices");
     
   -- usb_get_busses -- Return the list of USB busses found
   -- struct usb_bus *usb_get_busses(void);
   -- usb_get_busses simply returns the value of the global variable 
   -- usb_busses. This was implemented for those languages that support C 
   -- calling convention and can use shared libraries, but don't support C 
   -- global variables (like Delphi).
   function Usb_Get_Busses return Usb_Bus_Type_Access;
   pragma Import (C, Usb_Get_Busses, "usb_get_busses");
   
   
   --  void usb_set_debug(int level);
   -- TODO enumerate levels
   procedure Usb_Set_Debug(Level : Int);
   pragma Import (C, Usb_Set_Debug, "usb_set_debug");
   
   -- --------------- --
   -- Device features --
   -- --------------- --
   
   -- Opens a USB device
   -- usb_dev_handle *usb_open(struct *usb_device dev);
   -- usb_open is to be used to open up a device for use. usb_open must be 
   -- called before attempting to perform any operations to the device. 
   -- Returns a handle used in future communication with the device.
   function Usb_Open 
     (Device : Usb_Device_Type_Access) return Usb_Device_Handle_Type;
   pragma Import (C, Usb_Open, "usb_open");
   
   -- Closes a USB device
   -- int usb_close(usb_dev_handle *dev);
   -- usb_close closes a device opened with usb_open. 
   -- No further operations may be performed on the handle after 
   -- usb_close is called. Returns 0 on success or < 0 on error.
   function Usb_Close 
     (Usb_Device_Handle : Usb_Device_Handle_Type ) return Int;
   pragma Import (C, Usb_Close, "usb_close");
   
   -- Sets the active configuration of a device
   -- int usb_set_configuration(usb_dev_handle *dev, int configuration);
   -- usb_set_configuration sets the active configuration of a device. 
   -- The configuration parameter is the value as specified in the descriptor 
   -- field bConfigurationValue. Returns 0 on success or < 0 on error.
   function Usb_Set_Configuration
     (USB_Device_Handle : USB_Device_Handle_Type; 
      Configuration     : Int) return Int;
   pragma Import (C, Usb_Set_Configuration, "usb_set_configuration");
   
   -- Sets the active alternate setting of the current interface
   -- int usb_set_altinterface(usb_dev_handle *dev, int alternate);
   -- usb_set_altinterface sets the active alternate setting of the current 
   -- interface. The alternate parameter is the value as specified in the 
   -- descriptor field bAlternateSetting. 
   -- Returns 0 on success or < 0 on error.
   function Usb_Set_Altinterface
     (USB_Device_Handle : USB_Device_Handle_Type; Alternative : Int) return Int;
   pragma Import (C, Usb_Set_Altinterface, "usb_set_altinterface");  
   
   -- Resets state for an endpoint
   -- int usb_resetep(usb_dev_handle *dev, unsigned int ep);
   -- usb_resetep resets all state (like toggles) for the specified endpoint. 
   -- The ep parameter is the value specified in the descriptor field 
   -- bEndpointAddress. 
   -- Returns 0 on success or < 0 on error.
   -- Deprecated: usb_resetep is deprecated. You probably want to use 
   -- usb_clear_halt.
   function Usb_Reset_End_Point
     (USB_Device_Handle : USB_Device_Handle_Type; 
      End_Point         : Unsigned) return Int;
   pragma Import(C, Usb_Reset_End_Point,"usb_resetep");
	
   -- Clears any halt status on an endpoint
   -- int usb_clear_halt(usb_dev_handle *dev, unsigned int ep);
   -- usb_clear_halt clears any halt status on the specified endpoint. 
   -- The ep parameter is the value specified in the descriptor field 
   -- bEndpointAddress. 
   -- Returns 0 on success or < 0 on error.
   function Usb_Clear_Halt_Status
     (USB_Device_Handle : USB_Device_Handle_Type; 
      End_Point         : Unsigned) return Int;
   pragma Import (C,Usb_Clear_Halt_Status,"usb_clear_halt");
  
   -- Resets a device
   -- int usb_reset(usb_dev_handle *dev);
   -- usb_reset resets the specified device by sending a RESET down the port it
   -- is connected to.
   -- Returns 0 on success or < 0 on error.
   -- Causes re-enumeration: After calling usb_reset, the device will need to 
   -- re-enumerate and thusly, requires you to find the new device and open a 
   -- new handle. The handle used to call usb_reset will no longer work.
   function Usb_Reset(USB_Device_Handle : USB_Device_Handle_Type) return Int;
   pragma Import(C,Usb_Reset,"usb_reset");
   
   -- Claim an interface of a device
   -- int usb_claim_interface(usb_dev_handle *dev, int interface);
   -- usb_claim_interface claims the interface with the Operating System.
   -- The interface parameter is the value as specified in the descriptor field
   -- bInterfaceNumber.
   -- Returns 0 on success or < 0 on error.
   -- Must be called!: usb_claim_interface must be called before you perform 
   -- any operations related to this interface (like usb_set_altinterface, 
   -- usb_bulk_write, etc).
   --  Return Codes:
   --  code	description
   --  -EBUSY	Interface is not available to be claimed (-16)
   --  -ENOMEM	Insufficient memory
   function Usb_Claim_Interface
     (USB_Device_Handle : USB_Device_Handle_Type; 
      USB_Interface     : Int) return Int;
   pragma Import (C,Usb_Claim_Interface,"usb_claim_interface");
   
   -- int usb_release_interface(usb_dev_handle *dev, int interface);
   -- usb_release_interface releases an interface previously claimed with 
   -- usb_claim_interface.
   -- The interface parameter is the value as specified in the descriptor field 
   -- bInterfaceNumber. Returns 0 on success or < 0 on error.
   function Usb_Release_Interface
     (USB_Device_Handle : USB_Device_Handle_Type; 
      USB_Interface     : Int) return Int;
   pragma Import(C,Usb_Release_Interface,"usb_release_interface");
  
   -- ----------------- --
   -- Control Transfers --
   -- ----------------- --
   
   -- Send a control message to a device
   -- int usb_control_msg(usb_dev_handle *dev, int requesttype, int request, 
   -- int value, int index, char *bytes, int size, int timeout);
   -- usb_control_msg performs a control request to the default control pipe on
   -- a device.
   -- The parameters mirror the types of the same name in the USB specification.
   -- Returns number of bytes written/read or < 0 on error.
   function 
     Usb_Control_Msg (USB_Device_Handle : USB_Device_Handle_Type;
		      Request_Type      : Int;
		      Request           : Int;
		      Value             : Int;
		      Index             : Int;
		      Bytes             : System.Address;
		      Size              : Int;
		      Timeout           : Int) return Int;
   pragma Import (C,Usb_Control_Msg,"usb_control_msg");

   -- Retrieves a string descriptor from a device
   -- int usb_get_string(usb_dev_handle *dev, int index, int langid, char *buf,
   -- size_t buflen);
   -- usb_get_string retrieves the string descriptor specified by index and 
   -- langid from a device. The string will be returned in Unicode as specified
   -- by the USB specification. 
   -- Returns the number of bytes returned in buf or < 0 on error.
   function Usb_Get_String(USB_Device_Handle : USB_Device_Handle_Type;
			   Index             : Int;
			   Langid            : Int;
			   Buffer            : System.Address;
			   Buffer_Size       : Unsigned) return Int;
   pragma Import (C,Usb_Get_String,"usb_get_string");
   
   
   -- Retrieves a string descriptor from a device using the first language
   -- int usb_get_string_simple(usb_dev_handle *dev, int index, char *buf, 
   -- size_t buflen);
   --  usb_get_string_simple is a wrapper around usb_get_string that retrieves 
   -- the string description specified by index in the first language for the 
   -- descriptor and converts it into C style ASCII. Returns number of bytes 
   -- returned in buf or < 0 on error.
   function Usb_Get_String_Simple 
     (USB_Device_Handle : USB_Device_Handle_Type;
      Index             : Int;
      Buffer            : System.Address) return Int;
   pragma Import (C,Usb_Get_String_Simple,"usb_get_string_simple");
   
   
   -- Retrieves a descriptor from a device's default control pipe
   -- int usb_get_descriptor(usb_dev_handle *dev, unsigned char type, 
   -- unsigned char index, void *buf, int size);
   -- usb_get_descriptor retrieves a descriptor from the device identified by 
   -- the type and index of the descriptor from the default control pipe. 
   -- Returns number of bytes read for the descriptor or < 0 on error.
   function Usb_Get_Descriptor 
     (USB_Device_Handle : USB_Device_Handle_Type;
      Device_Type       : Unsigned_Char;
      Index             : Unsigned_Char;
      Buffer            : System.Address;
      Size              : Int) return Int;
   pragma Import (C,Usb_Get_Descriptor,"usb_get_descriptor");
   
   
   -- TODO's
   
   
   -- See usb_get_descriptor_by_endpoint for a function that allows the control
   -- endpoint to be specified.
   -- usb_get_descriptor_by_endpoint -- Retrieves a descriptor from a device
   -- int usb_get_descriptor_by_endpoint(usb_dev_handle *dev, int ep, 
   -- unsigned char type, unsigned char index, void *buf, int size);
   --  usb_get_descriptor_by_endpoint retrieves a descriptor from the device 
   -- identified by the type and index of the descriptor from the control pipe 
   -- identified by ep. Returns number of bytes read for the descriptor or < 0 
   -- on error.
   function Usb_Get_Descriptor_By_Endpoint
     (USB_Device_Handle : USB_Device_Handle_Type;
      End_Point         : Int;
      Device_Type       : Unsigned_Char;
      Index             : Unsigned_Char;
      Buffer            : System.Address;
      Size              : Int) return Int;
   
   -- -------------- --
   -- Bulk Transfers --
   -- -------------- --
   
   -- Write data to a bulk endpoint
   -- int usb_bulk_write(usb_dev_handle *dev, int ep, char *bytes, int size, 
   -- int timeout);
   --  usb_bulk_write performs a bulk write request to the endpoint specified 
   -- by ep. Returns number of bytes written on success or < 0 on error.
   function Usb_Bulk_Write
     (USB_Device_Handle : USB_Device_Handle_Type;
      End_Point         : Int;
      Data              : System.Address;
      Size              : Int;
      Timeout           : int) return Int;
   pragma Import (C,Usb_Bulk_Write,"usb_bulk_write");
   
   
   -- int usb_bulk_read(usb_dev_handle *dev, int ep, char *bytes, int size, 
   -- int timeout);
   --  usb_bulk_read performs a bulk read request to the endpoint specified by 
   -- ep. Returns number of bytes read on success or < 0 on error.
   function Usb_Bulk_Read
     (USB_Device_Handle : USB_Device_Handle_Type;
      End_Point         : Int;
      Data              : System.Address;
      Size              : Int;
      Timeout           : int) return Int;
   pragma Import (C,Usb_Bulk_Read,"usb_bulk_read");

  
   -- ------------------- --
   -- Interrupt Transfers --
   -- ------------------- --
   
   -- Write data to an interrupt endpoint
   -- int usb_interrupt_write(usb_dev_handle *dev, int ep, char *bytes, 
   -- int size, int timeout);
   -- usb_interrupt_write performs an interrupt write request to the endpoint 
   -- specified by ep.
   -- Returns number of bytes written on success or < 0 on error.
   function Usb_Interrupt_Write 
     (USB_Device_Handle : USB_Device_Handle_Type;
      End_Point : Int;
      Data      : System.Address; -- Raw data
      Size      : Int;            -- Number of bytes
      Timeout   : Int) return Int;
   pragma Import(C,Usb_Interrupt_Write,"usb_interrupt_write");

   
   -- Read data from a interrupt endpoint
   -- int usb_interrupt_read(usb_dev_handle *dev, int ep, char *bytes, 
   -- int size, int timeout);
   -- usb_interrupt_read performs a interrupt read request to the endpoint 
   -- specified by ep. 
   -- Returns number of bytes read on success or < 0 on error.
   function Usb_Interrupt_Read 
     (USB_Device_Handle : USB_Device_Handle_Type;
      End_Point : Int;
      Data      : System.Address; -- Raw data
      Size      : Int;            -- Number of bytes
      Timeout   : Int) return Int;
   pragma Import(C,Usb_Interrupt_Read,"usb_interrupt_read");
   
   
   -- ---------------------- --
   -- Non-Portable functions --
   -- ---------------------- --
   -- These functions are non portable. 
   -- They may expose some part of the USB API on one OS or perhaps a couple, 
   -- but not all. They are all marked with the string _np at the end of the 
   -- function name. A C preprocessor macro will be defined if the function is 
   -- implemented. The form is LIBUSB_HAS_ prepended to the function name, 
   -- without the leading "usb_", in all caps.
   -- For example, if usb_get_driver_np is implemented, 
   -- LIBUSB_HAS_GET_DRIVER_NP will be defined.
    
   -- Get driver name bound to interface
   -- int usb_get_driver_np(usb_dev_handle *dev, int interface, char *name, 
   -- int namelen);
   -- This function will obtain the name of the driver bound to the interface 
   -- specified by the parameter interface and place it into the buffer named 
   -- name limited to namelen characters. Returns 0 on success or < 0 on error.
   --  Implemented on Linux only!
   function Usb_Get_Driver_Np 
     (USB_Device_Handle : USB_Device_Handle_Type;
      USB_Interface     : Int;
      Name              : System.Address; -- Should be Chars_Ptr
      Name_Lenght       : Int) return Int;
   pragma Import (C,Usb_Get_Driver_Np,"usb_get_driver_np");
  
   -- Detach kernel driver from interface
   -- int usb_detach_kernel_driver_np(usb_dev_handle *dev, int interface);
   -- This function will detach a kernel driver from the interface specified 
   -- by parameter interface. Applications using libusb can then try claiming 
   -- the interface. 
   -- Returns 0 on success or < 0 on error
   --  Implemented on Linux only!
   function Usb_Detach_Kernel_Driver_Np 
     (USB_Device_Handle : USB_Device_Handle_Type;
      USB_Interface     : Int) return Int;
   pragma Import(C,Usb_Detach_Kernel_Driver_Np,"usb_detach_kernel_driver_np");
   
end Libusb_Thin;
