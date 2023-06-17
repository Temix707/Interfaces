module sine_taylor_shell
  #(
    parameter INT_BITS_I = 12,       // 4 - .,  8 - . 
    
    parameter INT_BITS_O = 16        // 4 - ., 12 - . 
  )
  (
  input                    clk_sh_i,
  input                    srst_sh_i,
  
  input  [INT_BITS_I-1:0]  x_sh_i,  
  input                    arg_vld_sh_i,  
    
  output [INT_BITS_O-1:0]  sinx_sh_o
  );
  
  // Inputs
  wire [INT_BITS_I-1:0] x_sh_w;
  reg  [INT_BITS_I-1:0] x_sh_r;

  wire                  arg_vld_sh_w;
  reg                   arg_vld_sh_r;
  
  // Outputs
  wire [INT_BITS_O-1:0] sinx_sh_w; 
  reg  [INT_BITS_O-1:0] sinx_sh_r;
  
  sine_taylor shell 
  ( 
    .clk_i   ( clk_sh_i     ),
    .srst_i  ( srst_sh_i    ), 
    .x_i     ( x_sh_r       ), 
    .arg_vld ( arg_vld_sh_r ),
    
    .sinx_o  ( sinx_sh_w    ) 
  );
  
  assign x_sh_w       = x_sh_i;

  assign arg_vld_sh_w = arg_vld_sh_i;

  assign sinx_sh_o    = sinx_sh_r;


  always @( posedge clk_sh_i ) begin
    if( srst_sh_i ) begin
      //x_sh_r       <= 0;
      //arg_vld_sh_r <= 0;

      sinx_sh_r    <= 0;
    end
    else begin
      x_sh_r       <= x_sh_w;

      arg_vld_sh_r <= arg_vld_sh_w;

      sinx_sh_r    <= sinx_sh_w; 
    end
  end
  
endmodule






















/*module sine_taylor_shell
  #(
    parameter INT_BITS_I = 12,       // 4 - ���.�,  8 - �����.� 
    
    parameter INT_BITS_O = 16        // 4 - ���.�, 12 - �����.� 
  )
  (
  input                     clk_sh_i,
  input                     srst_sh_i,
  
  input   [INT_BITS_I-1:0]  x_sh_i,
    
  output  [INT_BITS_O-1:0]  sinx_sh_o
  );
  
  // I
  wire [INT_BITS_I-1:0] x_sh_w_i;             
  reg  [INT_BITS_I-1:0] x_sh_r_o;             

  // O
  wire  [INT_BITS_O-1:0] sinx_sh_r_o;                   
  
  sine_taylor shell 
  ( 
    .clk_i   ( clk_sh_i    ),
    .srst_i  ( srst_sh_i   ),

    .x_i     ( x_sh_r_o    ), 
    
    .sinx_o  ( sinx_sh_r_o ) 
  );
  
  assign x_sh_w_i    = x_sh_i;                // i
  //assign sinx_sh_o = sinx_sh_r_o;
  
  always @(posedge clk_sh_i or posedge srst_sh_i) begin
    if( srst_sh_i ) begin
      sinx_sh_o <= 16'd0;
    end
    else begin
      x_sh_r_o    <= x_sh_w_i;                  // i
      sinx_sh_o   <= sinx_sh_r_o; 
    end
  end
  
endmodule
*/