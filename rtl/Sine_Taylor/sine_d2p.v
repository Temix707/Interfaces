module sine_d2p
  #(
    parameter WIDTH = 12
  )
  (
    input                  clk,
    input      [WIDTH-1:0] x_i,
   
    output reg [WIDTH-1:0] x_o  
  );
  
  always @( posedge clk ) begin  
    if( x_i[WIDTH - 1] ) begin
      x_o <= ( {x_i[WIDTH - 1], ( ~ x_i[WIDTH - 2:0] + 1 )} );
    end 
    else begin
      x_o <= x_i;
    end
  end

endmodule