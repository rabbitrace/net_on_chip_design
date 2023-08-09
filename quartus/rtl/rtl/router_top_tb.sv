module router_top_tb; 
 

 logic clk;
 logic nreset;
 logic key_in;
 logic key_out;
 logic key_cnt;

 logic Rs232_Tx;
 logic error_led;
 logic error_con;
 
 router_top router_top_0
(

.clk(clk), 
.nreset(nreset),  //switch0
.key_in(key_in),
.key_out(key_out),
.key_cnt(key_cnt),

.Rs232_Tx(Rs232_Tx),
.error_led(error_led), //led0
.error_con(error_con) //led1 
);

    initial
        begin
            clk = '0;
            forever #10  clk = ~clk;
        end
    
    initial 
        begin
            nreset = '0;
            key_in = '1;
            key_out = '1;
            key_cnt = '1;
            #41 nreset = '1;
            #200;
            key_in_change();
            repeat(8) key_cnt_change();
            key_out_change();
            repeat(8) key_cnt_change();
            //key_in_change();
            //key_in_change();
            #500;
            $stop;
        end

defparam  router_top_0.key_filter_0.CNT_MAX = 10;
defparam  router_top_0.key_filter_1.CNT_MAX = 10;
defparam  router_top_0.key_filter_2.CNT_MAX = 10;

task key_in_change;
      key_in = 1'b0;
      #1000;
      key_in = 1'b1;
      #1000;
endtask

task key_out_change;
      key_out = 1'b0;
       #1000;
      key_out = 1'b1;
      #1000;
endtask

task key_cnt_change;
      key_cnt = 1'b0;
       #1000;
      key_cnt = 1'b1;
      #1000;
endtask


endmodule 