`include "globe_def.sv"
module router#(parameter X_CUR = 2, Y_CUR=2)

(
input clk,
input nreset,
input [`DATA_WIDTH -1:0]Data_L,Data_R,Data_T,Data_B,Data_IP,
input Valid_L,Valid_R,Valid_T,Valid_B,Valid_IP,
input Last_L,Last_R,Last_T,Last_B,Last_IP,

input  Ready_L,Ready_R,Ready_T,Ready_B,Ready_IP,
output logic Ready_east,Ready_west,Ready_north,Ready_south,Ready_out_ip,

output logic Last_east,Last_west,Last_north,Last_south,Last_out_ip,
output logic Valid_east,Valid_west,Valid_north,Valid_south,Valid_out_ip,

output [`DATA_WIDTH -1:0]Data_east,Data_west,Data_north,Data_south,Data_out_ip


);
logic [4:0]four_direct;
//logic enable;
//logic en_west,en_east,en_north,en_south,en_ip;
//logic [1:0]x_north,y_north,x_south,y_south,x_east,y_east,x_west,y_west;
//logic [1:0]x_des,y_des;


logic [6:0]x_final,y_final;
logic [`DATA_WIDTH -1:0]Data_out;
logic [`DATA_WIDTH -1:0]Data_out_tmp;
logic last_out;
logic xy_enable;

// logic [`DATA_WIDTH -1:0] Data_xy_east;
// logic [`DATA_WIDTH -1:0] Data_xy_west;
// logic [`DATA_WIDTH -1:0] Data_xy_north;
// logic [`DATA_WIDTH -1:0] Data_xy_south;
// logic [`DATA_WIDTH -1:0] Data_xy_ip;


logic wren_east;
logic wren_west;
logic wren_north;
logic wren_south;
logic wren_ip;
logic xy_wren;

logic last_xy_west;
logic last_xy_east;
logic last_xy_south;
logic last_xy_north;
logic last_xy_ip;

logic last_out_tmp;

logic [`DATA_WIDTH:0] rd_data_top_east,rd_data_top_west,rd_data_top_north,rd_data_top_south,rd_data_top_ip;
logic [`DATA_WIDTH:0] rd_data_bottom_east,rd_data_bottom_west,rd_data_bottom_north,rd_data_bottom_south,rd_data_bottom_ip;
logic [`DATA_WIDTH:0] rd_data_left_east,rd_data_left_west,rd_data_left_north,rd_data_left_south,rd_data_left_ip;
logic [`DATA_WIDTH:0] rd_data_right_east,rd_data_right_west,rd_data_right_north,rd_data_right_south,rd_data_right_ip;
logic [`DATA_WIDTH:0] rd_data_ip_east,rd_data_ip_west,rd_data_ip_north,rd_data_ip_south;

// localparam  X_CURRY= X_CUR;
// localparam  Y_CURRY= Y_CUR;

router_receive #(X_CUR,Y_CUR) router_receive_top
(
.clk(clk),
.nreset(nreset),
.Data(Data_T),
.Valid(Valid_T),
.Last(Last_T),
.Ready(Ready_north),
.rd_en_east(rd_en_top_east),
.rd_en_west(rd_en_top_west),
.rd_en_north(rd_en_top_north),
.rd_en_south(rd_en_top_south),
.rd_en_ip(rd_en_top_ip),
.empty_east(empty_top_east),
.empty_west(empty_top_west),
.empty_north(empty_top_north),
.empty_south(empty_top_south),
.empty_ip(empty_top_ip),
.rd_data_east(rd_data_top_east),
.rd_data_west(rd_data_top_west),
.rd_data_north(rd_data_top_north),
.rd_data_south(rd_data_top_south),
.rd_data_ip(rd_data_top_ip)
);


router_receive #(X_CUR,Y_CUR) router_receive_bottom
(
.clk(clk),
.nreset(nreset),
.Data(Data_B),
.Valid(Valid_B),
.Last(Last_B),
.Ready(Ready_south),
.rd_en_east(rd_en_bottom_east),
.rd_en_west(rd_en_bottom_west),
.rd_en_north(rd_en_bottom_north),
.rd_en_south(rd_en_bottom_south),
.rd_en_ip(rd_en_bottom_ip),
.empty_east(empty_bottom_east),
.empty_west(empty_bottom_west),
.empty_north(empty_bottom_north),
.empty_south(empty_bottom_south),
.empty_ip(empty_bottom_ip),
.rd_data_east(rd_data_bottom_east),
.rd_data_west(rd_data_bottom_west),
.rd_data_north(rd_data_bottom_north),
.rd_data_south(rd_data_bottom_south),
.rd_data_ip(rd_data_bottom_ip)
);


router_receive #(X_CUR,Y_CUR) router_receive_left
(
.clk(clk),
.nreset(nreset),
.Data(Data_L),
.Valid(Valid_L),
.Last(Last_L),
.Ready(Ready_west),
.rd_en_east(rd_en_left_east),
.rd_en_west(rd_en_left_west),
.rd_en_north(rd_en_left_north),
.rd_en_south(rd_en_left_south),
.rd_en_ip(rd_en_left_ip),
.empty_east(empty_left_east),
.empty_west(empty_left_west),
.empty_north(empty_left_north),
.empty_south(empty_left_south),
.empty_ip(empty_left_ip),
.rd_data_east(rd_data_left_east),
.rd_data_west(rd_data_left_west),
.rd_data_north(rd_data_left_north),
.rd_data_south(rd_data_left_south),
.rd_data_ip(rd_data_left_ip)
);

router_receive #(X_CUR,Y_CUR) router_receive_right
(
.clk(clk),
.nreset(nreset),
.Data(Data_R),
.Valid(Valid_R),
.Last(Last_R),
.Ready(Ready_east),
.rd_en_east(rd_en_right_east),
.rd_en_west(rd_en_right_west),
.rd_en_north(rd_en_right_north),
.rd_en_south(rd_en_right_south),
.rd_en_ip(rd_en_right_ip),
.empty_east(empty_right_east),
.empty_west(empty_right_west),
.empty_north(empty_right_north),
.empty_south(empty_right_south),
.empty_ip(empty_right_ip),
.rd_data_east(rd_data_right_east),
.rd_data_west(rd_data_right_west),
.rd_data_north(rd_data_right_north),
.rd_data_south(rd_data_right_south),
.rd_data_ip(rd_data_right_ip)
);

router_receive #(X_CUR,Y_CUR) router_receive_ip
(
.clk(clk),
.nreset(nreset),
.Data(Data_IP),
.Valid(Valid_IP),
.Last(Last_IP),
.Ready(Ready_out_ip),
.rd_en_east(rd_en_ip_east),
.rd_en_west(rd_en_ip_west),
.rd_en_north(rd_en_ip_north),
.rd_en_south(rd_en_ip_south),
.rd_en_ip(),
.empty_east(empty_ip_east),
.empty_west(empty_ip_west),
.empty_north(empty_ip_north),
.empty_south(empty_ip_south),
.empty_ip(),
.rd_data_east(rd_data_ip_east),
.rd_data_west(rd_data_ip_west),
.rd_data_north(rd_data_ip_north),
.rd_data_south(rd_data_ip_south),
.rd_data_ip()
);


router_send  router_send_east
(
.clk(clk),
.nreset(nreset),

.Data_last_top(rd_data_top_east),
.Data_last_bottom(rd_data_bottom_east),
.Data_last_left(rd_data_left_east),
.Data_last_right(rd_data_right_east),
.Data_last_ip(rd_data_ip_east),
.Ready(Ready_R),


.empty_top(empty_top_east),
.empty_bottom(empty_bottom_east),
.empty_left(empty_left_east),
.empty_right(empty_right_east),
.empty_ip(empty_ip_east),

.rd_en_top(rd_en_top_east),
.rd_en_bottom(rd_en_bottom_east),
.rd_en_left(rd_en_left_east),
.rd_en_right(rd_en_right_east),
.rd_en_ip(rd_en_ip_east),

.Last_out(Last_east),
.Valid(Valid_east),
.Data_out(Data_east)
);


router_send  router_send_west
(
.clk(clk),
.nreset(nreset),

.Data_last_top(rd_data_top_west),
.Data_last_bottom(rd_data_bottom_west),
.Data_last_left(rd_data_left_west),
.Data_last_right(rd_data_right_west),
.Data_last_ip(rd_data_ip_west),
.Ready(Ready_L),


.empty_top(empty_top_west),
.empty_bottom(empty_bottom_west),
.empty_left(empty_left_west),
.empty_right(empty_right_west),
.empty_ip(empty_ip_west),

.rd_en_top(rd_en_top_west),
.rd_en_bottom(rd_en_bottom_west),
.rd_en_left(rd_en_left_west),
.rd_en_right(rd_en_right_west),
.rd_en_ip(rd_en_ip_west),

.Last_out(Last_west),
.Valid(Valid_west),
.Data_out(Data_west)
);


router_send  router_send_north
(
.clk(clk),
.nreset(nreset),

.Data_last_top(rd_data_top_north),
.Data_last_bottom(rd_data_bottom_north),
.Data_last_left(rd_data_left_north),
.Data_last_right(rd_data_right_north),
.Data_last_ip(rd_data_ip_north),
.Ready(Ready_T),


.empty_top(empty_top_north),
.empty_bottom(empty_bottom_north),
.empty_left(empty_left_north),
.empty_right(empty_right_north),
.empty_ip(empty_ip_north),

.rd_en_top(rd_en_top_north),
.rd_en_bottom(rd_en_bottom_north),
.rd_en_left(rd_en_left_north),
.rd_en_right(rd_en_right_north),
.rd_en_ip(rd_en_ip_north),

.Last_out(Last_north),
.Valid(Valid_north),
.Data_out(Data_north)
);

router_send  router_send_south
(
.clk(clk),
.nreset(nreset),

.Data_last_top(rd_data_top_south),
.Data_last_bottom(rd_data_bottom_south),
.Data_last_left(rd_data_left_south),
.Data_last_right(rd_data_right_south),
.Data_last_ip(rd_data_ip_south),
.Ready(Ready_B),


.empty_top(empty_top_south),
.empty_bottom(empty_bottom_south),
.empty_left(empty_left_south),
.empty_right(empty_right_south),
.empty_ip(empty_ip_south),

.rd_en_top(rd_en_top_south),
.rd_en_bottom(rd_en_bottom_south),
.rd_en_left(rd_en_left_south),
.rd_en_right(rd_en_right_south),
.rd_en_ip(rd_en_ip_south),

.Last_out(Last_south),
.Valid(Valid_south),
.Data_out(Data_south)
);


router_send  router_send_ip
(
.clk(clk),
.nreset(nreset),

.Data_last_top(rd_data_top_ip),
.Data_last_bottom(rd_data_bottom_ip),
.Data_last_left(rd_data_left_ip),
.Data_last_right(rd_data_right_ip),
.Data_last_ip(33'b0),
.Ready(Ready_IP),


.empty_top(empty_top_ip),
.empty_bottom(empty_bottom_ip),
.empty_left(empty_left_ip),
.empty_right(empty_right_ip),
.empty_ip(1'b1),

.rd_en_top(rd_en_top_ip),
.rd_en_bottom(rd_en_bottom_ip),
.rd_en_left(rd_en_left_ip),
.rd_en_right(rd_en_right_ip),
.rd_en_ip(),

.Last_out(Last_out_ip),
.Valid(Valid_out_ip),
.Data_out(Data_out_ip)
);



		
endmodule 