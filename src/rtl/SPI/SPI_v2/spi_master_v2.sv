module spi_master_v2(
  input   logic         clk_i,          //  System clock
  input   logic         arst_i,         // Asynchronous system reset
  input   logic [15:0]  data_i,

  output  logic         spi_cs_l_o,     // Binary input vector
  output  logic         spi_sclk_o,       // SPI Active-low chip select
  output  logic         spi_data_o,     // SPI bus clock
  output  logic [4:0]   counter         // SPI bus data
);

logic [15:0]  MOSI;                     // SPI shift register
logic [4:0]   count;                    // Control counter
logic         cs_l;                     // SPI chip select (active-low)
logic         sclk;
logic [2:0]   state;


always_ff @( posedge clk_i or posedge arst_i ) begin
  if( arst_i ) begin
    MOSI  <= 16'b0;
    count <= 5'd16;
    cs_l  <= 1'b1;
    sclk  <= 1'b0;
  end
  else begin
    case( state )
      
      0: begin
        sclk  <= 1'b0;
        cs_l  <= 1'b1;

        state <= 1;
      end
          
      1: begin
        sclk  <= 1'b0;
        cs_l  <= 1'b0;
        MOSI  <= data_i[count - 1];
        count <= count - 1;

        state <= 2;
      end
            
      2: begin
        sclk  <= 1'b1;

        if( count > 0 ) begin
          state <= 1;
        end
        else begin
          count <= 16;
          state <= 0;
        end

      end
            
      default: begin
        state <= 0;
      end

    endcase    
  end

end


always_comb begin
  spi_cs_l_o = cs_l;
  spi_sclk_o = sclk;
  spi_data_o = MOSI;
  counter    = count;
end



endmodule
