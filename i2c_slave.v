`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.12.2020 18:37:09
// Design Name: 
// Module Name: i2c_slave
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module i2c_slave( inout sda, inout scl );

localparam address = 7'b0101010;

localparam read_addr = 0;
localparam ack_tx = 1;
localparam read_data = 2;
localparam write_data = 3;
localparam ack_tx2 = 4;

reg [7:0] addr;
reg [7:0] counter;
reg [7:0] state = 0;
reg [7:0] data_in = 0;
reg [7:0] data_out = 8'b11001100;
reg sda_out = 0;
reg sda_in = 0;
reg start = 0;
reg write_enable = 0;

assign sda = (write_enable == 1) ? sda_out : 'bz;
	
	always @(negedge sda) begin
		if ((start == 0) && (scl == 1)) begin
			start <= 1;	
			counter <= 7;
		end
	end
	
	always @(posedge sda) begin
		if ((start == 1) && (scl == 1)) begin
			state <= read_addr;
			start <= 0;
			write_enable <= 0;
		end
	end
	
	always @(posedge scl) begin
		if (start == 1) begin
			case(state)
				read_addr: begin
					addr[counter] <= sda;
					if(counter == 0) state <= ack_tx;
					else counter <= counter - 1;					
				end
				
				ack_tx: begin
					if(addr[7:1] == address) begin
						counter <= 7;
						if(addr[0] == 0) begin 
							state <= read_data;
						end
						else state <= write_data;
					end
				end
				
				read_data: begin
					data_in[counter] <= sda;
					if(counter == 0) begin
						state <= ack_tx2;
					end else counter <= counter - 1;
				end
				
				ack_tx2: begin
					state <= read_addr;					
				end
				
				write_data: begin
					if(counter == 0) state <= read_addr;
					else counter <= counter - 1;		
				end
				
			endcase
		end
	end
	
	always @(negedge scl) begin
		case(state)
			
			read_addr: begin
				write_enable <= 0;			
			end
			
			ack_tx: begin
				sda_out <= 0;
				write_enable <= 1;	
			end
			
			read_data: begin
				write_enable <= 0;
			end
			
			write_data: begin
				sda_out <= data_out[counter];
				write_enable <= 1;
			end
			
			ack_tx2: begin
				sda_out <= 0;
				write_enable <= 1;
			end
		endcase
	end
endmodule
