
module fifo_tb();

 logic clk,rst_n,wr_en,rd_en,full,empty,almost_full,almost_empty;
 logic [32:0] wr_data,rd_data;

 fifo #(33,8) fifo_0 
(
    .clk(clk),
    .rst_n(rst_n),
    .wr_data(wr_data),
    .wr_en(wr_en), //write_enable 
    .rd_en(rd_en), //read_enable 
    .rd_data(rd_data),
    .full(full),
    .empty(empty),
    .almost_full(almost_full),
    .almost_empty(almost_empty)
);

    initial 
        begin
            clk = '0;
            forever #10 clk = ~clk;
        end

    initial 
        begin
            rst_n = '0;
            wr_data = 32'd1;
            rd_en ='0;
            wr_en = '0;
            repeat (10)@(posedge clk);
            #1;
            rst_n = '1;
            wr_en = '1;
            for(int i= 0;i<10;i =i +1)
                begin
                wr_data = wr_data + i;
                @(posedge clk);   
                end
            wr_en ='0;
            rd_en ='1;
            repeat (10)@(posedge clk);
            #500;
            $stop;            
        end


endmodule 