
module pcu #(parameter SPI_MODE = 3)
  (
   // Control/Data Signals,
   input            i_Rst_L,    // FPGA Reset
   input            i_Clk,      // FPGA Clock
   output wire       o_RX_DV,    // Data Valid pulse (1 clock cycle)
   output wire [7:0] o_RX_Byte,  // Byte received on MOSI
   input            i_TX_DV,    // Data Valid pulse to register i_TX_Byte
   input  [7:0]     i_TX_Byte,  // Byte to serialize to MISO.

   // SPI Interface
   input      i_SPI_Clk,
   output     o_SPI_MISO,
   input      i_SPI_MOSI,
   input      i_SPI_CS_n,
   
   // 
   //output reg [7:0] data_out,
   output wire ready,
   input enable,
   input reset_i2c,
   inout i2c_sda,
   inout i2c_scl
   );
   
   wire [7:0] data_out;
   wire [6:0] addr; assign addr=7'b0101010; wire rw=0;


  
 //assign ready=(r2==1)?1'b1:1'b0; 
 //assign ready = (enable==1)?1'b1:1'b0;
   
  SPI_SLAVE #( SPI_MODE )
  s(
   // Control/Data Signals,
   i_Rst_L,    // FPGA Reset
    i_Clk,      // FPGA Clock
   o_RX_DV,    // Data Valid pulse (1 clock cycle)
    o_RX_Byte,  // Byte received on MOSI
    i_TX_DV,    // Data Valid pulse to register i_TX_Byte
  i_TX_Byte,  // Byte to serialize to MISO.

   // SPI Interface
   i_SPI_Clk,
  o_SPI_MISO,
     i_SPI_MOSI,
    i_SPI_CS_n
   );
 

   
   master_i2c m(clk,
	reset_i2c,
	addr,
	o_TX_Byte,
	enable,
	 rw,
    data_out,
	 ready,
    i2c_sda,
	 i2c_scl
 );
   endmodule
   