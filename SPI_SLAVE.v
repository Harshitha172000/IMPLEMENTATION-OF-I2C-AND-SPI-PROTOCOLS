`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Module Name: SPI_SLAVE

// 
//////////////////////////////////////////////////////////////////////////////////



module SPI_SLAVE
  #(parameter SPI_MODE = 0)
  (

   input            i_Rst_L,    
   input            i_Clk,      
   output reg       o_RX_DV, 
   output reg [7:0] o_RX_Byte,  
   input            i_TX_DV,
   input  [7:0]     i_TX_Byte,  

  
   input      i_SPI_Clk,
   output     o_SPI_MISO,
   input      i_SPI_MOSI,
   input      i_SPI_CS_n
   );


  
  wire w_CPOL;     
  wire w_CPHA;  
  wire w_SPI_Clk;  
  wire w_SPI_MISO_Mux;
  
  reg [2:0] r_RX_Bit_Count;
  reg [2:0] r_TX_Bit_Count;
  reg [7:0] r_Temp_RX_Byte;
  reg [7:0] r_RX_Byte;
  reg r_RX_Done, r2_RX_Done, r3_RX_Done, r4_RX_Done;
  reg [7:0] r_TX_Byte;
  reg r_SPI_MISO_Bit, r_Preload_MISO;

  assign w_CPOL  = (SPI_MODE == 2) | (SPI_MODE == 3);

  
  assign w_CPHA  = (SPI_MODE == 1) | (SPI_MODE == 3);

  assign w_SPI_Clk = w_CPHA ? ~i_SPI_Clk : i_SPI_Clk;




  always @(posedge w_SPI_Clk or posedge i_SPI_CS_n)
  begin
    if (i_SPI_CS_n)
    begin
      r_RX_Bit_Count <= 0;
      r_RX_Done      <= 1'b0;
    end
   
    else
    
    begin
      r_RX_Bit_Count <= r_RX_Bit_Count + 1;

      // Receive in LSB, shift up to MSB
      r_Temp_RX_Byte <= {r_Temp_RX_Byte[6:0], i_SPI_MOSI};
    
      if (r_RX_Bit_Count == 3'b111)
      begin
        r_RX_Done <= 1'b1;
        r_RX_Byte <= {r_Temp_RX_Byte[6:0], i_SPI_MOSI};
      end
      else if (r_RX_Bit_Count == 3'b010)
      begin
        r_RX_Done <= 1'b0;        
      end

    end 
  end 



  always @(posedge i_Clk or negedge i_Rst_L)
  begin
    if (~i_Rst_L)
    begin
      r2_RX_Done <= 1'b0;
      r3_RX_Done <= 1'b0;
      o_RX_DV    <= 1'b0;
      o_RX_Byte  <= 8'h00;
    end
    else
    begin
     
      r2_RX_Done <= r_RX_Done;

      r3_RX_Done <= r2_RX_Done;
    //  r4_RX_Done<=r3_RX_Done;
      if (r3_RX_Done == 1'b0 && r2_RX_Done == 1'b1)
      begin
        o_RX_DV   <= 1'b1;  
        o_RX_Byte <= r_RX_Byte;
      end
      else
      begin
        o_RX_DV <= 1'b0;
      end
    end
  end 


  always @(posedge w_SPI_Clk or posedge i_SPI_CS_n)
  begin
    if (i_SPI_CS_n)
    begin
      r_Preload_MISO <= 1'b1;
    end
    else
    begin
      r_Preload_MISO <= 1'b0;
    end
  end

  always @(posedge w_SPI_Clk or posedge i_SPI_CS_n)
  begin
    if (i_SPI_CS_n) begin
      r_TX_Bit_Count <= 3'b111;  // Send MSb first
      r_SPI_MISO_Bit <= r_TX_Byte[3'b111];  // Reset to MSb
    end
    else
    begin
      r_TX_Bit_Count <= r_TX_Bit_Count - 1;


      r_SPI_MISO_Bit <= r_TX_Byte[r_TX_Bit_Count];

    end 
  end 



  always @(posedge i_Clk or negedge i_Rst_L)
  begin
    if (~i_Rst_L)
    begin
      r_TX_Byte <= 8'h00;
    end
    else
    begin
      if (i_TX_DV)
      begin
        r_TX_Byte <= i_TX_Byte; 
      end
    end 
  end 

  assign w_SPI_MISO_Mux = r_Preload_MISO ? r_TX_Byte[3'b111] : r_SPI_MISO_Bit;
  assign o_SPI_MISO = i_SPI_CS_n ? 1'bZ : w_SPI_MISO_Mux;

endmodule 
