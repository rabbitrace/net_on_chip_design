`include "globe_def.sv"
module router_receive #(X_CURRY =2 ,Y_CURRY = 2)//#(X_CURRY =2 ,Y_CURRY = 2,TESET = 0)
(
input clk,nreset,
input logic[`DATA_WIDTH -1 :0]Data,
input logic Valid,
input logic Last,

input logic rd_en_east,rd_en_west,rd_en_north,rd_en_south,rd_en_ip,


output logic Ready,

//FIFO port
output logic empty_east,empty_west,empty_north,empty_south,empty_ip,
output logic [`DATA_WIDTH:0]rd_data_east,rd_data_west,rd_data_north,rd_data_south,rd_data_ip

);


logic [$clog2(128) -1:0]x_final,y_final;
logic wr_en,rd_en,full,empty,almost_full,almost_empty,almost_full_one;
//logic [DATA_WIDTH -1 :0]Data_tmp,Data_out_tmp;
logic [`DATA_WIDTH -1 :0]Data_tmp;
//logic last_tmp,last_out_tmp;
logic last_tmp;
logic [`DATA_WIDTH:0]rd_data;

logic [4:0]four_direct;

logic xy_enable;


logic full_east,full_west,full_north,full_south,full_ip;

logic wr_en_east,wr_en_west,wr_en_north,wr_en_south,wr_en_ip;

logic Valid_tmp;

localparam  FIFO_WIDTH = `DATA_WIDTH + 1;

enum logic[2:0]{IDLE,TRANSFER,WAIT,WAIT_LAST,DONE} state,state_xy;

// generate
//     if(X_CURRY == 0 && Y_CURRY == 1 && TESET == 1)
//         begin
//             hex u10 (
// 		        .probe (state)  // probes.probe
// 	        ); 
//             hex u11 (
// 		        .probe (state_xy)  // probes.probe
// 	        ); 
//             hex u12 (
// 		        .probe (wr_en)  // probes.probe
// 	        ); 
//             hex u13 (
// 		        .probe (Data_tmp)  // probes.probe
// 	        ); 
//             hex u14 (
// 		        .probe (rd_en)  // probes.probe
// 	        ); 
//             hex u15 (
// 		        .probe (rd_data[32:1])  // probes.probe
// 	        ); 
//             hex u16 (
// 		        .probe (four_direct)  // probes.probe
// 	        );  
//             hex u17 (
// 		        .probe (wr_en_ip)  // probes.probe
// 	        );
//             hex u18 (
// 		        .probe (rd_en_ip)  // probes.probe
// 	        ); 
//             hex u19 (
// 		        .probe (rd_data_ip[32:1])  // probes.probe
// 	        );   
                  
//         end
// endgenerate


always_ff@(posedge clk,negedge nreset)
    begin
        if(!nreset)    
            begin
                Valid_tmp <= '0;
            end
        else 
            begin
                Valid_tmp <= Valid;
            end
    end
    

//fifo receive 
always_ff@(posedge clk,negedge nreset)
    begin
        if(!nreset)
            begin
                state <= IDLE;
                Data_tmp <= '0;
                last_tmp <= '0;  
                wr_en <= '0;
                Ready <= '0;             
            end
        else 
            begin
                case(state)
                    IDLE:
                        begin
                            if(Valid_tmp)
                                begin
                                    if(almost_full || full)
                                        begin
                                            Ready <= 1'b0;
                                        end
                                    else 
                                        begin
                                            Ready <= 1'b1;  
                                            state <= TRANSFER;
                                        end
                                        
                                end
                        end
                    TRANSFER:
                        begin
                            if(Valid)
                                begin
                                    Data_tmp <= Data;
                                    last_tmp <= Last;
                                    wr_en <= 1'b1; 
                                    if(almost_full && Last == 1'b1)
                                        begin
                                            Ready <= 1'b0;
                                            wr_en <= 1'b0;
                                            state <= WAIT_LAST;
                                        end
                                    else if(almost_full && Last == 1'b0)
                                        begin
                                            Ready <= 1'b0;
                                            wr_en <= 1'b0;  
                                            state <= WAIT;                                          
                                        end
                                    else if(Last == 1'b1)
                                        begin
                                            Ready <= 1'b0;
                                            //wr_en <= 1'b0;
                                            //last_tmp <= 1'b0;
                                            state <= DONE;                                           
                                        end
                                    else 
                                        begin
                                            state <= TRANSFER; 
                                        end
                                end 
                            else 
                                begin
                                    wr_en <= 1'b0; 
                                    state <= TRANSFER;
                                end
                        end
                    WAIT:
                        begin
                            if(full)
                                begin
                                    state <= WAIT;
                                end
                            else if(almost_full)
                                begin
                                    
                                    state <= WAIT; 
                                end
                            else 
                                begin
                                    wr_en <= 1'b1;
                                    Ready <= 1'b1; 
                                    state <= TRANSFER;        
                                end 
                        end
                    WAIT_LAST:
                        begin
                            if(full)
                                begin
                                    state <= WAIT_LAST;
                                end
                            else if(almost_full)
                                begin
                                    
                                    state <= WAIT_LAST; 
                                end
                            else 
                                begin
                                    wr_en <= 1'b1; 
                                    state <= DONE;        
                                end 
                        end                       
                    DONE:
                        begin
                            wr_en <= 1'b0;
                            state <= IDLE; 
                        end

                endcase
            end
    end

always@(posedge clk,negedge nreset)
    begin
        if(!nreset)
            begin
                state_xy <= IDLE;
                rd_en <= '0;
                //Data_out_tmp <='0;
                //last_out_tmp <='0;
                xy_enable <= '0;
                {wr_en_east,wr_en_west,wr_en_north,wr_en_south,wr_en_ip} <= '0;
            end 
        else 
            case(state_xy)
                IDLE:
                    begin
                        xy_enable <= 1'b0;
                        {wr_en_east,wr_en_west,wr_en_north,wr_en_south,wr_en_ip} <= '0;
                        if(!empty)
                            begin
                                rd_en <=1;
                                state_xy <= WAIT;
                            end 
                        else 
                            begin
                                rd_en <= '0;
                                state_xy <= IDLE;
                            end
                    end
                WAIT:
                    begin
                        rd_en <= '0;
                        state_xy <= TRANSFER;
                        //{Data_out_tmp,last_out_tmp} <= rd_data;
                        //xy_enable <= 1'b1;
                    end
                TRANSFER:
                    begin
                        rd_en <= '0;
                        xy_enable <= 1'b1;
                        state_xy <= IDLE;
                        if((four_direct[0]) &&  !full_east)
                            begin
                                wr_en_east <= 1'b1;
                            end
                        else if((four_direct[1]) &&  !full_west)
                            begin
                                wr_en_west <= 1'b1;
                            end
                        else if((four_direct[2]) &&  !full_north)
                            begin
                                wr_en_north <= 1'b1;
                            end
                        else if((four_direct[3]) &&  !full_south)
                            begin
                                wr_en_south <= 1'b1;    
                            end
                        else if((four_direct[4]) &&  !full_ip)
                            begin
                                wr_en_ip <= 1'b1; 
                            end
                        else 
                            begin
                                xy_enable <= 1'b1;
                                state_xy <= TRANSFER;  //  fifo is not empty 
                            end
                    end
            endcase
    end



assign x_final = rd_data[`DATA_WIDTH-:7];
assign y_final = rd_data[`DATA_WIDTH -7-:7];

fifo #(FIFO_WIDTH,`FIFO_DEPTH) fifo_0
(
    .clk(clk),
    .rst_n(nreset),
    .wr_data({Data_tmp,last_tmp}),
    .wr_en(wr_en), //write_enable 
    .rd_en(rd_en), //read_enable 
    .rd_data(rd_data),
    .full(full),
    .empty(empty),
    .almost_full_one(almost_full_one),
    .almost_full(almost_full),
    .almost_empty(almost_empty)
);


fifo #(FIFO_WIDTH,`FIFO_DEPTH) fifo_east
(
    .clk(clk),
    .rst_n(nreset),
    .wr_data(rd_data),
    .wr_en(wr_en_east), //write_enable 
    .rd_en(rd_en_east), //read_enable 
    .rd_data(rd_data_east),
    .full(full_east),
    .empty(empty_east),
    .almost_full_one(),
    .almost_full(),
    .almost_empty()
);

fifo #(FIFO_WIDTH,`FIFO_DEPTH) fifo_west
(
    .clk(clk),
    .rst_n(nreset),
    .wr_data(rd_data),
    .wr_en(wr_en_west), //write_enable 
    .rd_en(rd_en_west), //read_enable 
    .rd_data(rd_data_west),
    .full(full_west),
    .empty(empty_west),
    .almost_full_one(),
    .almost_full(),
    .almost_empty()
);


fifo #(FIFO_WIDTH,`FIFO_DEPTH) fifo_north
(
    .clk(clk),
    .rst_n(nreset),
    .wr_data(rd_data),
    .wr_en(wr_en_north), //write_enable 
    .rd_en(rd_en_north), //read_enable 
    .rd_data(rd_data_north),
    .full(full_north),
    .empty(empty_north),
    .almost_full_one(),
    .almost_full(),
    .almost_empty()
);

fifo #(FIFO_WIDTH,`FIFO_DEPTH) fifo_south
(
    .clk(clk),
    .rst_n(nreset),
    .wr_data(rd_data),
    .wr_en(wr_en_south), //write_enable 
    .rd_en(rd_en_south), //read_enable 
    .rd_data(rd_data_south),
    .full(full_south),
    .empty(empty_south),
    .almost_full_one(),
    .almost_full(),
    .almost_empty()
);

fifo #(FIFO_WIDTH,`FIFO_DEPTH) fifo_ip
(
    .clk(clk),
    .rst_n(nreset),
    .wr_data(rd_data),
    .wr_en(wr_en_ip), //write_enable 
    .rd_en(rd_en_ip), //read_enable 
    .rd_data(rd_data_ip),
    .full(full_ip),
    .empty(empty_ip),
    .almost_full_one(),
    .almost_full(),
    .almost_empty()
);


xy_coordinate #(`MAX_VX,`MAX_VY,`MIN_V) xy_coordinate_0
(
   .x_cur(X_CURRY),
   .y_cur(Y_CURRY),
   .x_final(x_final),
   .y_final(y_final),
   .xy_enable(xy_enable),
   .four_direct(four_direct) // actual four_direct is enable signal 

);

endmodule 