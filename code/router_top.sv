module router_top
(

input logic clk, 
input logic nreset,  //switch0
input logic key_in,
input logic key_out,
input logic key_cnt,

output logic Rs232_Tx,
output logic error_led, //led0
output logic error_con //led1 


);


logic key_flag;
logic key_state;
logic key_flag_tx;
logic key_state_tx;
logic key_flag_cnt;
logic key_state_cnt;

logic send_en;
logic send_en_tx;
logic send_en_cnt;

logic [7:0]data_byte;
logic send_en;
logic Tx_Done;
logic [`DATA_WIDTH -1 :0] data;

logic [3:0] data_cnt;


assign send_en = key_flag & !key_state;
assign send_en_tx = key_flag_tx & !key_state_tx;
assign send_en_cnt = key_flag_cnt & !key_state_cnt;

`ifdef BITS_WIDE_32_2
	logic [7:0] data_tmp[3:0];
	assign {data_tmp[3],data_tmp[2],data_tmp[1],data_tmp[0]} = data;
	always@(posedge clk,negedge nreset )
		begin
			if(!nreset)
				begin
					data_byte <= 8'b0;
				end
			else if(send_en_cnt && data_cnt == 4'd3)
				data_cnt <= 4'd0;
			else if(send_en_cnt)
				data_cnt <= data_cnt + 1'b1;
		end
endif

`ifdef BITS_WIDE_32_4
	logic [7:0] data_tmp[3:0];
	assign {data_tmp[3],data_tmp[2],data_tmp[1],data_tmp[0]} = data;
	always@(posedge clk,negedge nreset )
		begin
			if(!nreset)
				begin
					data_byte <= 8'b0;
				end
			else if(send_en_cnt && data_cnt == 4'd3)
				data_cnt <= 4'd0;
			else if(send_en_cnt)
				data_cnt <= data_cnt + 1'b1;
		end
endif

`ifdef BITS_WIDE_64_2
	logic [7:0] data_tmp[7:0];
	assign {data_tmp[7],data_tmp[6],data_tmp[5],data_tmp[4],data_tmp[3],data_tmp[2],data_tmp[1],data_tmp[0]} = data;
	always@(posedge clk,negedge nreset )
		begin
			if(!nreset)
				begin
					data_byte <= 8'b0;
				end
			else if(send_en_cnt && data_cnt == 4'd7)
				data_cnt <= 4'd0;
			else if(send_en_cnt)
				data_cnt <= data_cnt + 1'b1;
		end
endif

`ifdef BITS_WIDE_64_4
	logic [7:0] data_tmp[7:0];
	assign {data_tmp[7],data_tmp[6],data_tmp[5],data_tmp[4],data_tmp[3],data_tmp[2],data_tmp[1],data_tmp[0]} = data;
	always@(posedge clk,negedge nreset )
		begin
			if(!nreset)
				begin
					data_byte <= 8'b0;
				end
			else if(send_en_cnt && data_cnt == 4'd7)
				data_cnt <= 4'd0;
			else if(send_en_cnt)
				data_cnt <= data_cnt + 1'b1;
		end
endif



router22 router22_0
(

  .clk(clk), 
  .nreset(nreset),  
  .send_en(send_en),
  .send_en_tx(send_en_tx),
  .data(data);
  .error_led(error_led), 
  .error_con(error_con)  
);

key_filter key_filter_0(    //send_en inside 
	.Clk(clk),      
	.Rst_n(nreset),    
	.key_in(key_in),   
	.key_flag(key_flag), 
	.key_state(key_state) 
	);

key_filter key_filter_1(  //send_en outside 
	.Clk(clk),      
	.Rst_n(nreset),    
	.key_in(key_out),   
	.key_flag(key_flag_tx), 
	.key_state(key_state_tx) 
	);

key_filter key_filter_2(  //send_en outside 
	.Clk(clk),      
	.Rst_n(nreset),    
	.key_in(key_cnt),   
	.key_flag(key_flag_cnt), 
	.key_state(key_state_cnt) 
	);

uart_byte_tx uart_byte_tx(
	.Clk(clk),
	.Rst_n(nreset),
	.data_byte(data_tmp[data_cnt]),
	.send_en(send_en_tx),
	.baud_set(3'd0),
		
	.Rs232_Tx(Rs232_Tx),
	.Tx_Done(Tx_Done),
	.uart_state()
	);





endmodule 