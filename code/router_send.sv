`include "globe_def.sv"
module router_send  //#(X_CURRY =2 ,Y_CURRY = 2,TESET = 0)
(
input clk,
input nreset,

input logic [`DATA_WIDTH:0] Data_last_top,Data_last_bottom,Data_last_left,Data_last_right,Data_last_ip,
input logic Ready,


input logic empty_top,empty_bottom,empty_left,empty_right,empty_ip,

output logic rd_en_top,rd_en_left,rd_en_right,rd_en_bottom,rd_en_ip,

output logic Last_out,
output logic Valid,
output logic [`DATA_WIDTH -1:0]Data_out


);
//logic [31:0] Data_tmp;
// generate
//     if(X_CURRY == 0 && Y_CURRY == 1 && TESET == 1)
//         begin
//             hex u20 (
// 		        .probe (state)  // probes.probe
// 	        );    
//             hex u21 (
// 		        .probe (Data_last_ip[32:1])  // probes.probe
// 	        ); 
//             hex u22 (
// 		        .probe (Data_last_ip[0])  // probes.probe
// 	        );                  
//         end
// endgenerate




enum  logic[3:0]{IDLE,TRANSFER_TOP,TRANSFER_BOTTOM,TRANSFER_LEFT,TRANSFER_RIGHT,TRANSFER_IP,DATA_PREPARE,DONE} state;
//logic [`DATA_WIDTH -1:0]Data_out_tmp;
logic Last_out_tmp;

logic [2:0]dirction_cnt;

logic wait_top,wait_bottom,wait_left,wait_right,wait_ip;

always@(posedge clk , negedge  nreset)
	begin
		if(!nreset)
			begin
				state <= IDLE;
				//dirction_cnt <= 2'b0;
				Valid <= '0;
				{rd_en_top,rd_en_left,rd_en_right,rd_en_bottom,rd_en_ip} <= '0;
				{wait_top,wait_bottom,wait_left,wait_right,wait_ip} <= '1;
				//{Data_out_tmp,Last_out_tmp} <= '0;
				Data_out <= '0;
				Last_out <= '0;
			end
		else 
			begin
				case(state)
					IDLE:
						begin
							if(!empty_top && wait_top)
								begin
									rd_en_top <= 1'b1;
									state <= TRANSFER_TOP;
								end
							else if(!empty_bottom && wait_bottom)
								begin
									rd_en_bottom <= 1'b1;
									state <= TRANSFER_BOTTOM;
								end
							else if(!empty_left && wait_left) 
								begin
									rd_en_left <= 1'b1;
									state <= TRANSFER_LEFT;
								end
							else if(!empty_right && wait_right)
								begin
									rd_en_right <= 1'b1;
									state <= TRANSFER_RIGHT;
								end
							else if(!empty_ip && wait_ip)
								begin
									rd_en_ip <= 1'b1;
									state <= TRANSFER_IP;
								end
							else 
								begin
									state <= IDLE;
								end
						end
					TRANSFER_TOP:
						begin
							rd_en_top <= 1'b0;
							//Valid <= 1'b1;
							state <= DATA_PREPARE;
							{wait_bottom,wait_left,wait_right,wait_ip} <= '0;
							//{Data_out_tmp,Last_out_tmp} <= Data_last_top;								
						end
					TRANSFER_BOTTOM:
						begin
							rd_en_bottom <= 1'b0;
							//Valid <= 1'b1;
							state <= DATA_PREPARE;
							{wait_top,wait_left,wait_right,wait_ip} <= '0;
							//{Data_out_tmp,Last_out_tmp} <= Data_last_bottom;
						end
					TRANSFER_LEFT:
						begin
							rd_en_left <= 1'b0;
							//Valid <= 1'b1;
							state <= DATA_PREPARE;
							{wait_top,wait_bottom,wait_right,wait_ip} <= '0;
							//{Data_out_tmp,Last_out_tmp} <= Data_last_left;
						end
					TRANSFER_RIGHT:
						begin
							rd_en_right <= 1'b0;
							//Valid <= 1'b1;
							state <= DATA_PREPARE;
							{wait_top,wait_bottom,wait_left,wait_ip} <= '0;
							//{Data_out_tmp,Last_out_tmp} <= Data_last_right;								
						end
					TRANSFER_IP:
						begin
							rd_en_ip <= 1'b0;
							//Valid <= 1'b1;
							state <= DATA_PREPARE;
							{wait_top,wait_bottom,wait_left,wait_right} <= '0;
							//{Data_out_tmp,Last_out_tmp} <= Data_last_ip;
						end
					DATA_PREPARE:
						begin
							state <= DONE;
							Valid <= 1'b1;
							if(wait_top)
								{Data_out,Last_out} <= Data_last_top;	
							else if(wait_bottom)
								{Data_out,Last_out} <= Data_last_bottom;
							else if(wait_left)
								{Data_out,Last_out} <= Data_last_left;
							else if(wait_right)
								{Data_out,Last_out} <= Data_last_right;	
							else if(wait_ip)
								{Data_out,Last_out} <= Data_last_ip;
						end

					DONE:
						begin
							//Data_out <= Data_out_tmp;
							//Last_out <= Last_out_tmp;
							if(Ready)
								begin
									Valid <= 1'b0;
									state <= IDLE;
									if(Last_out)
										begin
											{wait_top,wait_bottom,wait_left,wait_right,wait_ip} = '1; 
										end
								end
							else 
								begin
									state <= DONE;
								end
						end
				endcase
			end
	end		

endmodule 