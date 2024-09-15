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
#define BA_BT_TX   XPAR_BLUETOOTHCONTROL_WRAP_0_BASEADDR
#define BA_BT_RX   XPAR_BLUETOOTHCONTROL_WRAP_0_BASEADDR + 4

u32 deg;
u32 deg_r;

int main()
{
    init_platform();

    xil_printf("Program Start !!!\n\r \n\r");

    // Initial Value
    Xil_Out32(BA_DEG, 0x00000000);

    deg = 0;

    while(1){

        // ================================================
        // Detect ASCII from bluetooth module
        deg = Xil_In32(BA_BT_RX);

        // ================================================
        // Using Tx to send back the input degree
        if(deg!=deg_r){
            // for same degree, only send once
            deg_r  = deg;

            // ================================================
            // Trigger the Servo
            // Valid Number 0~7
            // 0: IDLE
            // 1~7: 0-deg, 30, 60, 90, 120, 150, 180
            if(deg <=55 && deg >= 49) { 
                Xil_Out32(BA_DEG, deg-48); // -48 to convert to ASCII to Decimal
            } 

            // ================================================
            // Trigger the Bluetooth Tx
            // slv_reg_0[0]    = tx_valid
            // slv_reg_0[15:8] = tx_data
            // +1 to trigger the valid signaln
            deg    = (deg << 8) + 1;; 
            
            Xil_Out32(BA_BT_TX, deg);
            
            usleep(100);
            // clean the valid
            Xil_Out32(BA_BT_TX, 0x00000000); 
        }
        // ================================================
        
        

    }

    cleanup_platform();
    return 0;
}
