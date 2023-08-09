module xy_coordinate #(parameter MAX_VX =2,MAX_VY =2,MIN_v =0)
(

input logic  [31:0]x_cur,
input logic  [31:0]y_cur,
input logic  [6:0]x_final,
input logic  [6:0]y_final,
input logic  xy_enable,

output logic [4:0]four_direct



);

always_comb
	begin
	if(xy_enable)
		begin
		   four_direct ='0;
			if(x_final>x_cur)			//east
					begin 
						if(x_final == MAX_VX  && x_cur == MIN_v  )
							begin
								four_direct[1] = 1'b1;  //west
							end
						else 
							begin
								four_direct[0] = 1'b1;  //east
							end
					end
				else if(x_final < x_cur)		
						begin
							if(x_final == MIN_v  && x_cur == MAX_VX )
								begin
									four_direct[0] = 1'b1; //east
								end
							else 
								begin
									four_direct[1] = 1'b1; //west
								end
						end
				else if(x_final == x_cur)
					begin
						if(y_final> y_cur)		
						begin
							if(y_final == MAX_VY  && y_cur == MIN_v )
								begin
									four_direct[3]= 1'b1;  //south
								end
							else 
								begin
									four_direct[2]= 1'b1;  //north
								end
						end
						else if(y_final < y_cur)
							begin
							if(y_final == MIN_v  && y_cur == MAX_VY )
								begin
									four_direct[2]= 1'b1;  //north
								end
							else 
								begin
									four_direct[3]= 1'b1;  //south
								end
							end
						else if((y_final == y_cur) )
							begin
								four_direct[4] = 1'b1;   //the IP is in this router 
							end
							
					end		
					
		end
	else 
		four_direct ='0;
	
	end

// always_ff@(posedge clk,negedge nreset)
// 	if(!nreset)
// 		begin
// 		{Data_xy_east,Data_xy_west,Data_xy_north,Data_xy_south,Data_xy_ip}  <= '0;
// 		{last_xy_west,last_xy_east,last_xy_south,last_xy_north,last_xy_ip}  <= '0; 
		
// 		end
// 	else 
// 		begin
// 			if(xy_enable)
// 				begin
// 					case(four_direct)
// 						5'b00001:begin Data_xy_east  <= Data; last_xy_east   <= last_in_xy; end
// 						5'b00010:begin Data_xy_west  <= Data; last_xy_west   <= last_in_xy; end
// 						5'b00100:begin Data_xy_north <= Data; last_xy_north  <= last_in_xy; end
// 						5'b01000:begin Data_xy_south <= Data; last_xy_south  <= last_in_xy; end   
// 						5'b10000:begin Data_xy_ip    <= Data; last_xy_ip     <= last_in_xy; end
// 				default:begin
// 						//{Data_xy_east,Data_xy_west,Data_xy_north,Data_xy_south}  <= '0; 
// 						{last_xy_west,last_xy_east,last_xy_south,last_xy_north,last_xy_ip}  <= '0; 
// 						end
		
// 				endcase
// 				end
// 			else 
// 				begin
// 					{last_xy_west,last_xy_east,last_xy_south,last_xy_north,last_xy_ip}  <= '0; 
// 				end
// 		end
		
	
endmodule 