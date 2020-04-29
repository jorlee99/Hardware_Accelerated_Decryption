`default_nettype none
module rc4_task2a(clk,s_counter,s_data_in,s_mem_data,write_enable_s_mem,d_counter,d_data,d_mem_out,write_enable_d_mem,e_counter,e_mem_data,
i_counter_task2a,start_secret, secret_key_data,secret_key_done,secret_key,
fail_led, success_led,key0,key1,key2,key3,
state);
//basic
input clk;

input key0,key1,key2,key3; //test cases

output reg [8:0] state;

//
//
//task1 IO
//
//
//

//outputs
output reg [7:0] s_counter;
output reg [7:0] s_data_in;
output reg write_enable_s_mem;

//inputs
input reg [7:0] s_mem_data;

//wires
reg [7:0] i_counter_task1 = 8'b0;

//
//
//task 2a IO
//
//
//

//outputs
output reg [7:0] i_counter_task2a;
output reg start_secret;
assign start_secret = state[0]; //flag to computer secret key data

//inputs
input reg [7:0] secret_key_data;
input reg secret_key_done;

//wires
reg [7:0] j_counter_task2a;
reg [7:0] s_mem_i, s_mem_j; //input store

//
//
// task 2b IO
//
//
//

//inputs
input reg [7:0] e_mem_data;
input reg [7:0] d_mem_out;

//outputs
output reg [7:0] d_counter;
output reg [7:0] d_data;
output reg write_enable_d_mem; 
output reg [7:0] e_counter;


//wires
reg [7:0]s_mem_i_2b, s_mem_j_2b, s_mem_f;
reg [7:0] k_counter, f_counter;
reg [7:0] i_counter_task2b;
reg [7:0] j_counter_task2b;

//
//
// task3 IO
//
//
//

//inputs

//outputs
output reg [23:0] secret_key;
output reg success_led; // led flags
output reg fail_led;

//wires

//task1 states
parameter task1 = 9'b00000000;
parameter get_i_counter = 9'b00000001;

//task2a states
parameter get_i_wait = 9'b00000010_0;
parameter get_i_data= 9'b00000011_0;
parameter get_secret_key= 9'b00000100_1;
parameter store_secret_key= 9'b00000101_0;
parameter get_j_value = 9'b00000110_0;
parameter get_j_counter = 9'b00000111_0;
parameter get_j_wait = 9'b00001000_0;
parameter get_j_data = 9'b00001001_0;
parameter i_swap_out = 9'b00001010_0;
parameter swap_values= 9'b00001011_0;
parameter j_swap_out = 9'b00001100_0;
parameter end_task2a= 9'b00001101_0;

//task2b states
parameter i_increment= 9'b00001110_0;
parameter get_i_counter_2b = 9'b00001111_0;
parameter get_i_wait_2b = 9'b00010000_0;
parameter get_i_data_2b = 9'b00010001_0;
parameter j_increment = 9'b00010010_0;
parameter get_j_counter_2b = 9'b00010011_0;
parameter get_j_wait_2b = 9'b00010100_0;
parameter get_j_data_2b = 9'b00010101_0;
parameter j_swap_out_2b = 9'b00010110_0;
parameter swap_values_2b = 9'b00010111_0;
parameter i_swap_out_2b = 9'b00011000_0;
parameter get_f_count_value = 9'b00011001_0;
parameter get_f_counter = 9'b00011010_0;
parameter wait_f_data = 9'b00011011_0;
parameter get_f_data = 9'b00011100_0;
parameter get_encrypt_data = 9'b00011101_0;
parameter decrypt_counter = 9'b00011110_0;
parameter decrypt_wait = 9'b00011111_0;
parameter get_decrypt_data = 9'b00100000_0;
parameter end_task2b = 9'b00100001_0;
parameter end_all = 9'b00100010_0;

//task3 states
parameter decrypt_check = 9'b00100011_0;
parameter failed = 9'b00100100_0;
parameter success_check = 9'b00100101_0;
parameter end_all_failed = 9'b00100110_0;
parameter end_all_success = 9'b00100111_0;
parameter reset = 9'b00101000_0;

//MY CODE//

	always_ff @(posedge clk) begin
		case(state) 
		
			reset:begin //reset all variables
				i_counter_task1 <= 1'b0;
				i_counter_task2a <= 1'b0;
				j_counter_task2a <= 1'b0;
				i_counter_task2b <= 1'b0;
				j_counter_task2b <= 1'b0;
				f_counter <= 1'b0;
				k_counter <= 1'b0;
				state <= task1;
			end
			
			task1: begin
				write_enable_s_mem <= 1'b1;
															//store values
					s_counter <= i_counter_task1;
					s_data_in <= i_counter_task1;
					
				if (i_counter_task1 == 8'd255) begin //check if done 256 times if so go to 2a
				state <= get_i_counter;
				end
				else begin
					i_counter_task1 <= i_counter_task1 + 1'b1; //increment
					state <= task1;
				end
			end
			
			//task 2a
			
			get_i_counter: begin
					s_counter <= i_counter_task2a; //set address
					write_enable_s_mem <= 1'b0;
					state <= get_i_wait;
			end
			
			get_i_wait: begin
				write_enable_s_mem <= 1'b0; 
				state <= get_i_data;
			end
			
			get_i_data: begin
				write_enable_s_mem <= 1'b0;
				s_mem_i<= s_mem_data; //store data
				state <= get_secret_key;
			end	

		get_secret_key:begin // call secret key fsm
				 write_enable_s_mem <=1'b0;
				if(secret_key_done) 
				state<=store_secret_key;
				else
				state<=get_secret_key;
			end
		
		store_secret_key: //wait state to store secret_key
			begin
				write_enable_s_mem <=1'b0;
				state <= get_j_value;
			end

			get_j_value: begin //compute j
				write_enable_s_mem <= 1'b0;
				j_counter_task2a<= (j_counter_task2a+ s_mem_data + secret_key_data);  	
				state <= get_j_counter;
			end
				
			get_j_counter: begin 
				write_enable_s_mem <= 1'b0;
				s_counter <= j_counter_task2a; //set address
				state <= get_j_wait;
			end
			
			get_j_wait: begin
				write_enable_s_mem <= 1'b0;
				state <= get_j_data;
			end
			
			get_j_data: begin
				s_mem_j <= s_mem_data; //store data
				write_enable_s_mem <= 1'b0;
				state <= i_swap_out;
			end
			
			i_swap_out: begin
				write_enable_s_mem <= 1'b1;
				s_data_in <= s_mem_i; //put i into j 
				state <= swap_values;
			end
			
			swap_values: begin
				write_enable_s_mem <= 1'b0;
				s_counter <= i_counter_task2a; //change address
				state <= j_swap_out;
			end
			
			j_swap_out: begin
				write_enable_s_mem <= 1'b1;
				s_data_in <= s_mem_j; //put j into i
				state <= end_task2a;
			end
				
			end_task2a: begin
				write_enable_s_mem <= 1'b0;
				if (i_counter_task2a< 8'd255) begin //check if at 256
					i_counter_task2a<= i_counter_task2a+ 1'b1;//increment
					state <= get_i_counter;
				end
				else begin
					state <= i_increment;//go to task 2b
				end
			end
//task2b
			i_increment: begin
				i_counter_task2b<= i_counter_task2b+ 1'b1;//increment 
				state <= get_i_counter_2b;
			end

			get_i_counter_2b: begin
				write_enable_s_mem <= 1'b0;
				s_counter <= i_counter_task2b;//set address to i
				state <= get_i_wait_2b;
			end
			
			get_i_wait_2b: begin
				write_enable_s_mem <= 1'b0;
				state <= get_i_data_2b;
			end
			
			get_i_data_2b: begin
				write_enable_s_mem <= 1'b0;
				s_mem_i_2b <= s_mem_data; //store data
				state <= j_increment;
			end	
			
			j_increment: begin
				write_enable_s_mem <= 1'b0;
				j_counter_task2b<= j_counter_task2b+ s_mem_i_2b; // get j count
				state <= get_j_counter_2b;
			end
			
			get_j_counter_2b: begin
				write_enable_s_mem <= 1'b0;
				s_counter <= j_counter_task2b; //change address
				state <= get_j_wait_2b;
			end
			
			get_j_wait_2b: begin
				write_enable_s_mem <= 1'b0;
				state <= get_j_data_2b;
			end
			
			get_j_data_2b: begin
				write_enable_s_mem <= 1'b0;
				s_mem_j_2b <= s_mem_data;    //store data
				state <= j_swap_out_2b;
			end
			
			j_swap_out_2b: begin
				write_enable_s_mem <= 1'b1;
				s_data_in <= s_mem_i_2b; //put i into j
				state <= swap_values_2b;
			end
			
			swap_values_2b: begin
				write_enable_s_mem <= 1'b0;
				s_counter <= i_counter_task2b; //swap to address i
				state <= i_swap_out_2b;
			end
			
			i_swap_out_2b: begin
				write_enable_s_mem <= 1'b1;
				s_data_in <= s_mem_j_2b; //put i into j
				state <= get_f_count_value;
			end
				
			get_f_count_value: begin
				write_enable_s_mem <= 1'b0;
				f_counter <= s_mem_i_2b + s_mem_j_2b; //get f_address
				state <= get_f_counter;
			end
			
			get_f_counter: begin 
				write_enable_s_mem <= 1'b0;
				s_counter <= f_counter; //store f_address
				state <= wait_f_data;
			end
			
			wait_f_data: begin
				write_enable_s_mem <= 1'b0;
				state <= get_f_data;
			end
			
			get_f_data: begin
				write_enable_s_mem <= 1'b0; 
				s_mem_f <= s_mem_data; //store f_data
				write_enable_d_mem <= 1'b0;
				state <= get_encrypt_data;
			end	
			
			get_encrypt_data:
				begin
				e_counter <= k_counter; //put k into e address
				state <= decrypt_counter;
				end
			
			decrypt_counter:
			begin
				d_counter <= k_counter; //put k into d address
				state <= decrypt_wait;
			end
			
			decrypt_wait: begin
				state <= get_decrypt_data;
			end
			
			get_decrypt_data: begin
				write_enable_d_mem <= 1'b1;
				d_data <= (s_mem_f^e_mem_data); //compute d data
				state <= decrypt_check;
			end
			
//task3 			

		decrypt_check:
		begin
			if ((d_data == 8'd32) || ((d_data <= 8'd122) && (d_data >= 8'd97)))//compare d_data to characters
				begin
					if (k_counter < 31) begin
						k_counter <= k_counter + 1'b1;
						state <= i_increment;
					end
					else
						state <= end_all_success;
				end
				
			else if (secret_key < 24'h3FFFFF) begin//check secret key
				secret_key <= secret_key + 1'b1;
				state <= reset;
				end
			else
				state <= end_all_failed;
		end
		
		end_all_success://success loop
			begin
				success_led <= 1'b1;
				fail_led <= 1'b0;
				state <= end_all_success;
			end
			
		end_all_failed://fail loop
			begin
				success_led <= 1'b0;
				fail_led <= 1'b1;
				state <= end_all_failed;
			end
			
		default: state <= reset;
	endcase
	
end

endmodule
