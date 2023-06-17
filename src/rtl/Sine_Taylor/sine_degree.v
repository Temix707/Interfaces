module sine_degree
# (
  parameter BITS_I = 1,
            BITS_O = 1,
            NUM    = 1
)
(
  input                   clk,

  input                   vld,
  input      [BITS_I-1:0] x_deg,

  output reg [BITS_O-1:0] x_d_m
);


  reg [2 * BITS_I-1:0] x_d_m_2;
  reg [3 * BITS_I-1:0] x_d_m_3;
  reg [4 * BITS_I-1:0] x_d_m_4; 
  reg [5 * BITS_I-1:0] x_d_m_5;
  reg [6 * BITS_I-1:0] x_d_m_6;
  reg [7 * BITS_I-1:0] x_d_m_7;

  always @( posedge clk ) begin
    if( vld ) begin
      if( NUM == 3) begin
        x_d_m_2 <= x_deg   * x_deg;
        x_d_m_3 <= x_d_m_2 * x_deg;
        x_d_m   <= x_d_m_3;
      end
      else if ( NUM == 5 ) begin
        x_d_m_2 <= x_deg   * x_deg;
        x_d_m_3 <= x_d_m_2 * x_deg;
        x_d_m_4 <= x_d_m_3 * x_deg;
        x_d_m_5 <= x_d_m_4 * x_deg;
        x_d_m   <= x_d_m_5;
      end
      else if ( NUM == 7 ) begin
        x_d_m_2 <= x_deg   * x_deg;
        x_d_m_3 <= x_d_m_2 * x_deg;
        x_d_m_4 <= x_d_m_3 * x_deg;
        x_d_m_5 <= x_d_m_4 * x_deg;
        x_d_m_6 <= x_d_m_5 * x_deg;
        x_d_m_7 <= x_d_m_6 * x_deg;
        x_d_m   <= x_d_m_7;
      end
    end
  end

endmodule