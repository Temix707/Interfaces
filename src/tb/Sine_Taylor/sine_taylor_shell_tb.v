`timescale 1ns / 1ps

module sine_taylor_shell_tb
  #(
    parameter INT_BITS_I = 12,       // 4 - ���.�,  8 - �����.� 
  
    parameter INT_BITS_O = 16        // 4 - ���.�, 12 - �����.� 
  )();

  reg                     clk_sh_i_tb;
  reg                     srst_sh_i_tb;
  
  reg   [INT_BITS_I-1:0]  x_sh_i_tb;
    
  wire  [INT_BITS_O-1:0]  sinx_sh_o_tb;

  always #10 clk_sh_i_tb = ~clk_sh_i_tb;
  
  sine_taylor_shell dut_shell
  (
    .clk_sh_i    ( clk_sh_i_tb  ),
    .srst_sh_i   ( srst_sh_i_tb ),
    .x_sh_i      ( x_sh_i_tb    ),
    
    .sinx_sh_o   ( sinx_sh_o_tb )
  );

  initial begin
    clk_sh_i_tb       = 1'b0;

    srst_sh_i_tb      = 1'b1;
    #20;
    srst_sh_i_tb      = 1'b0;
    
    x_sh_i_tb = 12'b0001_10000000; // 1,5
    $display ("Value 1: x = %b; Value sinx = %b", x_sh_i_tb, sinx_sh_o_tb);
    #40;
    x_sh_i_tb = 12'b0110_01000000; // 6,25
    $display ("Value 2: x = %b; Value sinx = %b", x_sh_i_tb, sinx_sh_o_tb);
    #40;
    x_sh_i_tb = 16'b0010_10000000; // 
    $display ("Value 3: x = %b; Value sinx = %b", x_sh_i_tb, sinx_sh_o_tb);
    #40;
    $display ("Value 4: x = %b; Value sinx = %b", x_sh_i_tb, sinx_sh_o_tb);
    #40;
    $stop;
  end


endmodule
