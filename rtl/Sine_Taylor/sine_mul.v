module sine_mul
(
  input             clk,

  input      [83:0] const,
  input      [83:0] d_mul,
    
  output reg [167:0] q_mul
);

  always @ ( posedge clk ) begin  
    q_mul <= d_mul * const;
  end

endmodule