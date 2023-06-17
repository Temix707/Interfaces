module reg_vld
# (
    parameter w = 1
) 
(
  input                clk,
  input                srst,

  input                vld,
  input      [w - 1:0] d,
    
  output reg [w - 1:0] q
);

  always @( posedge clk or posedge srst ) begin
    if( srst ) begin
      q <= { 167 { 1'b0 } };
    end
    else if( vld ) begin
      q <= d;
    end 
  end

endmodule
