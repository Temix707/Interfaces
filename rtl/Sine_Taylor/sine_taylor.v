module sine_taylor 
#(
  parameter INT_BITS_I = 12,       // 4 ,  8  
            FRAC_BITS  = 100,
            INT_BITS_O = 16        // 4 , 12
)
(
  input                          clk_i,
  input                          srst_i,

  input        [INT_BITS_I-1:0]  x_i,
  input                          arg_vld,
    
  output       [INT_BITS_O-1:0]  sinx_o
);
  
  // constants
  wire [83:0] CONST1 = 84'b0000000000000000000000000000_00101010000000000000000000000000000000000000000000000000;   // 16'b0000_001010100000;  //  ~ 0.16
  wire [83:0] CONST2 = 84'b0000000000000000000000000000_00000010001000000000000000000000000000000000000000000000;   // 16'b0000_000000100010;  //  ~ 0.0083
  wire [83:0] CONST3 = 84'b0000000000000000000000000000_00000000000100000000000000000000000000000000000000000000;   // 16'b0000_000000000001;  //  ~ 0.0001984
  

  wire [INT_BITS_I-1:0]       x_i_q;
  
  reg_vld # ( INT_BITS_I ) 
  arg_i     ( .clk( clk_i ), .srst(srst_i), .vld( arg_vld ), .d( x_i ), .q( x_i_q ) );


  wire [INT_BITS_I-1:0]       x_o_q;    
  
  sine_d2p d2p1 ( .clk( clk_i ), .x_i( x_i_q )   , .x_o( x_o_q ) );                 // dop code to pr code
  
  // Calculation in degree
  wire [3 * INT_BITS_I-1:0]   x3_q;                                                 // 36
  wire [5 * INT_BITS_I-1:0]   x5_q;                                                 // 60
  wire [7 * INT_BITS_I-1:0]   x7_q;                                                 // 84

  wire x_vld = ( x_o_q != 0 );

  // Exponentiation
  sine_degree # ( INT_BITS_I, 36, 3 ) 
  deg_3         ( .clk( clk_i ), .vld( x_vld ), .x_deg( x_o_q ), .x_d_m( x3_q ) );  // [35:0] ; [35:24][23:0]
  
  sine_degree # ( INT_BITS_I, 60, 5 ) 
  deg_5         ( .clk( clk_i ), .vld( x_vld ), .x_deg( x_o_q ), .x_d_m( x5_q ) );  // [59:0] ; [59:40][39:0]
  
  sine_degree # ( INT_BITS_I, 84, 7 ) 
  deg_7         ( .clk( clk_i ), .vld( x_vld ), .x_deg( x_o_q ), .x_d_m( x7_q ) );  // [83:0] ; [83:56][55:0]



  // SE
  reg [167:0] SE_x_o; 
  reg [83:0]  SE_x3, SE_x5, SE_x7;

  always @( posedge clk_i ) begin
    SE_x_o [167:0] <= {52'd0 , x_o_q[    INT_BITS_I-1:0] , 104'd0};                 // [167:116][115:105][103:0] ;  [167:112][111:0]
    SE_x3  [83:0]  <= {16'd0 , x3_q [3 * INT_BITS_I-1:0] , 32'd0 };
    SE_x5  [83:0]  <= {8'd0  , x5_q [5 * INT_BITS_I-1:0] , 16'd0 };
    SE_x7  [83:0]  <=          x7_q [7 * INT_BITS_I-1:0]          ;
  end
  


  wire [83:0] SE_x3_d, SE_x5_d, SE_x7_d;
  assign SE_x3_d = SE_x3;
  assign SE_x5_d = SE_x5;
  assign SE_x7_d = SE_x7;

  wire [14 * INT_BITS_I-1:0] r_res_mc1, r_res_mc2, r_res_mc3;


  // Multiplication
  sine_mul    
  mul_const1 ( .clk( clk_i ), .const( CONST1 ), .d_mul( SE_x3_d ), .q_mul( r_res_mc1 ) );
  
  sine_mul   
  mul_const2 ( .clk( clk_i ), .const( CONST2 ), .d_mul( SE_x5_d ), .q_mul( r_res_mc2 ) );
  
  sine_mul   
  mul_const3 ( .clk( clk_i ), .const( CONST3 ), .d_mul( SE_x7_d ), .q_mul( r_res_mc3 ) );



  reg   [14 * INT_BITS_I-1:0]  r_res;
  wire  [INT_BITS_O-1:0]       RetVal;

  // // ( SE_x_o - ( SE_x3 * CONST1 ) + ( SE_x5 * CONST2 ) - ( SE_x7 * CONST3 ) )
  always @( posedge clk_i ) begin
    r_res                        <= SE_x_o - r_res_mc1 + r_res_mc2 - r_res_mc3;
  end 
  assign RetVal[INT_BITS_O - 1:0] = r_res[INT_BITS_O - 1 + FRAC_BITS : FRAC_BITS];    //  [115:100]   [59:44] = 16 b

  sine_p2d p2d1 ( .clk( clk_i ), .x_i( RetVal ), .x_o( sinx_o ) );                    // pr code to dop code
 
endmodule    





//FIXED_POINT
//                  .   1/2  1/4   1/8    1/16     1/32      1/64      1/128      1/256
//  16  8   4   2   .   0.5  0.25  0.125  0.0625  0.03125  0.015625  0.0078125  0.00390625
//  4   3   2   1   .   -1   -2     -3      -4      -5       -6         -7          -8

//The sine of the taylor series
// sin x  = x - (x^3/3!) + (x^5/5!) ? (x^7/7!) ...    y C[-1,1]
  
//Constants
// 1/3! = 1/6     ~  0.166667  = 0 + 1/8 + 1/32 + 1/128    = 0.0010101 
// 1/5! = 1/120   ~  0.0083    = 0 + 1/128 + (-11)         = 0.00000010001
// 1/7! = 1/5040  ~  0.0001984 = 0 + (-13) + (-14) + (-16) = 0.0000000000001101
