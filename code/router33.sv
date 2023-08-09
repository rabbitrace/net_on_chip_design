module router22_tb();

logic clk;
logic nreset;
logic error_led;
logic error_con;
logic send_en;


	router22 router22_0
(

  .clk(clk), 
  .nreset(nreset),
  .send_en(send_en),
  .error_led(error_led),
  .error_con(error_con) //led1 

);



initial 
	begin
		clk = '0;
		forever #20 clk = ~clk;
	end
	
initial 
	begin
		nreset = '0;
		send_en = '0;
		repeat(10)@(posedge clk);
		#1;
		nreset = '1;

		repeat(10)@(posedge clk);
		send_en = '1;
		@(posedge clk);
		send_en = '0;

		repeat(10)@(posedge clk);
		send_en = '1;
		@(posedge clk);
		send_en = '0;

		repeat(10)@(posedge clk);
		send_en = '1;
		@(posedge clk);
		send_en = '0;

		repeat(10)@(posedge clk);
		send_en = '1;
		@(posedge clk);
		send_en = '0;



		#1ms;
		$stop;
	
	end

endmodule 