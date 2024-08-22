/******************************************************************************
* Author: Hsiu-Pin Hsu
* Date: 2024.08.20
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

    print("Program Start !!!\n\r \n\r");

    // Anodes Mask
    Xil_Out32(XPAR_DISPLAYCONTROL_0_BASEADDR, 0x0000000F);

    // Initial Value
    Xil_Out32(XPAR_DISPLAYCONTROL_0_BASEADDR+4, 0x00000000);

    data = 0;

    while(1){
        digit = XUartLite_RecvByte(XPAR_XUARTLITE_0_BASEADDR);
        digit = digit-48; // ASCII -> Int
        if(digit > 9 || digit < 0){
            xil_printf("\n\r");
            data = 0;
        } else {
            xil_printf("%d", digit);
            data = (data<<8) + digit;
        };
        Xil_Out32(XPAR_DISPLAYCONTROL_0_BASEADDR+4, data);
    }

    cleanup_platform();
    return 0;
}
