`timescale 1ns / 1ps

module uart_tb();

        logic       clk_tb_i, srst_tb_i;      
  //Transmitter
  wire  logic       TxD_tb_o;

  //Receiver
        logic       RxD_tb_i;
  wire  logic [7:0] RxData_tb_o;


  uart_top DUT_TOP
  (
    .clk_i     ( clk_tb_i     ),
    .srst_i    ( srst_tb_i    ),

    .TxD_o     ( TxD_tb_o     ), 

    .RxD_i     ( RxD_tb_i     ),
    .RxData_o  ( RxData_tb_o  )
  );

 initial begin
      clk_tb_i = 0;
      forever #5 clk_tb_i = ~ clk_tb_i;
  end

  initial begin
    $display ("Start");

    srst_tb_i <= 1;

    repeat ( 5 ) begin
      @( posedge clk_tb_i ) begin
        $display ("Bang %b", clk_tb_i);
        srst_tb_i <= 1;
      end
    end

    srst_tb_i <= 0;
  end





endmodule
