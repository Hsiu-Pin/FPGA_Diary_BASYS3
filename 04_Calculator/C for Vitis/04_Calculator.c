/******************************************************************************
* Author: Hsiu-Pin Hsu
* Date: 2024.08.24
******************************************************************************/

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_types.h"
#include "xil_io.h"

#define REG0 XPAR_CALCULATORCONTROL_0_BASEADDR
#define REG1 XPAR_CALCULATORCONTROL_0_BASEADDR+4
#define REG2 XPAR_CALCULATORCONTROL_0_BASEADDR+8
#define REG3 XPAR_CALCULATORCONTROL_0_BASEADDR+12

u32 digit;
u32 data;

void wait_result();
void wait_esc();

// Continuously read the REG3 to see if the calculation is done.
// REG3 = {3'd0, cal_done, ans};
// Shift Reg3 right by 28-bit, we can get the cal_done signal.
void wait_result(){
    while(1){
        data = Xil_In32(REG3);
        if( data >> 28 != 0){
            xil_printf(" = %0d \n\r", data & 0x0FFFFFFF);  
            xil_printf("Please Press ESC... \n\r");
            wait_esc();
            return;
        }

        // Press ESC to Reset
        if (XUartLite_RecvByte(XPAR_XUARTLITE_0_BASEADDR) == 27) { // ESC
            data = 0;
            Xil_Out32(REG2, 0x00000006);
            Xil_Out32(REG1, data);
            xil_printf("---- ESC ---- \n\r");
            return;
        }
    }
}

// After completing one calculation, wait for ESC to start again.
void wait_esc(){
    while(1){
        if (XUartLite_RecvByte(XPAR_XUARTLITE_0_BASEADDR) == 27) { // ESC
            data = 0;
            Xil_Out32(REG2, 0x00000006);
            Xil_Out32(REG1, data);
            xil_printf("---- ESC ---- \n\r");
            return;
        }
    }
}

int main()
{
    init_platform();

    xil_printf("Program Start !!!\n\r \n\r");

    // Anodes Mask
    Xil_Out32(REG0, 0x0000000F);

    // Initial Value
    Xil_Out32(REG1, 0x00000000);

    data = 0;

    while(1){

        // Detect ASCII from computer keyboard
        digit = XUartLite_RecvByte(XPAR_XUARTLITE_0_BASEADDR);

        // ================================================
        // Number 0~9
        if(digit <=57 && digit >= 48) {
            digit = digit-48; // ASCII -> Decimal
            xil_printf("%d", digit);
            data = (data<<8) + digit;
            Xil_Out32(REG1, data);
        // ================================================
        // Push Enter (=)
        } else if (digit == 13) {
            Xil_Out32(REG2, 0x00000001);
            wait_result();       
        // ================================================
        // Addition (+)
        } else if (digit == 43) {
            data = 0;
            Xil_Out32(REG2, 0x00000002);
            xil_printf("+");
        // ================================================
        // Subtraction (+)
        } else if (digit == 45) { // -
            data = 0;
            Xil_Out32(REG2, 0x00000003);
            xil_printf("-");
        // ================================================
        // Multiplication (+)
        } else if (digit == 42) { // *
            data = 0;
            Xil_Out32(REG2, 0x00000004);
            xil_printf("*");
        // ================================================
        // Division (/)
        } else if (digit == 47) { // /
            data = 0;
            Xil_Out32(REG2, 0x00000005);
            xil_printf("/");
        // ================================================
        // ESC, Reset or Restart
        } else if (digit == 27) { // ESC
            data = 0;
            Xil_Out32(REG2, 0x00000006);
            Xil_Out32(REG1, data);
            xil_printf("---- ESC ---- \n\r");
        }
    }

    cleanup_platform();
    return 0;
}
