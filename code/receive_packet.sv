module receive_packet#(parameter FILE_NAME = "H:/vivado_project/router/print_file/file_00.txt")
(
input clk,
input [31:0]memory[7:0],
input [2:0] address

//input [31:0]memory[1023:0],
//input [9:0] address
);

int  fid;
int memory_address = 0;

logic [31:0]memory_tmp[1023:0];
localparam INDE = 8;
localparam WIDTH =32;

//logic [6:0] x_cur,y_cur,x_des,y_des


initial
	begin
		while(1)
			begin
				if($isunknown(memory[0])== 1)
					@(posedge clk);
				else 
					break;
			end

		while(1)
			begin
				// fid = $fopen("H:/vivado_project/router/print_file/file_00.txt","a");
				// $fwrite(fid,"simulation time is %t  address = %d",$time,address);
				// $fwrite(fid,"\n------------------------------------------------------------------\n");
				// @(posedge clk);
				if(address ==3'd0)
					begin
						//repeat(7)@(posedge clk);
						fid = $fopen(FILE_NAME,"a");
						for(int i=0;i<INDE;i++)
							begin
								//memory_tmp[memory_address:memory_address + 7] =  memory;
								//$fwrite(fid," %h\n",memory_tmp[memory_address + i]);
								$fwrite(fid," %h this packet is from x y = [%d][%d] \n",memory[i],memory[i][17:11],memory[i][10:4]);
								/*for(int j=0;j<WIDTH;j++)
									begin
										if(j==0)
											begin
												$fwrite(fid,"x_des = %b",memory[i][j]);
											end
										else if(j==7)
											begin
												$fwrite(fid,"y_des = %b",memory[i][j]);
											end
										else if(j== 14)
											begin
												$fwrite(fid,"y_des = %b",memory[i][j]);
											end
											begin
												$fwrite(fid,"x_des = %h",memory[i][j]);
											end
										
									end
									$fwrite(fid,"\n");
								    //$fwrite(fid,"the packet come from x=%d y=%d the content = %b",memory[i][31:25],memory[i][24:18],memory[i]);
								*/
							end
						$fwrite(fid,"simulation time is %t",$time);
						memory_address = memory_address + 3'd7;
						$fwrite(fid,"\n------------------------------------------------------------------\n");
						$fclose(fid);
						repeat(6)@(posedge clk);
					end
				else 
					begin
					@(posedge clk);
					end
				
			end
	end

endmodule 