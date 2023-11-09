module clk_200kHz(
  input  logic clk_100MHz_i,

  output logic clk_200kHz_o
);
    
  // 100 x 10^6 / 200 x 10^3 / 2 = 250 <-- 8 bit counter
  logic [7:0] counter = 8'h00;
  logic       clk_reg = 1'b1;
    
  always_ff @( posedge clk_100MHz_i ) begin
    if( counter == 249 ) begin
      counter <= 8'h00;
      clk_reg <= ~clk_reg;
    end 
    else
      counter <= counter + 1;
  end
    
  assign clk_200kHz_o = clk_reg;
    
endmodule
