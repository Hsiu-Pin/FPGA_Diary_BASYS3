/******************************************************************************
* Author: Hsiu-Pin Hsu
* Date: 2024.08.10
******************************************************************************/

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

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

	XGpio_Config *cfg_ptr;

	XGpio swt_device;
	XGpio led_device;
	XGpio btn_device;

	u32 swt_data;
	u32 btn_data;
	u32 led_data;
 
	init_platform();
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
