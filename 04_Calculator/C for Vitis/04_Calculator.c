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

u32 digit;
u32 data;

int main()
{
    init_platform();

    //print("Program Start !!!\n\r \n\r");

    // Anodes Mask
    Xil_Out32(XPAR_CALCULATORCONTROL_0_BASEADDR, 0x0000000F);

    // Initial Value
    Xil_Out32(XPAR_CALCULATORCONTROL_0_BASEADDR+4, 0x00000000);

    
    Xil_Out32(XPAR_CALCULATORCONTROL_0_BASEADDR+4, 0x01020304);
    Xil_Out32(XPAR_CALCULATORCONTROL_0_BASEADDR+8, 0x00000002);
    Xil_Out32(XPAR_CALCULATORCONTROL_0_BASEADDR+4, 0x05060708);
    Xil_Out32(XPAR_CALCULATORCONTROL_0_BASEADDR+8, 0x00000001);
    Xil_Out32(XPAR_CALCULATORCONTROL_0_BASEADDR+8, 0x00000006);

    //data = 0;

    /*while(1){
        digit = XUartLite_RecvByte(XPAR_XUARTLITE_0_BASEADDR);
        if(digit <=57 && digit >= 48) {// number 0~9
            digit = digit-48; // ASCII -> Decimal
            xil_printf("%d", digit);
            data = (data<<8) + digit;
            Xil_Out32(XPAR_CALCULATORCONTROL_0_BASEADDR+4, data);
        } else if (digit == 13) { // Enter
            Xil_Out32(XPAR_CALCULATORCONTROL_0_BASEADDR+8, 0x00000001);
            xil_printf(" Enter \n\r");
        } else if (digit == 43) { // +
            Xil_Out32(XPAR_CALCULATORCONTROL_0_BASEADDR+8, 0x00000002);
            xil_printf("+");
        } else if (digit == 45) { // -
            Xil_Out32(XPAR_CALCULATORCONTROL_0_BASEADDR+8, 0x00000003);
            xil_printf("-");
        } else if (digit == 42) { // *
            Xil_Out32(XPAR_CALCULATORCONTROL_0_BASEADDR+8, 0x00000004);
            xil_printf("*");
        } else if (digit == 47) { // /
            Xil_Out32(XPAR_CALCULATORCONTROL_0_BASEADDR+8, 0x00000005);
            xil_printf("/");
        } else if (digit == 27) { // ESC
            Xil_Out32(XPAR_CALCULATORCONTROL_0_BASEADDR+8, 0x00000006);
            xil_printf("---- ESC ---- \n\r");
        }
    }
*/
    cleanup_platform();
    return 0;
}
