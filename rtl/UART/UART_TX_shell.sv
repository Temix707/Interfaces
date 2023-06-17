module UART_TX_shell(
  input   logic       clk_i,
  input   logic       srst_i,         // btn_0
  input   logic [7:0] data_i,        
  input   logic       transmit_i,     // btn_1

  output  logic       TxD_o
);

  logic transmit_out;

// frequency = oversempling rate * bod rate

  signal_delivery DUT_DB
  (
    .clk_i        ( clk_i         ),
    .btn_i        ( transmit_i    ),
    
    .tr_signal_o  ( transmit_out  )
  );


  uart_tx DUT_TX
  (
    .clk_i        ( clk_i         ),
    .srst_i       ( srst_i        ),
    .tr_but_i     ( transmit_out  ),
    .data_i       ( data_i        ),
    .TxD_o        ( TxD_o         )
  );


endmodule