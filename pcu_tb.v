
module pcu_tb ();
  
  parameter SPI_MODE = 3; // CPOL = 0, CPHA = 1
  parameter SPI_CLK_DELAY = 20;  // 2.5 MHz
  parameter MAIN_CLK_DELAY = 2;  // 25 MHz

  wire w_CPOL; // clock polarity
  wire w_CPHA; // clock phase

  assign w_CPOL = (SPI_MODE == 2) | (SPI_MODE == 3);
  assign w_CPHA = (SPI_MODE == 1) | (SPI_MODE == 3);

  reg r_Rst_L     = 1'b0;

 // reg [7:0] dataPayload[0:255]; 
  //reg [7:0] dataLength;
  
  // CPOL=0, clock idles 0.  CPOL=1, clock idles 1
//  logic r_SPI_Clk   = w_CPOL ? 1'b1 : 1'b0;
  wire w_SPI_Clk;
  //reg r_SPI_En    = 1'b0;
  reg r_Clk       = 1'b0;
  //wire w_SPI_CS_n;
  wire w_SPI_MOSI;
  wire w_SPI_MISO;

  // Master Specific
  reg [7:0] r_Master_TX_Byte ;
  reg r_Master_TX_DV = 1'b0;
  reg r_Master_CS_n = 1'b1;
  wire w_Master_TX_Ready;
  wire r_Master_RX_DV;
  wire [7:0] r_Master_RX_Byte;

  // Slave Specific
  wire       w_Slave_RX_DV; reg r_Slave_TX_DV;
  wire [7:0] w_Slave_RX_Byte; reg [7:0] r_Slave_TX_Byte;
  
  wire i2c_sda, i2c_scl;
  reg reset_i2c=1;
  reg enable=0; 
  // Clock Generators:
  always #(MAIN_CLK_DELAY) r_Clk = ~r_Clk;

  // Instantiate UUT
  pcu #(.SPI_MODE(SPI_MODE)) SPI_Slave_UUT
  (
   // Control/Data Signals,
   .i_Rst_L(r_Rst_L),      // FPGA Reset
   .i_Clk(r_Clk),          // FPGA Clock
   .o_RX_DV(w_Slave_RX_DV),      // Data Valid pulse (1 clock cycle)
   .o_RX_Byte(w_Slave_RX_Byte),  // Byte received on MOSI
   .i_TX_DV(r_Slave_TX_DV),      // Data Valid pulse
   .i_TX_Byte(r_Slave_TX_Byte),  // Byte to serialize to MISO (set up for loopback)

   // SPI Interface
   .i_SPI_Clk(w_SPI_Clk),
   .o_SPI_MISO(w_SPI_MISO),
   .i_SPI_MOSI(w_SPI_MOSI),
   .i_SPI_CS_n(r_Master_CS_n),
   
   .ready(ready),
   .enable(enable),
   .reset_i2c(reset_i2c),
   .i2c_sda(i2c_sda),
   .i2c_scl(i2c_scl)
   );

  // Instantiate Master to drive Slave
  SPI_M
  #(.SPI_MODE(SPI_MODE),
    .CLKS_PER_HALF_BIT(2),
    .NUM_SLAVES(1)) SPI_Master_UUT
  (
   // Control/Data Signals,
   .i_Rst_L(r_Rst_L),     // FPGA Reset
   .i_Clk(r_Clk),         // FPGA Clock
   
   // TX (MOSI) Signals
   .i_TX_Byte(r_Master_TX_Byte),     // Byte to transmit on MOSI
   .i_TX_DV(r_Master_TX_DV),         // Data Valid Pulse with i_TX_Byte
   .o_TX_Ready(w_Master_TX_Ready),   // Transmit Ready for Byte
   
   // RX (MISO) Signals
   .o_RX_DV(r_Master_RX_DV),       // Data Valid pulse (1 clock cycle)
   .o_RX_Byte(r_Master_RX_Byte),   // Byte received on MISO

   // SPI Interface
   .o_SPI_Clk(w_SPI_Clk),
   .i_SPI_MISO(w_SPI_MISO),
   .o_SPI_MOSI(w_SPI_MOSI)
   );


  // Sends a single byte from master to slave.  Will drive CS on its own.
  task SendSingleByte(input [7:0] data);begin
    @(posedge r_Clk);
    
    r_Master_TX_Byte <= data;
    r_Master_TX_DV   <= 1'b1;
    r_Master_CS_n    <= 1'b0;
    @(posedge r_Clk);
    r_Master_TX_DV <= 1'b0;
    @(posedge w_Master_TX_Ready);
    r_Master_CS_n    <= 1'b1;  
      
    end
  endtask // SendSingleByte



    
  initial
    begin
      repeat(10) @(posedge r_Clk);
      r_Rst_L  = 1'b0;
      r_Master_CS_n    <= 1'b1; 
      repeat(10) @(posedge r_Clk);
      r_Rst_L          = 1'b1;
      r_Master_CS_n    <= 1'b0; 
      r_Slave_TX_Byte <= 8'h5A;
      r_Slave_TX_DV   <= 1'b1;
     // reset_i2c=1'b1;
      repeat(100) @(posedge r_Clk);
      reset_i2c=1'b0;
      enable=1;
      repeat(10) @(posedge r_Clk);
      enable=0;
      r_Master_CS_n<=1'b1;
      r_Slave_TX_DV   <= 1'b0;
      SendSingleByte(8'hb1);
      repeat(10) @(posedge r_Clk);
      enable=1;
      
      repeat(5)@(posedge r_Clk);
      r_Rst_L          = 1'b1;
      r_Master_CS_n    <= 1'b0; 
      r_Slave_TX_Byte <= 8'h2A;
      r_Slave_TX_DV   <= 1'b1;
      repeat(10) @(posedge r_Clk);
      r_Slave_TX_DV   <= 1'b0;
      r_Master_CS_n<=1'b1;
      SendSingleByte(8'ha1);
     
      repeat(100) @(posedge r_Clk);
     
     
      $finish();      
    end // initial begin

endmodule // SPI_Slave
