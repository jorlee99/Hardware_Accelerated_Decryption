module secretkey (clk,start,finish,i_counter,secret_key_value,secret_key_input,hex0,hex1,hex2,hex3,hex4,hex5,state);

input clk;
input reg start;
input [7:0] i_counter;
input [23:0] secret_key_input;

reg [1:0] keylength = 2'd3;

output finish;
output reg [7:0] secret_key_value;

output reg [3:0] hex0,hex1,hex2,hex3,hex4,hex5;

reg [1:0] secret_key_mod;

output reg [3:0] state;

parameter idle = 4'b0000;
parameter key_mod = 4'b0001;
parameter key_mod_check = 4'b0010;
parameter finish_state = 4'b0011;
parameter hex_display = 4'b0100;
parameter wait_display = 4'b0101;

always @(posedge clk)
begin

	case(state)
	
	idle: begin
	finish <=1'b0;
	if (start)
		state <= key_mod;
	else
		state<= idle;
	end
	
	key_mod:begin
		secret_key_mod <= (i_counter % keylength);
		state <= key_mod_check;
	end
	
	key_mod_check:
	begin
		if (secret_key_mod == 0)
			secret_key_value <= secret_key_input[23:16] ;
		else if (secret_key_mod == 1)
			secret_key_value <= secret_key_input[15:8];
		else if (secret_key_mod == 2)
			secret_key_value <= secret_key_input[7:0];
	state <= hex_display;
	end
	
	hex_display:
		begin
			hex0 <= secret_key_input[3:0];
			hex1 <= secret_key_input[7:4];
			hex2 <= secret_key_input[11:8];
			hex3 <= secret_key_input[15:12];
			hex4 <= secret_key_input[19:16];
			hex5 <= secret_key_input[23:20];
			
			state <= wait_display;
		end
	
	wait_display:
		begin
			state <= finish_state;
		end
	
	finish_state:begin
	state <= idle;
	finish <= 1'b1;
	end
	
	default: state<= idle;
	endcase
	
end

endmodule
