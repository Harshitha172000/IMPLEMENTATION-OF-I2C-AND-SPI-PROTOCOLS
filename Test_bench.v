
module Test_bench ();
  
  parameter SPI_MODE = 3; 
  parameter SPI_CLK_DELAY = 20;  // 2.5 MHz
  parameter MAIN_CLK_DELAY = 2;  // 25 MHz

  wire w_CPOL; // clock polarity
  wire w_CPHA; // clock phase

  assign w_CPOL = (SPI_MODE == 2) | (SPI_MODE == 3);
  assign w_CPHA = (SPI_MODE == 1) | (SPI_MODE == 3);

  reg r_Rst_L     = 1'b0;

  wire w_SPI_Clk;

  reg r_Clk       = 1'b0;

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

  // Clock Generators:
  always #(MAIN_CLK_DELAY) r_Clk = ~r_Clk;

  // Instantiate UUT
  SPI_SLAVE #(.SPI_MODE(SPI_MODE)) SPI_Slave_UUT
  (
 
   .i_Rst_L(r_Rst_L),      
   .i_Clk(r_Clk),          
   .o_RX_DV(w_Slave_RX_DV),      
   .o_RX_Byte(w_Slave_RX_Byte),  
   .i_TX_DV(r_Slave_TX_DV),      
   .i_TX_Byte(r_Slave_TX_Byte),  

   // SPI Interface
   .i_SPI_Clk(w_SPI_Clk),
   .o_SPI_MISO(w_SPI_MISO),
   .i_SPI_MOSI(w_SPI_MOSI),
   .i_SPI_CS_n(r_Master_CS_n)
   );

  
  SPI_M
  #(.SPI_MODE(SPI_MODE),
    .CLKS_PER_HALF_BIT(2),
    .NUM_SLAVES(1)) SPI_Master_UUT
  (
   
   .i_Rst_L(r_Rst_L),    
   .i_Clk(r_Clk),         
   

   .i_TX_Byte(r_Master_TX_Byte),     
   .i_TX_DV(r_Master_TX_DV),         
   .o_TX_Ready(w_Master_TX_Ready),   
   
   
   .o_RX_DV(r_Master_RX_DV),       
   .o_RX_Byte(r_Master_RX_Byte),   

   
   .o_SPI_Clk(w_SPI_Clk),
   .i_SPI_MISO(w_SPI_MISO),
   .o_SPI_MOSI(w_SPI_MOSI)
   );


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
  endtask 



    
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
      repeat(10) @(posedge r_Clk);
      r_Master_CS_n<=1'b1;
      r_Slave_TX_DV   <= 1'b0;
      SendSingleByte(8'hC1);
      repeat(100) @(posedge r_Clk);
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
    end 

endmodule 
