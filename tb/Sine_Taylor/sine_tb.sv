`timescale 1ns / 1ps
module sine_tb
#(
  parameter INT_BITS_I = 12,       // 4 - ���.�,  8 - �����.�   
  parameter INT_BITS_O = 16        // 4 - ���.�, 12 - �����.� 
)();

  reg                     clk_tb;
  reg                     srst_tb;
  
  reg   [INT_BITS_I-1:0]  x_sh_i_tb;
  reg                     arg_vld_tb;
  
    
  wire  [INT_BITS_O-1:0]  sinx_sh_o_tb;
  
  sine_taylor_shell dut_shell
  (
    .clk_sh_i     ( clk_tb       ),
    .srst_sh_i    ( srst_tb      ),
    .x_sh_i       ( x_sh_i_tb    ),
    .arg_vld_sh_i ( arg_vld_tb   ),
    
    .sinx_sh_o    ( sinx_sh_o_tb )
  );

  initial begin
      clk_tb = '0;
      forever #5 clk_tb = ~ clk_tb;
  end

  initial begin
    
    srst_tb <= '1;
    repeat (3)  @ (posedge clk_tb);
    srst_tb <= '0;

    arg_vld_tb <= 1;
    repeat (20) @ (posedge clk_tb);
    arg_vld_tb <= 0;
    repeat (10) @ (posedge clk_tb);
    arg_vld_tb <= 1;

    repeat (2) begin
        
      srst_tb <= '1;
      repeat (3) @ (posedge clk_tb);
      srst_tb <= '0;

    end

    arg_vld_tb <= 0;
    repeat (10) @ (posedge clk_tb);
    arg_vld_tb <= 1;
    repeat (30) @ (posedge clk_tb);

    $stop;
  end

  always @( posedge clk_tb ) begin
  
    if( arg_vld_tb ) begin
        
      x_sh_i_tb <= 12'b0001_10000000; // 1,5
      $display ("Value 1: x = %b; Value sinx = %b", x_sh_i_tb, sinx_sh_o_tb);
      repeat (3) @ (posedge clk_tb);

      x_sh_i_tb <= 12'b0110_01000000; // 6,25
      $display ("Value 2: x = %b; Value sinx = %b", x_sh_i_tb, sinx_sh_o_tb);
      repeat (3) @ (posedge clk_tb);
    
      x_sh_i_tb <= 16'b0010_10000000; // 
      $display ("Value 3: x = %b; Value sinx = %b", x_sh_i_tb, sinx_sh_o_tb);
      repeat (3) @ (posedge clk_tb);


      x_sh_i_tb <= 12'b0001_10000000; // 1,5
      $display ("Value 1: x = %b; Value sinx = %b", x_sh_i_tb, sinx_sh_o_tb);
      repeat (2) @ (posedge clk_tb);

      x_sh_i_tb <= 12'b0110_01000000; // 6,25
      $display ("Value 2: x = %b; Value sinx = %b", x_sh_i_tb, sinx_sh_o_tb);
      repeat (2) @ (posedge clk_tb);
    
      x_sh_i_tb <= 16'b0010_10000000; // 
      $display ("Value 3: x = %b; Value sinx = %b", x_sh_i_tb, sinx_sh_o_tb);
      repeat (2) @ (posedge clk_tb);

    end

  end

  final begin
    $display ("Inside final block at %0t", $time());
  end
  
endmodule