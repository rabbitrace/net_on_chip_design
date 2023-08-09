module router_tb();


logic  clk;
logic  nreset;
logic  [31:0]Data_L,Data_R,Data_T,Data_B,Data_IP;
logic  Valid_L,Valid_R,Valid_T,Valid_B,Valid_IP;
logic  Last_L,Last_R,Last_T,Last_B,Last_IP;

logic Ready_L,Ready_R,Ready_T,Ready_B,Ready_IP;
logic  Ready_east,Ready_west,Ready_north,Ready_south,Ready_out_ip;

logic [31:0]Data_east,Data_west,Data_north,Data_south,Data_out_ip;
logic Last_east,Last_west,Last_north,Last_south,Last_out_ip;
logic Valid_east,Valid_west,Valid_north,Valid_south,Valid_out_ip;



 router#( 2, 2,4,0) router_0(
 .clk(clk),
 .nreset(nreset),
 .Data_L(Data_L),
 .Data_R(Data_R),
 .Data_T(Data_T),
 .Data_B(Data_B),
 .Data_IP(Data_IP),
 .Valid_L(Valid_L),
 .Valid_R(Valid_R),
 .Valid_T(Valid_T),
 .Valid_B(Valid_B),
 .Valid_IP(Valid_IP),
 .Last_L(Last_L),
 .Last_R(Last_R),
 .Last_T(Last_T),
 .Last_B(Last_B),
 .Last_IP(Last_IP),

 .Ready_L(Ready_L),
 .Ready_R(Ready_R),
 .Ready_T(Ready_T),
 .Ready_B(Ready_B),
 .Ready_IP(Ready_IP),
 .Ready_east(Ready_east),
 .Ready_west(Ready_west),
 .Ready_north(Ready_north),
 .Ready_south(Ready_south),
 .Ready_out_ip(Ready_out_ip),

 .Data_east(Data_east),
 .Data_west(Data_west),
 .Data_north(Data_north),
 .Data_south(Data_south),
 .Data_out_ip(Data_out_ip),
 .Last_east(Last_east),
 .Last_west(Last_west),
 .Last_north(Last_north),
 .Last_south(Last_south),
 .Last_out_ip(Last_out_ip),
 .Valid_east(Valid_east),
 .Valid_west(Valid_west),
 .Valid_north(Valid_north),
 .Valid_south(Valid_south),
 .Valid_out_ip(Valid_out_ip)

);

initial 
	begin
		clk = '0;
		forever #20 clk = ~clk;
	end
	
	
initial 
	begin
		nreset = '0;
		Ready_west = '0;
		{Valid_L,Valid_R,Last_T,Last_B,Last_IP} = '0;
		{Last_L,Last_R,Last_T,Last_B,Last_IP}= '0;
		repeat(10)@(posedge clk);
		#1;
		nreset = '1;
		Data_L = {7'd1,7'd1,18'd1};
		Valid_L = 1'd1;
		Last_L = 1'd1;
		while(1)
			begin
				if(Ready_L == 1)
					break;
				@(posedge clk);
			end
		Valid_L = 1'b0;
		Last_L = 1'b0;
		Ready_west = 1'b1;
		
		while(1)
			begin
				if(Last_west == 1)
					break;
				@(posedge clk);
			
			end
		#500ns	
		$stop;
		
		
	end




endmodule 