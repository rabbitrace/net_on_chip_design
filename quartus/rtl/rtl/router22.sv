`include "globe_def.sv"
module router22
(

input logic clk, 
input logic nreset,  //switch0
input logic send_en,
input logic send_en_tx,
output logic [`DATA_WIDTH -1 :0]data,
output logic error_led, //led0
//output logic error_con_re, //led0
output logic error_con //led1 
);


localparam  MAX_COX = `MAX_VX + 1; // max coordinate
localparam  MEM_WIDTH = $clog2(`TOTAL_PACKET_SEND);
localparam  TIME_ALL = 32'd2500_0000_0 ;
localparam  ROUTER_WIDTH = $clog2(`ROUTER_NUM); 

logic [ROUTER_WIDTH -1 :0] ROUTER_CNT;


logic [9 :0]receive_cnt[`ROUTER_NUM-1:0];  
logic [9 :0]send_cnt[`ROUTER_NUM-1:0];


logic [`ROUTER_NUM-1:0]error_flag;

logic [MEM_WIDTH -1:0]receive_cnt_total,send_cnt_total;

logic [`ROUTER_NUM-1:0] led;


//actually it's base on ready_east 
logic [`DATA_WIDTH -1:0]Data_east[`ROUTER_NUM-1:0];
logic [`DATA_WIDTH -1:0]Data_west[`ROUTER_NUM-1:0];
logic [`DATA_WIDTH -1:0]Data_north[`ROUTER_NUM-1:0];
logic [`DATA_WIDTH -1:0]Data_south[`ROUTER_NUM-1:0];
logic [`DATA_WIDTH -1:0]Data_out_ip[`ROUTER_NUM-1:0];
logic [`ROUTER_NUM-1:0]Valid_east,Valid_west,Valid_north,Valid_south,Valid_out_ip;
logic [`ROUTER_NUM-1:0]Last_east,Last_west,Last_north,Last_south,Last_out_ip;
logic [`ROUTER_NUM-1:0]Ready_east,Ready_west,Ready_north,Ready_south,Ready_out_ip;

//IP to router
logic [`ROUTER_NUM-1:0] Ready_ip_router;
logic [`ROUTER_NUM-1:0] Last_ip_router;
logic [`ROUTER_NUM-1:0] Valid_ip_router;
logic [`DATA_WIDTH -1:0]Data_ip_router[`ROUTER_NUM-1:0];

logic [31:0]time_cnt;
logic add_flag;


logic [9:0]send_en_cnt;



 genvar i;
 genvar j;
 

always @(posedge clk or negedge nreset) begin
   if(!nreset)
       error_con <= 1'b1;
   else if(error_flag)
       error_con <= 1'b0;
end

// always @(posedge clk or negedge nreset) begin
//     if(!nreset)
//         error_con_re <= 1'b0;
//     else if(led)
//         error_con_re <= 1'b1;
// end


	// hex u0 (
	// 	.probe ({31'd0,send_cnt[0]})  // probes.probe
	// );

	// hex u1 (
	// 	.probe ({22'd0,receive_cnt[0]})  // probes.probe
	// );

	// hex u2 (
	// 	.probe (receive_cnt_total)  // probes.probe
	// );

	// hex u3 (
	// 	.probe (send_cnt_total)  // probes.probe
	// );
    
	// hex u4 (
	// 	.probe ({31'd0,Last_out_ip[0]})  // probes.probe
	// );

//	hex u5 (
//		.probe (Data_out_ip[0])  // probes.probe
//	);
//
//	hex u6 (
//		.probe (Data_ip_router[0])  // probes.probe
//	);
//
//    hex u7 (
//		.probe (Data_out_ip[3])  // probes.probe
//	);
//    hex u8 (
//		.probe (Data_north[0])  // probes.probe
//	);
//    hex u9 (
//		.probe (Last_north[0])  // probes.probe
//	);  

always@(posedge clk or negedge nreset)begin
    if(!nreset)
        send_en_cnt <= 10'b0;
    else if(send_en )
        send_en_cnt <= send_en_cnt + 1'b1 ;
end


always@(posedge clk or negedge nreset)begin
    if(!nreset)
        time_cnt <= 1'b0;
    else if(time_cnt == TIME_ALL)
        time_cnt <= time_cnt ;
    else if(send_en_cnt == `PACKET_SEND)
        time_cnt <= time_cnt +1'b1;
end



   always_ff @( posedge clk or negedge nreset ) 
      begin
            integer h;
			if(!nreset)
				begin
					receive_cnt_total <= '0;
					send_cnt_total <= '0;
                    add_flag <= '0;
                    ROUTER_CNT <= '0;
				end
			else if(time_cnt == TIME_ALL)
				begin
					if(ROUTER_CNT < `ROUTER_NUM)
                        begin
                            receive_cnt_total <= receive_cnt_total +  receive_cnt[ROUTER_CNT] ;
                            send_cnt_total <= send_cnt_total + send_cnt[ROUTER_CNT] ; 
                            ROUTER_CNT <= ROUTER_CNT + 1'b1;
                        end		
				end
		end



always_ff @( posedge clk or negedge nreset ) 
    begin 
        if(!nreset)
            begin
                error_led <= '0;
            end
        else 
            begin
                if(receive_cnt_total ==  send_cnt_total && time_cnt == TIME_ALL)
                    begin
                        error_led <= '1;
                    end
                else 
                    begin
                        error_led <='0;
                    end
            end
    end


//   i equal to x, j equal to y
 generate
     for(i = 0 ;i <= `MAX_VX; i = i +1)  
     begin :router_generation
        for(j = 0 ;j <= `MAX_VY; j = j +1)
        begin :router_total
            if( i == 0 && j == 0)
                begin :fake_ip_00
                    fake_ip #(0,1,i,j,`PACKET_SEND,"H:/vivado_project/router/print_file/send_file_22.txt","H:/vivado_project/router/print_file/receive_file_00.txt") fake_ip
                    (
                    .clk(clk),
                    .nreset(nreset),
                    .send_en(send_en),
                    .send_en_tx(send_en_tx),


                    .data(data),
                    .Valid_IP(Valid_out_ip[i + j*MAX_COX]),
                    .Data_IP(Data_out_ip[i + j*MAX_COX]),
                    .Last_IP(Last_out_ip[i + j*MAX_COX]),
                    .Ready_out_ip(Ready_out_ip[i + j*MAX_COX]),

                    .Ready_IP(Ready_ip_router[i + j*MAX_COX]),
                    .Data_out_ip(Data_ip_router[i + j*MAX_COX]),
                    .Last_out_ip(Last_ip_router[i + j*MAX_COX]),
                    .Valid_out_ip(Valid_ip_router[i + j*MAX_COX]),
                    .receive_cnt(receive_cnt[i + j*MAX_COX]),
                    .send_cnt(send_cnt[i + j*MAX_COX]),
                    //.led(led[i + j*MAX_COX]),
                    .error_flag(error_flag[i + j*MAX_COX])
                    );                       
                end
            else 
                begin :fake_ip
                    fake_ip #(0,0,i,j,`PACKET_SEND,"H:/vivado_project/router/print_file/send_file_other.txt","H:/vivado_project/router/print_file/receive_file_other.txt") fake_ip
                    (
                    .clk(clk),
                    .nreset(nreset),
                    .send_en(send_en),
                    .send_en_tx(1'b0),
                    .data(),

                    .Valid_IP(Valid_out_ip[i + j*MAX_COX]),
                    .Data_IP(Data_out_ip[i + j*MAX_COX]),
                    .Last_IP(Last_out_ip[i + j*MAX_COX]),
                    .Ready_out_ip(Ready_out_ip[i + j*MAX_COX]),
                    
                    .Ready_IP(Ready_ip_router[i + j*MAX_COX]),
                    .Data_out_ip(Data_ip_router[i + j*MAX_COX]),
                    .Last_out_ip(Last_ip_router[i + j*MAX_COX]),
                    .Valid_out_ip(Valid_ip_router[i + j*MAX_COX]),
                    .receive_cnt(receive_cnt[i + j*MAX_COX]),
                    .send_cnt(send_cnt[i + j*MAX_COX]),
                    //.led(led[i + j*MAX_COX]),
                    .error_flag(error_flag[i + j*MAX_COX])
                    );                    
                end


            if(i == `MIN_V && j == `MIN_V) // i = 0   j = 0;
                begin :router_00
                    router#( i,j) router(
                    .clk(clk),
                    .nreset(nreset),
                    .Data_L(Data_east[i + j*MAX_COX  + `MAX_VX]),//Data_L_20_00
                    .Data_R(Data_west[i + j*MAX_COX  + 1]),//Data_R_10_00
                    .Data_T(Data_south[i + j*MAX_COX + MAX_COX]),//Data_T_01_00
                    .Data_B(Data_north[i + j*MAX_COX + `MAX_VY*MAX_COX]),//Data_B_02_00
                    .Data_IP(Data_ip_router[i + j*MAX_COX]),//Data_IP_00
                    .Valid_L(Valid_east[i + j*MAX_COX +`MAX_VX]),//Valid_L_20_00
                    .Valid_R(Valid_west[i + j*MAX_COX +1]),//Valid_R_10_00
                    .Valid_T(Valid_south[i + j*MAX_COX+MAX_COX]),//Valid_T_01_00
                    .Valid_B(Valid_north[i + j*MAX_COX+ `MAX_VY*MAX_COX]),//Valid_B_02_00
                    .Valid_IP(Valid_ip_router[i + j*MAX_COX]),//Valid_IP_00
                    .Last_L(Last_east[i + j*MAX_COX +`MAX_VX]),//Last_L_20_00
                    .Last_R(Last_west[i + j*MAX_COX +1]),//Last_R_10_00
                    .Last_T(Last_south[i + j*MAX_COX+MAX_COX]),//Last_T_01_00
                    .Last_B(Last_north[i + j*MAX_COX+ `MAX_VY*MAX_COX]),//Last_B_02_00
                    .Last_IP(Last_ip_router[i + j*MAX_COX]),//Last_IP_00

                    .Ready_L(Ready_east[i + j*MAX_COX +`MAX_VX]),//Ready_L_00_20
                    .Ready_R(Ready_west[i + j*MAX_COX +1]),//Ready_R_00_10
                    .Ready_T(Ready_south[i + j*MAX_COX+MAX_COX]),//Ready_T_00_01
                    .Ready_B(Ready_north[i + j*MAX_COX+ `MAX_VY*MAX_COX]),//Ready_B_00_02
                    .Ready_IP(Ready_ip_router[i + j*MAX_COX]),//Ready_00_ip


                    .Ready_east(Ready_east[i + j*MAX_COX]),//Ready_L_10_00
                    .Ready_west(Ready_west[i + j*MAX_COX]),//Ready_R_20_00
                    .Ready_north(Ready_north[i + j*MAX_COX]),//Ready_B_01_00
                    .Ready_south(Ready_south[i + j*MAX_COX]),//Ready_T_02_00
                    .Ready_out_ip(Ready_out_ip[i + j*MAX_COX]),//Ready_out_ip_00
                    .Data_east(Data_east[i + j*MAX_COX]),//Data_L_00_10
                    .Data_west(Data_west[i + j*MAX_COX]),//Data_R_00_20
                    .Data_north(Data_north[i + j*MAX_COX]),//Data_B_00_01
                    .Data_south(Data_south[i + j*MAX_COX]),//Data_T_00_02
                    .Data_out_ip(Data_out_ip[i + j*MAX_COX]),//Data_out_ip_00
                    .Last_east(Last_east[i + j*MAX_COX]),//Last_L_00_10
                    .Last_west(Last_west[i + j*MAX_COX]),//Last_R_00_20
                    .Last_north(Last_north[i + j*MAX_COX]),//Last_B_00_01
                    .Last_south(Last_south[i + j*MAX_COX]),//Last_T_00_02
                    .Last_out_ip(Last_out_ip[i + j*MAX_COX]),//Last_out_ip_00
                    .Valid_east(Valid_east[i + j*MAX_COX]),//Valid_L_00_10
                    .Valid_west(Valid_west[i + j*MAX_COX]),//Valid_R_00_20
                    .Valid_north(Valid_north[i + j*MAX_COX]),//Valid_B_00_01
                    .Valid_south(Valid_south[i + j*MAX_COX]),//Valid_T_00_02
                    .Valid_out_ip(Valid_out_ip[i + j*MAX_COX])//Valid_out_ip_00
                    );                    
                end
            else if(i == `MIN_V && j ==`MAX_VY) // i = 0   j = 2;
                begin :router_02
                    router#( i,j) router(
                    .clk(clk),
                    .nreset(nreset),
                    .Data_L(Data_east[i + j*MAX_COX +`MAX_VX]),//Data_L_20_00
                    .Data_R(Data_west[i + j*MAX_COX +1]),//Data_R_10_00
                    .Data_T(Data_south[i + j*MAX_COX-`MAX_VY*MAX_COX]),//Data_T_01_00
                    .Data_B(Data_north[i + j*MAX_COX-MAX_COX]),//Data_B_02_00
                    .Data_IP(Data_ip_router[i + j*MAX_COX]),//Data_IP_00
                    .Valid_L(Valid_east[i + j*MAX_COX +`MAX_VX]),//Valid_L_20_00
                    .Valid_R(Valid_west[i + j*MAX_COX +1]),//Valid_R_10_00
                    .Valid_T(Valid_south[i + j*MAX_COX-`MAX_VY*MAX_COX]),//Valid_T_01_00
                    .Valid_B(Valid_north[i + j*MAX_COX-MAX_COX]),//Valid_B_02_00
                    .Valid_IP(Valid_ip_router[i + j*MAX_COX]),//Valid_IP_00
                    .Last_L(Last_east[i + j*MAX_COX +`MAX_VX]),//Last_L_20_00
                    .Last_R(Last_west[i + j*MAX_COX +1]),//Last_R_10_00
                    .Last_T(Last_south[i + j*MAX_COX-`MAX_VY*MAX_COX]),//Last_T_01_00
                    .Last_B(Last_north[i + j*MAX_COX-MAX_COX]),//Last_B_02_00
                    .Last_IP(Last_ip_router[i + j*MAX_COX]),//Last_IP_00

                    .Ready_L(Ready_east[i + j*MAX_COX +`MAX_VX]),//Ready_L_00_20
                    .Ready_R(Ready_west[i + j*MAX_COX +1]),//Ready_R_00_10
                    .Ready_T(Ready_south[i + j*MAX_COX-`MAX_VY*MAX_COX]),//Ready_T_00_01
                    .Ready_B(Ready_north[i + j*MAX_COX-MAX_COX]),//Ready_B_00_02
                    .Ready_IP(Ready_ip_router[i + j*MAX_COX]),//Ready_00_ip


                    .Ready_east(Ready_east[i + j*MAX_COX]),//Ready_L_10_00
                    .Ready_west(Ready_west[i + j*MAX_COX]),//Ready_R_20_00
                    .Ready_north(Ready_north[i + j*MAX_COX]),//Ready_B_01_00
                    .Ready_south(Ready_south[i + j*MAX_COX]),//Ready_T_02_00
                    .Ready_out_ip(Ready_out_ip[i + j*MAX_COX]),//Ready_out_ip_00
                    .Data_east(Data_east[i + j*MAX_COX]),//Data_L_00_10
                    .Data_west(Data_west[i + j*MAX_COX]),//Data_R_00_20
                    .Data_north(Data_north[i + j*MAX_COX]),//Data_B_00_01
                    .Data_south(Data_south[i + j*MAX_COX]),//Data_T_00_02
                    .Data_out_ip(Data_out_ip[i + j*MAX_COX]),//Data_out_ip_00
                    .Last_east(Last_east[i + j*MAX_COX]),//Last_L_00_10
                    .Last_west(Last_west[i + j*MAX_COX]),//Last_R_00_20
                    .Last_north(Last_north[i + j*MAX_COX]),//Last_B_00_01
                    .Last_south(Last_south[i + j*MAX_COX]),//Last_T_00_02
                    .Last_out_ip(Last_out_ip[i + j*MAX_COX]),//Last_out_ip_00
                    .Valid_east(Valid_east[i + j*MAX_COX]),//Valid_L_00_10
                    .Valid_west(Valid_west[i + j*MAX_COX]),//Valid_R_00_20
                    .Valid_north(Valid_north[i + j*MAX_COX]),//Valid_B_00_01
                    .Valid_south(Valid_south[i + j*MAX_COX]),//Valid_T_00_02
                    .Valid_out_ip(Valid_out_ip[i + j*MAX_COX])//Valid_out_ip_00
                    );                    
                end
            else if(i == `MAX_VX && j == `MIN_V ) //i = 3  j = 0;
                begin :router_30
                    router#( i,j) router(
                    .clk(clk),
                    .nreset(nreset),
                    .Data_L(Data_east[i + j*MAX_COX -1]),//Data_L_20_00
                    .Data_R(Data_west[i + j*MAX_COX - `MAX_VX]),//Data_R_10_00
                    .Data_T(Data_south[i + j*MAX_COX+ MAX_COX]),//Data_T_01_00
                    .Data_B(Data_north[i + j*MAX_COX+ `MAX_VY*MAX_COX]),//Data_B_02_00
                    .Data_IP(Data_ip_router[i + j*MAX_COX]),//Data_IP_00
                    .Valid_L(Valid_east[i + j*MAX_COX -1]),//Valid_L_20_00
                    .Valid_R(Valid_west[i + j*MAX_COX - `MAX_VX]),//Valid_R_10_00
                    .Valid_T(Valid_south[i + j*MAX_COX+MAX_COX]),//Valid_T_01_00
                    .Valid_B(Valid_north[i + j*MAX_COX+`MAX_VY*MAX_COX]),//Valid_B_02_00
                    .Valid_IP(Valid_ip_router[i + j*MAX_COX]),//Valid_IP_00
                    .Last_L(Last_east[i + j*MAX_COX -1]),//Last_L_20_00
                    .Last_R(Last_west[i + j*MAX_COX - `MAX_VX]),//Last_R_10_00
                    .Last_T(Last_south[i + j*MAX_COX+MAX_COX]),//Last_T_01_00
                    .Last_B(Last_north[i + j*MAX_COX+`MAX_VY*MAX_COX]),//Last_B_02_00
                    .Last_IP(Last_ip_router[i + j*MAX_COX]),//Last_IP_00

                    .Ready_L(Ready_east[i + j*MAX_COX -1]),//Ready_L_00_20
                    .Ready_R(Ready_west[i + j*MAX_COX - `MAX_VX]),//Ready_R_00_10
                    .Ready_T(Ready_south[i + j*MAX_COX+MAX_COX]),//Ready_T_00_01
                    .Ready_B(Ready_north[i + j*MAX_COX+`MAX_VY*MAX_COX]),//Ready_B_00_02
                    .Ready_IP(Ready_ip_router[i + j*MAX_COX]),//Ready_00_ip


                    .Ready_east(Ready_east[i + j*MAX_COX]),//Ready_L_10_00
                    .Ready_west(Ready_west[i + j*MAX_COX]),//Ready_R_20_00
                    .Ready_north(Ready_north[i + j*MAX_COX]),//Ready_B_01_00
                    .Ready_south(Ready_south[i + j*MAX_COX]),//Ready_T_02_00
                    .Ready_out_ip(Ready_out_ip[i + j*MAX_COX]),//Ready_out_ip_00
                    .Data_east(Data_east[i + j*MAX_COX]),//Data_L_00_10
                    .Data_west(Data_west[i + j*MAX_COX]),//Data_R_00_20
                    .Data_north(Data_north[i + j*MAX_COX]),//Data_B_00_01
                    .Data_south(Data_south[i + j*MAX_COX]),//Data_T_00_02
                    .Data_out_ip(Data_out_ip[i + j*MAX_COX]),//Data_out_ip_00
                    .Last_east(Last_east[i + j*MAX_COX]),//Last_L_00_10
                    .Last_west(Last_west[i + j*MAX_COX]),//Last_R_00_20
                    .Last_north(Last_north[i + j*MAX_COX]),//Last_B_00_01
                    .Last_south(Last_south[i + j*MAX_COX]),//Last_T_00_02
                    .Last_out_ip(Last_out_ip[i + j*MAX_COX]),//Last_out_ip_00
                    .Valid_east(Valid_east[i + j*MAX_COX]),//Valid_L_00_10
                    .Valid_west(Valid_west[i + j*MAX_COX]),//Valid_R_00_20
                    .Valid_north(Valid_north[i + j*MAX_COX]),//Valid_B_00_01
                    .Valid_south(Valid_south[i + j*MAX_COX]),//Valid_T_00_02
                    .Valid_out_ip(Valid_out_ip[i + j*MAX_COX])//Valid_out_ip_00
                    );                  
                end
            else if(i == `MAX_VX && j == `MAX_VY) //i = 3  j = 2;
                begin :router_32
                    router#( i,j) router(
                    .clk(clk),
                    .nreset(nreset),
                    .Data_L(Data_east[i + j*MAX_COX -1]),//Data_L_20_00
                    .Data_R(Data_west[i + j*MAX_COX -`MAX_VX]),//Data_R_10_00
                    .Data_T(Data_south[i + j*MAX_COX-`MAX_VY*MAX_COX]),//Data_T_01_00
                    .Data_B(Data_north[i + j*MAX_COX-MAX_COX]),//Data_B_02_00
                    .Data_IP(Data_ip_router[i + j*MAX_COX]),//Data_IP_00
                    .Valid_L(Valid_east[i + j*MAX_COX -1]),//Valid_L_20_00
                    .Valid_R(Valid_west[i + j*MAX_COX -`MAX_VX]),//Valid_R_10_00
                    .Valid_T(Valid_south[i + j*MAX_COX-`MAX_VY*MAX_COX]),//Valid_T_01_00
                    .Valid_B(Valid_north[i + j*MAX_COX-MAX_COX]),//Valid_B_02_00
                    .Valid_IP(Valid_ip_router[i + j*MAX_COX]),//Valid_IP_00
                    .Last_L(Last_east[i + j*MAX_COX -1]),//Last_L_20_00
                    .Last_R(Last_west[i + j*MAX_COX -`MAX_VX]),//Last_R_10_00
                    .Last_T(Last_south[i + j*MAX_COX-`MAX_VY*MAX_COX]),//Last_T_01_00
                    .Last_B(Last_north[i + j*MAX_COX-MAX_COX]),//Last_B_02_00
                    .Last_IP(Last_ip_router[i + j*MAX_COX]),//Last_IP_00

                    .Ready_L(Ready_east[i + j*MAX_COX -1]),//Ready_L_00_20
                    .Ready_R(Ready_west[i + j*MAX_COX -`MAX_VX]),//Ready_R_00_10
                    .Ready_T(Ready_south[i + j*MAX_COX-`MAX_VY*MAX_COX]),//Ready_T_00_01
                    .Ready_B(Ready_north[i + j*MAX_COX-MAX_COX]),//Ready_B_00_02
                    .Ready_IP(Ready_ip_router[i + j*MAX_COX]),//Ready_00_ip


                    .Ready_east(Ready_east[i + j*MAX_COX]),//Ready_L_10_00
                    .Ready_west(Ready_west[i + j*MAX_COX]),//Ready_R_20_00
                    .Ready_north(Ready_north[i + j*MAX_COX]),//Ready_B_01_00
                    .Ready_south(Ready_south[i + j*MAX_COX]),//Ready_T_02_00
                    .Ready_out_ip(Ready_out_ip[i + j*MAX_COX]),//Ready_out_ip_00
                    .Data_east(Data_east[i + j*MAX_COX]),//Data_L_00_10
                    .Data_west(Data_west[i + j*MAX_COX]),//Data_R_00_20
                    .Data_north(Data_north[i + j*MAX_COX]),//Data_B_00_01
                    .Data_south(Data_south[i + j*MAX_COX]),//Data_T_00_02
                    .Data_out_ip(Data_out_ip[i + j*MAX_COX]),//Data_out_ip_00
                    .Last_east(Last_east[i + j*MAX_COX]),//Last_L_00_10
                    .Last_west(Last_west[i + j*MAX_COX]),//Last_R_00_20
                    .Last_north(Last_north[i + j*MAX_COX]),//Last_B_00_01
                    .Last_south(Last_south[i + j*MAX_COX]),//Last_T_00_02
                    .Last_out_ip(Last_out_ip[i + j*MAX_COX]),//Last_out_ip_00
                    .Valid_east(Valid_east[i + j*MAX_COX]),//Valid_L_00_10
                    .Valid_west(Valid_west[i + j*MAX_COX]),//Valid_R_00_20
                    .Valid_north(Valid_north[i + j*MAX_COX]),//Valid_B_00_01
                    .Valid_south(Valid_south[i + j*MAX_COX]),//Valid_T_00_02
                    .Valid_out_ip(Valid_out_ip[i + j*MAX_COX])//Valid_out_ip_00
                    );                    
                end
            else if(i == `MIN_V )  // i  = 0  y = dont care;
                begin :router_0X
                    router#( i,j) router(
                    .clk(clk),
                    .nreset(nreset),
                    .Data_L(Data_east[i + j*MAX_COX + `MAX_VX]),//Data_L_20_00
                    .Data_R(Data_west[i + j*MAX_COX +1]),//Data_R_10_00
                    .Data_T(Data_south[i + j*MAX_COX+MAX_COX]),//Data_T_01_00
                    .Data_B(Data_north[i + j*MAX_COX-MAX_COX]),//Data_B_02_00
                    .Data_IP(Data_ip_router[i + j*MAX_COX]),//Data_IP_00
                    .Valid_L(Valid_east[i + j*MAX_COX + `MAX_VX]),//Valid_L_20_00
                    .Valid_R(Valid_west[i + j*MAX_COX +1]),//Valid_R_10_00
                    .Valid_T(Valid_south[i + j*MAX_COX+MAX_COX]),//Valid_T_01_00
                    .Valid_B(Valid_north[i + j*MAX_COX-MAX_COX]),//Valid_B_02_00
                    .Valid_IP(Valid_ip_router[i + j*MAX_COX]),//Valid_IP_00
                    .Last_L(Last_east[i + j*MAX_COX + `MAX_VX]),//Last_L_20_00
                    .Last_R(Last_west[i + j*MAX_COX +1]),//Last_R_10_00
                    .Last_T(Last_south[i + j*MAX_COX+MAX_COX]),//Last_T_01_00
                    .Last_B(Last_north[i + j*MAX_COX-MAX_COX]),//Last_B_02_00
                    .Last_IP(Last_ip_router[i + j*MAX_COX]),//Last_IP_00

                    .Ready_L(Ready_east[i + j*MAX_COX + `MAX_VX]),//Ready_L_00_20
                    .Ready_R(Ready_west[i + j*MAX_COX +1]),//Ready_R_00_10
                    .Ready_T(Ready_south[i + j*MAX_COX+MAX_COX]),//Ready_T_00_01
                    .Ready_B(Ready_north[i + j*MAX_COX-MAX_COX]),//Ready_B_00_02
                    .Ready_IP(Ready_ip_router[i + j*MAX_COX]),//Ready_00_ip


                    .Ready_east(Ready_east[i + j*MAX_COX]),//Ready_L_10_00
                    .Ready_west(Ready_west[i + j*MAX_COX]),//Ready_R_20_00
                    .Ready_north(Ready_north[i + j*MAX_COX]),//Ready_B_01_00
                    .Ready_south(Ready_south[i + j*MAX_COX]),//Ready_T_02_00
                    .Ready_out_ip(Ready_out_ip[i + j*MAX_COX]),//Ready_out_ip_00
                    .Data_east(Data_east[i + j*MAX_COX]),//Data_L_00_10
                    .Data_west(Data_west[i + j*MAX_COX]),//Data_R_00_20
                    .Data_north(Data_north[i + j*MAX_COX]),//Data_B_00_01
                    .Data_south(Data_south[i + j*MAX_COX]),//Data_T_00_02
                    .Data_out_ip(Data_out_ip[i + j*MAX_COX]),//Data_out_ip_00
                    .Last_east(Last_east[i + j*MAX_COX]),//Last_L_00_10
                    .Last_west(Last_west[i + j*MAX_COX]),//Last_R_00_20
                    .Last_north(Last_north[i + j*MAX_COX]),//Last_B_00_01
                    .Last_south(Last_south[i + j*MAX_COX]),//Last_T_00_02
                    .Last_out_ip(Last_out_ip[i + j*MAX_COX]),//Last_out_ip_00
                    .Valid_east(Valid_east[i + j*MAX_COX]),//Valid_L_00_10
                    .Valid_west(Valid_west[i + j*MAX_COX]),//Valid_R_00_20
                    .Valid_north(Valid_north[i + j*MAX_COX]),//Valid_B_00_01
                    .Valid_south(Valid_south[i + j*MAX_COX]),//Valid_T_00_02
                    .Valid_out_ip(Valid_out_ip[i + j*MAX_COX])//Valid_out_ip_00
                    );              
                end
            else if(i == `MAX_VX) // i = 3  y= dont care 
                begin :router_3X
                    router#( i,j) router(
                    .clk(clk),
                    .nreset(nreset),
                    .Data_L(Data_east[i + j*MAX_COX -1]),//Data_L_20_00
                    .Data_R(Data_west[i + j*MAX_COX -`MAX_VX]),//Data_R_10_00
                    .Data_T(Data_south[i + j*MAX_COX+MAX_COX]),//Data_T_01_00
                    .Data_B(Data_north[i + j*MAX_COX-MAX_COX]),//Data_B_02_00
                    .Data_IP(Data_ip_router[i + j*MAX_COX]),//Data_IP_00
                    .Valid_L(Valid_east[i + j*MAX_COX -1]),//Valid_L_20_00
                    .Valid_R(Valid_west[i + j*MAX_COX -`MAX_VX]),//Valid_R_10_00
                    .Valid_T(Valid_south[i + j*MAX_COX+MAX_COX]),//Valid_T_01_00
                    .Valid_B(Valid_north[i + j*MAX_COX-MAX_COX]),//Valid_B_02_00
                    .Valid_IP(Valid_ip_router[i + j*MAX_COX]),//Valid_IP_00
                    .Last_L(Last_east[i + j*MAX_COX -1]),//Last_L_20_00
                    .Last_R(Last_west[i + j*MAX_COX -`MAX_VX]),//Last_R_10_00
                    .Last_T(Last_south[i + j*MAX_COX+MAX_COX]),//Last_T_01_00
                    .Last_B(Last_north[i + j*MAX_COX-MAX_COX]),//Last_B_02_00
                    .Last_IP(Last_ip_router[i + j*MAX_COX]),//Last_IP_00

                    .Ready_L(Ready_east[i + j*MAX_COX -1]),//Ready_L_00_20
                    .Ready_R(Ready_west[i + j*MAX_COX -`MAX_VX]),//Ready_R_00_10
                    .Ready_T(Ready_south[i + j*MAX_COX+MAX_COX]),//Ready_T_00_01
                    .Ready_B(Ready_north[i + j*MAX_COX-MAX_COX]),//Ready_B_00_02
                    .Ready_IP(Ready_ip_router[i + j*MAX_COX]),//Ready_00_ip


                    .Ready_east(Ready_east[i + j*MAX_COX]),//Ready_L_10_00
                    .Ready_west(Ready_west[i + j*MAX_COX]),//Ready_R_20_00
                    .Ready_north(Ready_north[i + j*MAX_COX]),//Ready_B_01_00
                    .Ready_south(Ready_south[i + j*MAX_COX]),//Ready_T_02_00
                    .Ready_out_ip(Ready_out_ip[i + j*MAX_COX]),//Ready_out_ip_00
                    .Data_east(Data_east[i + j*MAX_COX]),//Data_L_00_10
                    .Data_west(Data_west[i + j*MAX_COX]),//Data_R_00_20
                    .Data_north(Data_north[i + j*MAX_COX]),//Data_B_00_01
                    .Data_south(Data_south[i + j*MAX_COX]),//Data_T_00_02
                    .Data_out_ip(Data_out_ip[i + j*MAX_COX]),//Data_out_ip_00
                    .Last_east(Last_east[i + j*MAX_COX]),//Last_L_00_10
                    .Last_west(Last_west[i + j*MAX_COX]),//Last_R_00_20
                    .Last_north(Last_north[i + j*MAX_COX]),//Last_B_00_01
                    .Last_south(Last_south[i + j*MAX_COX]),//Last_T_00_02
                    .Last_out_ip(Last_out_ip[i + j*MAX_COX]),//Last_out_ip_00
                    .Valid_east(Valid_east[i + j*MAX_COX]),//Valid_L_00_10
                    .Valid_west(Valid_west[i + j*MAX_COX]),//Valid_R_00_20
                    .Valid_north(Valid_north[i + j*MAX_COX]),//Valid_B_00_01
                    .Valid_south(Valid_south[i + j*MAX_COX]),//Valid_T_00_02
                    .Valid_out_ip(Valid_out_ip[i + j*MAX_COX])//Valid_out_ip_00
                    );                    
                end
            else if(j == `MIN_V) // x = dont care  y = 0
                begin :router_X0
                   router#( i,j) router(
                    .clk(clk),
                    .nreset(nreset),
                    .Data_L(Data_east[i + j*MAX_COX -1]),//Data_L_20_00
                    .Data_R(Data_west[i + j*MAX_COX +1]),//Data_R_10_00
                    .Data_T(Data_south[i + j*MAX_COX+MAX_COX]),//Data_T_01_00
                    .Data_B(Data_north[i + j*MAX_COX+`MAX_VY*MAX_COX]),//Data_B_02_00
                    .Data_IP(Data_ip_router[i + j*MAX_COX]),//Data_IP_00
                    .Valid_L(Valid_east[i + j*MAX_COX -1]),//Valid_L_20_00
                    .Valid_R(Valid_west[i + j*MAX_COX +1]),//Valid_R_10_00
                    .Valid_T(Valid_south[i + j*MAX_COX+MAX_COX]),//Valid_T_01_00
                    .Valid_B(Valid_north[i + j*MAX_COX+`MAX_VY*MAX_COX]),//Valid_B_02_00
                    .Valid_IP(Valid_ip_router[i + j*MAX_COX]),//Valid_IP_00
                    .Last_L(Last_east[i + j*MAX_COX -1]),//Last_L_20_00
                    .Last_R(Last_west[i + j*MAX_COX +1]),//Last_R_10_00
                    .Last_T(Last_south[i + j*MAX_COX+MAX_COX]),//Last_T_01_00
                    .Last_B(Last_north[i + j*MAX_COX+`MAX_VY*MAX_COX]),//Last_B_02_00
                    .Last_IP(Last_ip_router[i + j*MAX_COX]),//Last_IP_00

                    .Ready_L(Ready_east[i + j*MAX_COX -1]),//Ready_L_00_20
                    .Ready_R(Ready_west[i + j*MAX_COX +1]),//Ready_R_00_10
                    .Ready_T(Ready_south[i + j*MAX_COX+MAX_COX]),//Ready_T_00_01
                    .Ready_B(Ready_north[i + j*MAX_COX+`MAX_VY*MAX_COX]),//Ready_B_00_02
                    .Ready_IP(Ready_ip_router[i + j*MAX_COX]),//Ready_00_ip


                    .Ready_east(Ready_east[i + j*MAX_COX]),//Ready_L_10_00
                    .Ready_west(Ready_west[i + j*MAX_COX]),//Ready_R_20_00
                    .Ready_north(Ready_north[i + j*MAX_COX]),//Ready_B_01_00
                    .Ready_south(Ready_south[i + j*MAX_COX]),//Ready_T_02_00
                    .Ready_out_ip(Ready_out_ip[i + j*MAX_COX]),//Ready_out_ip_00
                    .Data_east(Data_east[i + j*MAX_COX]),//Data_L_00_10
                    .Data_west(Data_west[i + j*MAX_COX]),//Data_R_00_20
                    .Data_north(Data_north[i + j*MAX_COX]),//Data_B_00_01
                    .Data_south(Data_south[i + j*MAX_COX]),//Data_T_00_02
                    .Data_out_ip(Data_out_ip[i + j*MAX_COX]),//Data_out_ip_00
                    .Last_east(Last_east[i + j*MAX_COX]),//Last_L_00_10
                    .Last_west(Last_west[i + j*MAX_COX]),//Last_R_00_20
                    .Last_north(Last_north[i + j*MAX_COX]),//Last_B_00_01
                    .Last_south(Last_south[i + j*MAX_COX]),//Last_T_00_02
                    .Last_out_ip(Last_out_ip[i + j*MAX_COX]),//Last_out_ip_00
                    .Valid_east(Valid_east[i + j*MAX_COX]),//Valid_L_00_10
                    .Valid_west(Valid_west[i + j*MAX_COX]),//Valid_R_00_20
                    .Valid_north(Valid_north[i + j*MAX_COX]),//Valid_B_00_01
                    .Valid_south(Valid_south[i + j*MAX_COX]),//Valid_T_00_02
                    .Valid_out_ip(Valid_out_ip[i + j*MAX_COX])//Valid_out_ip_00
                    );                    
                end

            else if(j == `MAX_VY)// x = dont care  y = 2
                begin :router_X2
                    router#( i,j) router(
                    .clk(clk),
                    .nreset(nreset),
                    .Data_L(Data_east[i + j*MAX_COX -1]),//Data_L_20_00
                    .Data_R(Data_west[i + j*MAX_COX +1]),//Data_R_10_00
                    .Data_T(Data_south[i + j*MAX_COX-`MAX_VY*MAX_COX]),//Data_T_01_00
                    .Data_B(Data_north[i + j*MAX_COX-MAX_COX]),//Data_B_02_00
                    .Data_IP(Data_ip_router[i + j*MAX_COX]),//Data_IP_00
                    .Valid_L(Valid_east[i + j*MAX_COX -1]),//Valid_L_20_00
                    .Valid_R(Valid_west[i + j*MAX_COX +1]),//Valid_R_10_00
                    .Valid_T(Valid_south[i + j*MAX_COX-`MAX_VY*MAX_COX]),//Valid_T_01_00
                    .Valid_B(Valid_north[i + j*MAX_COX-MAX_COX]),//Valid_B_02_00
                    .Valid_IP(Valid_ip_router[i + j*MAX_COX]),//Valid_IP_00
                    .Last_L(Last_east[i + j*MAX_COX -1]),//Last_L_20_00
                    .Last_R(Last_west[i + j*MAX_COX +1]),//Last_R_10_00
                    .Last_T(Last_south[i + j*MAX_COX-`MAX_VY*MAX_COX]),//Last_T_01_00
                    .Last_B(Last_north[i + j*MAX_COX-MAX_COX]),//Last_B_02_00
                    .Last_IP(Last_ip_router[i + j*MAX_COX]),//Last_IP_00

                    .Ready_L(Ready_east[i + j*MAX_COX -1]),//Ready_L_00_20
                    .Ready_R(Ready_west[i + j*MAX_COX +1]),//Ready_R_00_10
                    .Ready_T(Ready_south[i + j*MAX_COX-`MAX_VY*MAX_COX]),//Ready_T_00_01
                    .Ready_B(Ready_north[i + j*MAX_COX-MAX_COX]),//Ready_B_00_02
                    .Ready_IP(Ready_ip_router[i + j*MAX_COX]),//Ready_00_ip


                    .Ready_east(Ready_east[i + j*MAX_COX]),//Ready_L_10_00
                    .Ready_west(Ready_west[i + j*MAX_COX]),//Ready_R_20_00
                    .Ready_north(Ready_north[i + j*MAX_COX]),//Ready_B_01_00
                    .Ready_south(Ready_south[i + j*MAX_COX]),//Ready_T_02_00
                    .Ready_out_ip(Ready_out_ip[i + j*MAX_COX]),//Ready_out_ip_00
                    .Data_east(Data_east[i + j*MAX_COX]),//Data_L_00_10
                    .Data_west(Data_west[i + j*MAX_COX]),//Data_R_00_20
                    .Data_north(Data_north[i + j*MAX_COX]),//Data_B_00_01
                    .Data_south(Data_south[i + j*MAX_COX]),//Data_T_00_02
                    .Data_out_ip(Data_out_ip[i + j*MAX_COX]),//Data_out_ip_00
                    .Last_east(Last_east[i + j*MAX_COX]),//Last_L_00_10
                    .Last_west(Last_west[i + j*MAX_COX]),//Last_R_00_20
                    .Last_north(Last_north[i + j*MAX_COX]),//Last_B_00_01
                    .Last_south(Last_south[i + j*MAX_COX]),//Last_T_00_02
                    .Last_out_ip(Last_out_ip[i + j*MAX_COX]),//Last_out_ip_00
                    .Valid_east(Valid_east[i + j*MAX_COX]),//Valid_L_00_10
                    .Valid_west(Valid_west[i + j*MAX_COX]),//Valid_R_00_20
                    .Valid_north(Valid_north[i + j*MAX_COX]),//Valid_B_00_01
                    .Valid_south(Valid_south[i + j*MAX_COX]),//Valid_T_00_02
                    .Valid_out_ip(Valid_out_ip[i + j*MAX_COX])//Valid_out_ip_00
                    );                    
                end
            else 
                begin :router_regular
                    router#( i,j) router(
                    .clk(clk),
                    .nreset(nreset),
                    .Data_L(Data_east[i + j*MAX_COX -1]),//Data_L_20_00
                    .Data_R(Data_west[i + j*MAX_COX +1]),//Data_R_10_00
                    .Data_T(Data_south[i + j*MAX_COX+MAX_COX]),//Data_T_01_00
                    .Data_B(Data_north[i + j*MAX_COX-MAX_COX]),//Data_B_02_00
                    .Data_IP(Data_ip_router[i + j*MAX_COX]),//Data_IP_00
                    .Valid_L(Valid_east[i + j*MAX_COX -1]),//Valid_L_20_00
                    .Valid_R(Valid_west[i + j*MAX_COX +1]),//Valid_R_10_00
                    .Valid_T(Valid_south[i + j*MAX_COX+MAX_COX]),//Valid_T_01_00
                    .Valid_B(Valid_north[i + j*MAX_COX-MAX_COX]),//Valid_B_02_00
                    .Valid_IP(Valid_ip_router[i + j*MAX_COX]),//Valid_IP_00
                    .Last_L(Last_east[i + j*MAX_COX -1]),//Last_L_20_00
                    .Last_R(Last_west[i + j*MAX_COX +1]),//Last_R_10_00
                    .Last_T(Last_south[i + j*MAX_COX+MAX_COX]),//Last_T_01_00
                    .Last_B(Last_north[i + j*MAX_COX-MAX_COX]),//Last_B_02_00
                    .Last_IP(Last_ip_router[i + j*MAX_COX]),//Last_IP_00

                    .Ready_L(Ready_east[i + j*MAX_COX -1]),//Ready_L_00_20
                    .Ready_R(Ready_west[i + j*MAX_COX +1]),//Ready_R_00_10
                    .Ready_T(Ready_south[i + j*MAX_COX+MAX_COX]),//Ready_T_00_01
                    .Ready_B(Ready_north[i + j*MAX_COX-MAX_COX]),//Ready_B_00_02
                    .Ready_IP(Ready_ip_router[i + j*MAX_COX]),//Ready_00_ip


                    .Ready_east(Ready_east[i + j*MAX_COX]),//Ready_L_10_00
                    .Ready_west(Ready_west[i + j*MAX_COX]),//Ready_R_20_00
                    .Ready_north(Ready_north[i + j*MAX_COX]),//Ready_B_01_00
                    .Ready_south(Ready_south[i + j*MAX_COX]),//Ready_T_02_00
                    .Ready_out_ip(Ready_out_ip[i + j*MAX_COX]),//Ready_out_ip_00
                    .Data_east(Data_east[i + j*MAX_COX]),//Data_L_00_10
                    .Data_west(Data_west[i + j*MAX_COX]),//Data_R_00_20
                    .Data_north(Data_north[i + j*MAX_COX]),//Data_B_00_01
                    .Data_south(Data_south[i + j*MAX_COX]),//Data_T_00_02
                    .Data_out_ip(Data_out_ip[i + j*MAX_COX]),//Data_out_ip_00
                    .Last_east(Last_east[i + j*MAX_COX]),//Last_L_00_10
                    .Last_west(Last_west[i + j*MAX_COX]),//Last_R_00_20
                    .Last_north(Last_north[i + j*MAX_COX]),//Last_B_00_01
                    .Last_south(Last_south[i + j*MAX_COX]),//Last_T_00_02
                    .Last_out_ip(Last_out_ip[i + j*MAX_COX]),//Last_out_ip_00
                    .Valid_east(Valid_east[i + j*MAX_COX]),//Valid_L_00_10
                    .Valid_west(Valid_west[i + j*MAX_COX]),//Valid_R_00_20
                    .Valid_north(Valid_north[i + j*MAX_COX]),//Valid_B_00_01
                    .Valid_south(Valid_south[i + j*MAX_COX]),//Valid_T_00_02
                    .Valid_out_ip(Valid_out_ip[i + j*MAX_COX])//Valid_out_ip_00
                    );
                end
        end
     end
 endgenerate


endmodule 