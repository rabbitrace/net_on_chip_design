`timescale 1ns/1ns
`define clk_period 20

module uart_byte_rx_tb;

	reg Clk;
	reg Rst_n;
	reg Rs232_Rx;
	
	wire [7:0]data_byte_r;
	wire Rx_Done;	
	
	reg [7:0]data_byte_t;
	reg send_en;
	reg [2:0]baud_set;
	
	wire Rs232_Tx;
	wire Tx_Done;
	wire uart_state;
	
	uart_byte_rx uart_byte_rx(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.baud_set(baud_set),
		.Rs232_Rx(Rs232_Tx),
		
		.data_byte(data_byte_r),
		.Rx_Done(Rx_Done)
	);
	
	uart_byte_tx uart_byte_tx(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.data_byte(data_byte_t),
		.send_en(send_en),
		.baud_set(baud_set),
		
		.Rs232_Tx(Rs232_Tx),
		.Tx_Done(Tx_Done),
		.uart_state(uart_state)
	);
	
	initial Clk = 1;
	always#(`clk_period/2)Clk = ~Clk;
	
	initial begin
		Rst_n = 1'b0;
		data_byte_t = 8'd0;
		send_en = 1'd0;
		baud_set = 3'd4;
		#(`clk_period*20 + 1 );
		Rst_n = 1'b1;
		#(`clk_period*50);
		data_byte_t = 8'haa;
		send_en = 1'd1;
		#`clk_period;
		send_en = 1'd0;
		
		@(posedge Tx_Done)
		
		#(`clk_period*5000);
		data_byte_t = 8'h55;
		send_en = 1'd1;
		#`clk_period;
		send_en = 1'd0;
		@(posedge Tx_Done)
		#(`clk_period*5000);
		$stop;	
	end


endmodule
