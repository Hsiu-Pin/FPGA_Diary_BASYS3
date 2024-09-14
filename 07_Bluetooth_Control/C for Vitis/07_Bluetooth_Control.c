/******************************************************************************
* Author: Hsiu-Pin Hsu
* Date: 2024.09.13
******************************************************************************/

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_types.h"
#include "xil_io.h"

#define BA_DEG     XPAR_SERVOCONTROL_WRAP_0_BASEADDR
#define BA_BT_RX   XPAR_BLUETOOTHCONTROL_WRAP_0_BASEADDR

u32 deg;

int main()
{
    init_platform();

    xil_printf("Program Start !!!\n\r \n\r");

    // Initial Value
    Xil_Out32(BA_DEG, 0x00000000);

    deg = 0;

    while(1){

        // Detect ASCII from bluetooth module
        deg = Xil_In32(BA_BT_RX);

        // ================================================
        // Valid Number 0~7
        // 0: IDLE
        // 1~7: 0-deg, 30, 60, 90, 120, 150, 180
        if(deg <=55 && deg >= 49) { // Valid = 1~7
            deg = deg-48; // ASCII -> Decimal
            if     (deg==1){ xil_printf("  0 degrees \n\r"); }
            else if(deg==2){ xil_printf(" 30 degrees \n\r"); }
            else if(deg==3){ xil_printf(" 60 degrees \n\r"); }
            else if(deg==4){ xil_printf(" 90 degrees \n\r"); }
            else if(deg==5){ xil_printf("120 degrees \n\r"); }
            else if(deg==6){ xil_printf("150 degrees \n\r"); }
            else if(deg==7){ xil_printf("180 degrees \n\r"); }
            Xil_Out32(BA_DEG, deg);
        // ================================================
        } else {
            xil_printf("Invalid Input... \n\r \n\r");
        }

    }

    cleanup_platform();
    return 0;
}
