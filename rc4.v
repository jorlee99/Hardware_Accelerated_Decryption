`default_nettype none
module rc4(CLOCK_50,
LEDR,
KEY,
SW,
HEX0,
HEX1,
HEX2,
HEX3,
HEX4,
HEX5
);
//basic inputs
input CLOCK_50;
input [3:0] KEY;
input [9:0] SW;

wire CLK_50M;
assign CLK_50M = CLOCK_50;

//de1 outputs
output [9:0] LEDR;
output [6:0] HEX0;
output [6:0] HEX1;
output [6:0] HEX2;
output [6:0] HEX3;
output [6:0] HEX4;
output [6:0] HEX5;

//inputs
wire reset;

s_memory s_mem(.address(mem_addr), .data(mem_data), .clock(CLOCK_50), .wren(mem_enable), .q(mem_out));
wire [7:0] mem_out;

e_memory e_mem(.clock(CLOCK_50),.address(e_addr),.q(enc_out));
wire [7:0] enc_out;

d_memory d_mem(.address(d_addr), .data(d_data), .clock(CLOCK_50), .wren(write_enable_d), .q(dec_out));
wire [7:0] dec_out;

rc4_task2a (.clk(CLK_50M),.s_counter(mem_addr),.s_data_in(mem_data),.s_mem_data(mem_out),.write_enable_s_mem(mem_enable),.d_counter(d_addr),
.d_data(d_data),.d_mem_out(dec_out),.write_enable_d_mem(write_enable_d),.e_counter(e_addr),.e_mem_data(enc_out),

.start_secret(start_secret_key), .secret_key_data(secret_key_value),
.secret_key_done(secret_key_done), .i_counter_task2a(i_counter_task2a),

.secret_key(secret_key_input),.fail_led(LEDR[0]),.success_led(LEDR[9]),

.key0(KEY[0]),.key1(KEY[1]),.key2(KEY[2]),.key3(KEY[3])
);

wire start_secret_key;
wire task2a_finish;
wire [7:0] mem_addr;
wire [7:0] mem_data;
wire mem_enable;
wire [7:0] i_counter_task2a;

//2b stuff
wire [7:0] d_addr;
wire [7:0] e_addr;
wire [7:0] d_data;
wire write_enable_d;

//task 3 state
wire [23:0] secret_key_input;

secretkey key_fsm (.clk(CLK_50M), .start(start_secret_key), .i_counter(i_counter_task2a), .finish(secret_key_done), 
.secret_key_value(secret_key_value), .secret_key_input(secret_key_input),
.hex0(hex0),.hex1(hex1),.hex2(hex2),.hex3(hex3),.hex4(hex4),.hex5(hex5));

wire [3:0] hex0,hex1,hex2,hex3,hex4,hex5;
wire secret_key_done;
wire [7:0] secret_key_value;

SevenSegmentDisplayDecoder disp0 (.nIn(hex0),.ssOut(display0));
SevenSegmentDisplayDecoder disp1 (.nIn(hex1),.ssOut(display1));
SevenSegmentDisplayDecoder disp2 (.nIn(hex2),.ssOut(display2));
SevenSegmentDisplayDecoder disp3 (.nIn(hex3),.ssOut(display3));
SevenSegmentDisplayDecoder disp4 (.nIn(hex4),.ssOut(display4));
SevenSegmentDisplayDecoder disp5 (.nIn(hex5),.ssOut(display5));

wire [6:0] display0,display1,display2,display3,display4,display5;

assign HEX0 = display0;
assign HEX1 = display1;
assign HEX2 = display2;
assign HEX3 = display3;
assign HEX4 = display4;
assign HEX5 = display5;


endmodule
