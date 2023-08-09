/* 
Tip1:
    MAX_VX means the maximum data of x coordiantion from 0~MAX_VX, same as MAX_VY
    for example if the router is 5X6 so the x is 4 and y is 5 
Tip2:
    if you want to change the data width 
    change the DATA_WIDTH also delete the comment of BITS_WIDE
    for example if your data_width is 32 delete the comment of the BITS_WIDE_32
*/

`define MAX_VX 2   //  the maximum X coordination
`define MAX_VY 2  //  the maximum Y coordination
`define MIN_V  0   //  the minimum coordiantion 

`define ROUTER_NUM (`MAX_VX +1) * (`MAX_VY +1)  // the router number will be generated  router_num = (MAX_VX +1 ) *(MAX_VY +1)
`define DATA_WIDTH 32
`define FIFO_DEPTH 8
`define PACKET_SEND 10
`define TOTAL_PACKET_SEND `ROUTER_NUM * `PACKET_SEND
`define ROUTER_MAX 128   // dont change it ,it's maximum number of router 


//`define BITS_WIDE_64_2 1'b1
`define BITS_WIDE_32_2 1'b1

//`define BITS_WIDE_32_4 1'b1
//`define BITS_WIDE_64_4 1'b1;


