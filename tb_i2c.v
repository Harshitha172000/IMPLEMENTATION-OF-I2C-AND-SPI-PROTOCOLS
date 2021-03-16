`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.12.2020 18:08:55
// Design Name: 
// Module Name: i2c_tb
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
/////////////////////////////////////////////////////////////////////////////////

module tb_i2c;

	// Inputs
	reg clk;
	reg reset;
	reg [6:0] addr;
	reg [7:0] in_data;
	reg enable;
	reg rw;
	
	// Outputs
	wire [7:0] out_data;
	wire ready;
	
	// Bidirs
	wire sda;
	wire scl;
	

	// Instantiate the Unit Under Test (UUT)
	master_i2c m ( clk,
	reset,
	addr,
	in_data,
	enable,
	rw,
    out_data,
    ready,
	sda,
	scl);
		
	i2c_slave slave (
    .sda(sda), 
    .scl(scl)
    );
	
	initial begin
		clk = 0;
		forever begin
			clk = #2 ~clk;
		end		
	end

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		reset = 0;		
		addr = 7'b0101010;
		
		in_data = 8'b10101010;
		
		rw = 0;	
		enable = 1;
		#20;
		enable = 0;
				
		#400
		reset =0;
		addr = 7'b0101010;
		
		in_data = 8'b10101010;
		rw=1;
		enable =1;
		#10;
		enable=0;
		#100
		$finish;
		
	end      
endmodule

