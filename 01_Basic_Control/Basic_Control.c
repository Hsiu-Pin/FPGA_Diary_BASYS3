
// ====================================================================
// - init_platform()
// This function is defined in platform.c file 
//and permit to activate cache memory and standard input/output.
// ====================================================================
// - XGpio_Config
// This typedef contains configuration information for the device.
// u16 	    DeviceId     : Unique ID of device.
// UINTPTR 	BaseAddress  : Device base address.
// int 	InterruptPresent : Are interrupts supported in h/w.
// int 	IsDual           : Are 2 channels supported in h/w.
// ====================================================================
// - XGpio
// The XGpio driver instance data.
// The user is required to allocate a variable of this type for every GPIO 
// device in the system. A pointer to a variable of this type is then 
// passed to the driver API functions.
// UINTPTR 	BaseAddress  : Device base address.
// u32 	IsReady          : Device is initialized and ready.
// int 	InterruptPresent : Are interrupts supported in h/w.
// int 	IsDual           : Are 2 channels supported in h/w.
// ====================================================================
// - XGpio_LookupConfig
// Lookup the device configuration based on the unique device ID (Address).
// The table ConfigTable contains the configuration info for each device in 
// the system.
// Parameters: DeviceId: is the device identifier to lookup.
// Returns: A pointer of data type XGpio_Config which points to the device 
// configuration if DeviceID is found. NULL if DeviceID is not found.
// ====================================================================
// - XGpio_CfgInitialize
// Initialize the XGpio instance provided by the caller based on the given
// configuration data.
// Nothing is done except to initialize the InstancePtr.
// Parameters: 
//   - InstancePtr: is a pointer to an XGpio instance. The memory 
//     the pointer references must be pre-allocated by the caller. Further 
//     calls to manipulate the driver through the XGpio API must be 
//     made with this pointer.
//   - Config:	is a reference to a structure containing information about  
//     a specific GPIO device. This function initializes an InstancePtr 
//     object for a specific device specified by the contents of Config. 
//     This function can initialize multiple instance objects with the use 
//     of multiple calls giving different Config information on each call.
//   - EffectiveAddr: is the device base address in the virtual memory 
//     address space. The caller is responsible for keeping the address 
//     mapping from EffectiveAddr to the device physical base address 
//     unchanged once this function is invoked. Unexpected errors may occur 
//     if the address mapping changes after this function is called. If 
//     address translation is not used, use Config->BaseAddress for this 
//     parameters, passing the physical address instead.
//     Returns: XST_SUCCESS: if the initialization is successful.
// ====================================================================
// - XGpio_SetDataDirection
// Set the input/output direction of all discrete signals for the specified 
// GPIO channel.
// Parameters: 
//   - InstancePtr: is a pointer to an XGpio instance to be worked on.
//   - Channel:	contains the channel of the GPIO (1 or 2) to operate on.
//   - DirectionMask: is a bitmask specifying which discretes are input and 
//     which are output. Bits set to 0/1 are output/input.
// ====================================================================
// - XGpio_DiscreteRead
// Read state of discretes for the specified GPIO channel.
// Parameters: 
//   - InstancePtr: is a pointer to an XGpio instance to be worked on.
//   - Channel:	contains the channel of the GPIO (1 or 2) to operate on.
// Returns: Current copy of the discretes register. 
// Note: The hardware must be built for dual channels if this function is 
// used with any channel other than 1. Otherwise, this function will assert.

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

#include "sleep.h"

#include "xparameters.h"
#include "XGpio.h."
#include "xil_types.h"

// Defined in xparameters.h
// GPIO 0
#define SWT_ID XPAR_XGPIO_0_BASEADDR
// GPIO 1
#define BTN_ID XPAR_XGPIO_1_BASEADDR
// GPIO 2
#define LED_ID XPAR_XGPIO_2_BASEADDR

int main()
{
    init_platform();

	XGpio_Config *cfg_ptr;

	XGpio swt_device;
	XGpio led_device;
	XGpio btn_device;

	u32 swt_data;
	u32 btn_data;
	u32 led_data;
 
	xil_printf("Entered function main\r\n");

  // Initialize LED Device
	cfg_ptr = XGpio_LookupConfig(LED_ID);
	XGpio_CfgInitialize(&led_device, cfg_ptr, cfg_ptr->BaseAddress);
 
	// Initialize Button Device
	cfg_ptr = XGpio_LookupConfig(BTN_ID);
	XGpio_CfgInitialize(&btn_device, cfg_ptr, cfg_ptr->BaseAddress);

	// Initialize Switch Device
	cfg_ptr = XGpio_LookupConfig(SWT_ID);
	XGpio_CfgInitialize(&swt_device, cfg_ptr, cfg_ptr->BaseAddress);
 
	// Set Tristate
	XGpio_SetDataDirection(&btn_device, 1, 0b1111); // 4-bit bottons
	XGpio_SetDataDirection(&led_device, 1, 0b1111111111111111); // 16-bit LEDs
	XGpio_SetDataDirection(&swt_device, 1, 0b1111111111111111); // 16-bit Switches

	while (1) {
        swt_data = XGpio_DiscreteRead(&swt_device, SWT_CHANNEL);
        btn_data = XGpio_DiscreteRead(&btn_device, BTN_CHANNEL);
        if(btn_data!=0){
            led_data = swt_data;
        }else{
            led_data = 0b0000000000000000;
        }
        XGpio_DiscreteWrite(&led_device, LED_CHANNEL, led_data);
	}

  cleanup_platform();
  return 0;
}
