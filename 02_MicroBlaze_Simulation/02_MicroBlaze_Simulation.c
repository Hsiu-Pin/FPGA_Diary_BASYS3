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
#define SWT_BA XPAR_AXI_GPIO_SWITCHES_BASEADDR
// GPIO 1
#define BTN_BA XPAR_AXI_GPIO_BUTTONS_BASEADDR
// GPIO 2
#define LED_BA XPAR_AXI_GPIO_LEDS_BASEADDR

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
	//xil_printf("Entered function main\r\n");

	// Initialize Switch
	cfg_ptr = XGpio_LookupConfig(SWT_BA);
	XGpio_CfgInitialize(&swt_device, cfg_ptr, cfg_ptr->BaseAddress);

	// Initialize Button
	cfg_ptr = XGpio_LookupConfig(BTN_BA);
	XGpio_CfgInitialize(&btn_device, cfg_ptr, cfg_ptr->BaseAddress);

	// Initialize LED
	cfg_ptr = XGpio_LookupConfig(LED_BA);
	XGpio_CfgInitialize(&led_device, cfg_ptr, cfg_ptr->BaseAddress);
	
	// Set data direction
	XGpio_SetDataDirection(&btn_device, 1, 0x0000000F); // 4-bit buttons
	XGpio_SetDataDirection(&led_device, 1, 0x0000FFFF); // 16-bit LEDs
	XGpio_SetDataDirection(&swt_device, 1, 0x0000FFFF); // 16-bit Switches
	
	while (1) {
		swt_data = XGpio_DiscreteRead(&swt_device, 1);
		btn_data = XGpio_DiscreteRead(&btn_device, 1);
		if(btn_data!=0){
			led_data = swt_data;
		}else{
			led_data = 0x00000000;
		}
		XGpio_DiscreteWrite(&led_device, 1, led_data);
	}

	cleanup_platform();
	return 0;
}
