`include "globe_def.sv"
module fake_ip #(parameter X_DES = 2,Y_DES = 2,X_CUR = 2 ,Y_CUR =2,MAX_SEND_PACKET= 5, FILE_NAME_SNED = "H:/vivado_project/router/print_file/send_file_00.txt",FILE_NAME_RECEIVE ="H:/vivado_project/router/print_file/receive_file_00.txt")
(
input clk,
input nreset,
input send_en,
input send_en_tx,

input Valid_IP,
input [`DATA_WIDTH -1 :0]Data_IP,
input Last_IP,

output logic Ready_IP,

input  logic  Ready_out_ip,
output logic [`DATA_WIDTH -1:0]Data_out_ip,
output logic Last_out_ip,
output logic Valid_out_ip,

output logic [`DATA_WIDTH -1 :0]data,
output logic [9:0]receive_cnt,
output logic [9:0]send_cnt,

output logic error_flag


//output logic [31:0]memory[1023:0],
//output logic [9:0]address
);





logic [3:0]packet_cnt;

logic [`DATA_WIDTH -1 :0]memory[15:0];
logic [3:0]address;
logic [3:0] memory_addr_cnt;


//logic [7:0]all_send_cnt;

//logic [31:0] Data_ver;

enum  logic[1:0]{IDLE,TRANSFER,DONE} state;

enum  logic[2:0]{IDLE_PACKET,TRANSFER_PACKET,FIRST,SECOND,THIRD,FORTH,DONE_PACKET} state_packet;

localparam time_cnt_max = 6'd30 ;

assign data = memory[memory_addr_cnt];


reg [6:0]last_cnt;

always@(posedge clk or negedge nreset)
	begin
		if(!nreset)
			begin
				memory_addr_cnt <= 4'd0;
			end
		else if(memory_addr_cnt == 4'd15 && send_en_tx)
			begin
				memory_addr_cnt <= 4'd0;
			end
		else if(send_en_tx)
			begin
				memory_addr_cnt <= memory_addr_cnt +1'b1;
			end
	end

always @(posedge clk or negedge nreset) begin
	if(!nreset)
		begin
			last_cnt <= 7'd0;
		end
	else if(state == TRANSFER && Last_IP)
		begin
			last_cnt <= last_cnt +1'b1;
		end	
end

//assign Ready_out_ip = (state == IDLE)?1'b1:1'b0;

//IP receive 
always@(posedge clk,negedge nreset)
	begin
		if(!nreset)
			begin
				address <= '0;
				state <= IDLE;
				Ready_IP <= 1'b0;
				receive_cnt  <= '0;
			end
		else 
			case(state)
				IDLE:
					begin
						Ready_IP <= 1'b1;
						if(Valid_IP)
							begin
								if(address == 4'd15)
									begin
										address <= '0;
									end
								else 
									begin
										address <= address + 1'b1;
									end
								memory[address] <= Data_IP;
								state <= TRANSFER;
							end
						else 
							begin
								state <= IDLE;
							end
					end
				TRANSFER:
					begin
						if(Valid_IP)
							begin
							if(address == 4'd15)
								begin
									address <= '0;
								end
							else 
								begin
									address <= address + 1'b1;
								end
							memory[address] <= Data_IP;
							if(Last_IP)
								begin
									state <= IDLE;
									Ready_IP <= 1'b0;
									receive_cnt  <= receive_cnt + 1'b1;
								end
							else 
								begin
									state <= TRANSFER;
								end
							end	
					end
				/*DONE:
					begin
						state <= IDLE;
					end
				*/
			endcase
	
	end

always@( posedge clk,negedge nreset ) 
	begin 
		if(!nreset)
			begin
				error_flag   <= '0;
			end
		else if(Valid_IP)
			begin
				if((Data_IP[`DATA_WIDTH -1 -: 7]== X_CUR[6:0]) && (Data_IP[`DATA_WIDTH -8 -:7] == Y_CUR[6:0]) )
					begin
						error_flag <= 0;
					end
				else 
					begin
						error_flag <= 1;
					end
			end
	end

logic [5:0] time_cnt;
always @(posedge clk,negedge nreset) 
	begin
		if(!nreset)
			begin
				time_cnt <= '0;
			end
		else if (time_cnt == time_cnt_max)
			begin
				time_cnt <= '0;
			end
		else if(state_packet == DONE_PACKET)
			time_cnt = time_cnt +1'b1;
	end




//IP send  	
`ifdef BITS_WIDE_64_4
always@(posedge clk,negedge nreset)
	begin
		if(!nreset)
			begin
				Data_out_ip  <= '0;
				Last_out_ip  <= '0;
				Valid_out_ip <= '0;
				packet_cnt <= '0;
				send_cnt <= '0;
				state_packet <= IDLE_PACKET;
			end
		else 
			begin
				case(state_packet)
				IDLE_PACKET:
					begin
						if(send_cnt == MAX_SEND_PACKET)
							begin
								state_packet <= IDLE_PACKET;
							end
						else if(send_en)
							begin
								Data_out_ip  <= {X_DES[6:0],Y_DES[6:0],X_CUR[6:0],Y_CUR[6:0],32'b0,4'b0};
								state_packet <= TRANSFER_PACKET;								
							end
						else if(!send_en)
							begin
								state_packet <= IDLE_PACKET;
							end
					end
				TRANSFER_PACKET:
					begin
					    packet_cnt <= packet_cnt + 1'b1;
						Valid_out_ip <= 1'b1;
						state_packet <= FIRST;
					end
				FIRST:
					begin
						if(Ready_out_ip)
							begin
								Data_out_ip  <= {X_DES[6:0],Y_DES[6:0],X_CUR[6:0],Y_CUR[6:0],32'b1,4'b0};
								state_packet <= SECOND;
							end
						else 
							begin
								state_packet <= FIRST;
							end
					end
				SECOND:
					begin
						if(Ready_out_ip)
							begin
								Data_out_ip  <= {X_DES[6:0],Y_DES[6:0],X_CUR[6:0],Y_CUR[6:0],32'b1,4'b0};
								state_packet <= THIRD;
							end
						else 
							begin
								state_packet <= SECOND;
							end						
					end
				THIRD:
					begin
						if(Ready_out_ip)
							begin
								Data_out_ip  <= {X_DES[6:0],Y_DES[6:0],X_CUR[6:0],Y_CUR[6:0],32'b1,packet_cnt};
								Last_out_ip  <= 1'b1;
								state_packet <= FORTH;
							end
						else 
							begin
								state_packet <= THIRD;
							end
					end
				FORTH:
					begin
						if(Ready_out_ip)
							begin
								Valid_out_ip <= 1'b0;
								Last_out_ip  <= 1'b0;
								send_cnt <= send_cnt +1'b1;
								state_packet <= DONE_PACKET;
							end
						else 
							begin
								state_packet <= FORTH;
							end
					end
				DONE_PACKET:
					begin
						if(time_cnt == time_cnt_max)
							begin
								state_packet <= IDLE_PACKET;
							end
						else 
							begin
								state_packet <= DONE_PACKET;
							end
					end
				endcase
			end
	end
`endif

`ifdef BITS_WIDE_32_4
always@(posedge clk,negedge nreset)
	begin
		if(!nreset)
			begin
				Data_out_ip  <= '0;
				Last_out_ip  <= '0;
				Valid_out_ip <= '0;
				packet_cnt <= '0;
				send_cnt <= '0;
				state_packet <= IDLE_PACKET;
				led <='0;
			end
		else 
			begin
				case(state_packet)
				IDLE_PACKET:
					begin
						if(send_cnt == MAX_SEND_PACKET)
							begin
								state_packet <= IDLE_PACKET;
							end
						else if(send_en)
							begin
								Data_out_ip  <= {X_DES[6:0],Y_DES[6:0],X_CUR[6:0],Y_CUR[6:0],4'b0};
								state_packet <= TRANSFER_PACKET;								
							end
						else if(!send_en)
							state_packet <= IDLE_PACKET;

					end
				TRANSFER_PACKET:
					begin
					    packet_cnt <= packet_cnt + 1'b1;
						Valid_out_ip <= 1'b1;
						state_packet <= FIRST;
					end
				FIRST:
					begin
						if(Ready_out_ip)
							begin
								Data_out_ip  <= {X_DES[6:0],Y_DES[6:0],X_CUR[6:0],Y_CUR[6:0],4'b0};
								//Last_out_ip  <= 1'b1;
								state_packet <= SECOND;
							end
						else 
							begin
								state_packet <= FIRST;
							end
					end
				SECOND:
					begin
						if(Ready_out_ip)
							begin
								Data_out_ip  <= {X_DES[6:0],Y_DES[6:0],X_CUR[6:0],Y_CUR[6:0],4'b0};
								//Valid_out_ip <= 1'b0;
								//Last_out_ip  <= 1'b1;
								//send_cnt <= send_cnt +1'b1;
								state_packet <= THIRD;
							end
						else 
							begin
								state_packet <= SECOND;
							end						
					end
				THIRD:
					begin
						if(Ready_out_ip)
							begin
								Data_out_ip  <= {X_DES[6:0],Y_DES[6:0],X_CUR[6:0],Y_CUR[6:0],packet_cnt};
								//Valid_out_ip <= 1'b0;
								Last_out_ip  <= 1'b1;
								//send_cnt <= send_cnt +1'b1;
								state_packet <= FORTH;
							end
						else 
							begin
								state_packet <= THIRD;
							end
					end
				FORTH:
					begin
						if(Ready_out_ip)
							begin
								Valid_out_ip <= 1'b0;
								Last_out_ip  <= 1'b0;
								send_cnt <= send_cnt +1'b1;
								state_packet <= DONE_PACKET;
								led <= '1;
							end
						else 
							begin
								state_packet <= FORTH;
							end
					end
				DONE_PACKET:
					begin
						if(time_cnt == time_cnt_max)
							begin
								state_packet <= IDLE_PACKET;
							end
						else 
							begin
								state_packet <= DONE_PACKET;
							end
					end
				endcase
			end
	end
`endif

`ifdef BITS_WIDE_64_2
always@(posedge clk,negedge nreset)
	begin
		if(!nreset)
			begin
				Data_out_ip  <= '0;
				Last_out_ip  <= '0;
				Valid_out_ip <= '0;
				packet_cnt <= '0;
				send_cnt <= '0;
				state_packet <= IDLE_PACKET;
			end
		else 
			begin
				case(state_packet)
				IDLE_PACKET:
					begin
						if(send_cnt == MAX_SEND_PACKET)
							begin
								state_packet <= IDLE_PACKET;
							end
						else if(send_en)
							begin
								Data_out_ip  <= {X_DES[6:0],Y_DES[6:0],X_CUR[6:0],Y_CUR[6:0],32'b0,4'b0};
								state_packet <= TRANSFER_PACKET;								
							end
						else if(!send_en)
								state_packet <= IDLE_PACKET;
					end
				TRANSFER_PACKET:
					begin
					    packet_cnt <= packet_cnt + 1'b1;
						Valid_out_ip <= 1'b1;
						state_packet <= FIRST;
					end
				FIRST:
					begin
						if(Ready_out_ip)
							begin
								Data_out_ip  <= {X_DES[6:0],Y_DES[6:0],X_CUR[6:0],Y_CUR[6:0],32'b0,packet_cnt};
								Last_out_ip  <= 1'b1;
								state_packet <= SECOND;
							end
						else 
							begin
								state_packet <= FIRST;
							end
					end
				SECOND:
					begin
						if(Ready_out_ip)
							begin
								Valid_out_ip <= 1'b0;
								Last_out_ip  <= 1'b0;
								send_cnt <= send_cnt +1'b1;
								state_packet <= DONE_PACKET;
							end
						else 
							begin
								state_packet <= SECOND;
							end						
					end
				DONE_PACKET:
					begin
						if(time_cnt == time_cnt_max)
							begin
								state_packet <= IDLE_PACKET;
							end
						else 
							begin
								state_packet <= DONE_PACKET;
							end
					end
				endcase
			end
	end
`endif

`ifdef BITS_WIDE_32_2
always@(posedge clk,negedge nreset)
	begin
		if(!nreset)
			begin
				Data_out_ip  <= '0;
				Last_out_ip  <= '0;
				Valid_out_ip <= '0;
				packet_cnt <= '0;
				send_cnt <= '0;
				state_packet <= IDLE_PACKET;
			end
		else 
			begin
				case(state_packet)
				IDLE_PACKET:
					begin
						if(send_cnt == MAX_SEND_PACKET)
							begin
								state_packet <= IDLE_PACKET;
							end
						else if(send_en)
							begin
								Data_out_ip  <= {X_DES[6:0],Y_DES[6:0],X_CUR[6:0],Y_CUR[6:0],4'b0};
								state_packet <= TRANSFER_PACKET;								
							end
						else if(!send_en)
							 state_packet <= IDLE_PACKET;

					end
				TRANSFER_PACKET:
					begin
					    packet_cnt <= packet_cnt + 1'b1;
						Valid_out_ip <= 1'b1;
						state_packet <= FIRST;
					end
				FIRST:
					begin
						if(Ready_out_ip)
							begin
								Data_out_ip  <= {X_DES[6:0],Y_DES[6:0],X_CUR[6:0],Y_CUR[6:0],packet_cnt};
								Last_out_ip  <= 1'b1;
								state_packet <= SECOND;
							end
						else 
							begin
								state_packet <= FIRST;
							end
					end
				SECOND:
					begin
						if(Ready_out_ip)
							begin
								Valid_out_ip <= 1'b0;
								Last_out_ip  <= 1'b0;
								send_cnt <= send_cnt +1'b1;
								state_packet <= DONE_PACKET;
							end
						else 
							begin
								state_packet <= SECOND;
							end						
					end
				DONE_PACKET:
					begin
						if(time_cnt == time_cnt_max)
							begin
								state_packet <= IDLE_PACKET;
							end
						else 
							begin
								state_packet <= DONE_PACKET;
							end
					end
				endcase
			end
	end
`endif





//int fid;
//
//initial 
//	begin
//		fid = $fopen(FILE_NAME_SNED,"w");
//		$fwrite(fid,"");
//		$fclose(fid);
//		while(1)
//			begin
//				if(state_packet == TRANSFER)	
//					begin
//						fid = $fopen(FILE_NAME_SNED,"a");
//							
//						$fwrite(fid," %h this packet is sent to  x y = [%d][%d] \n",Data_out_ip,Data_out_ip[31:25],Data_out_ip[24:18]);
//						//$fwrite(fid,"send_cnt [%d%d] ==  %d, ",Data_out_ip[17:11],Data_out_ip[10:4],send_cnt);	
//						$fwrite(fid,"simulation time is %t",$time);
//						$fwrite(fid,"\n------------------------------------------------------------------\n");
//						$fclose(fid);
//						@(posedge clk);
//					end
//				else 
//					begin
//						@(posedge clk);
//					end
//			end
//	end
//
//int fid_receive;
//	initial 
//		begin
//			//while(1)
//				//begin
//			fid_receive = $fopen(FILE_NAME_RECEIVE,"w");
//					//if($fsize(fid_receive) > 0 )
//						//begin
//							//$fseek(fid_receive,0,"SEEK_SET");
//			$fwrite(fid_receive,"");
//			$fclose(fid_receive);
//			//@(posedge clk);							
//						//end
//					//else 
//						//begin
//							//@(posedge clk);	
//							//break;
//						//end
//				//end
//			while(1)
//				begin
//					if(state == TRANSFER && Valid_IP == 1'b1)
//						begin
//							fid_receive = $fopen(FILE_NAME_RECEIVE,"a");
//
//							$fwrite(fid_receive," %h this packet is  receive from  x y = [%d][%d] \n",Data_IP,Data_IP[17:11],Data_IP[10:4]);
//							$fwrite(fid_receive,"simulation time is %t",$time);
//							$fwrite(fid_receive,"simulation time is %t",$time);
//							$fwrite(fid_receive,"\n------------------------------------------------------------------\n");
//							$fclose(fid_receive);	
//							@(posedge clk);						
//						end
//					else 
//						begin
//							@(posedge clk);
//						end
//				end
//		end





endmodule 