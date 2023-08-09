module fifo
#(
    parameter DATA_WIDTH = 33,
    FIFO_DEPTH = 8
)
(
    input  logic clk,
    input  logic rst_n,
    input  logic [DATA_WIDTH -1 :0] wr_data,
    input  logic wr_en, //write_enable 
    input  logic rd_en, //read_enable 
    output logic [DATA_WIDTH -1 :0] rd_data,
    output  logic full,
    output  logic empty,
    output logic  almost_full,
    output logic almost_full_one,
    output logic  almost_empty


);

localparam  ADDR_WIDTH = $clog2(FIFO_DEPTH);
logic [DATA_WIDTH -1:0]mem[FIFO_DEPTH -1:0]; //memory 
logic [ADDR_WIDTH: 0]wr_ptr;   // the bit must be more than one bit
logic [ADDR_WIDTH: 0]rd_ptr;

always@(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            begin
               wr_ptr <= '0; 
            end 
        else if(wr_en && !full)
            begin
                wr_ptr <= wr_ptr + 1'b1;
            end
    end

always@(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            begin
               rd_ptr <= '0; 
            end 
        else if(rd_en && !empty)
            begin
                rd_ptr <= rd_ptr + 1'b1;
            end
    end

always @(posedge clk or negedge rst_n) 
    begin
        integer i;
        if(!rst_n)
            begin
                for(i = 0; i <8; i = i + 1 )
                begin
                    mem[i] <= {DATA_WIDTH{1'b0}};  //inital the content of memory 
                end        
            end
        else if(wr_en && !full)
            begin
                mem[wr_ptr[ADDR_WIDTH -1:0]] <= wr_data;
            end
    end

always @(posedge clk or negedge rst_n) 
    begin
        if(!rst_n)
            begin
                rd_data <= '0;
            end
        else  if( rd_en && !empty)
            begin
                rd_data <= mem[rd_ptr[ADDR_WIDTH -1:0]];
            end
    end

assign empty = (wr_ptr == rd_ptr) ;
assign full  = (wr_ptr[ADDR_WIDTH -1:0] == rd_ptr[ADDR_WIDTH -1:0]) & (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]);

assign almost_full = (wr_ptr == (rd_ptr + 3'd7)); // two left

assign almost_full_one = (wr_ptr == (rd_ptr + 3'd7));

assign almost_empty = (wr_ptr == (rd_ptr +1'b1));



endmodule 