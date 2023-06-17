module uart_top(
  input   logic       clk_i,
  input   logic       srst_i,         

  //Transmitter
  //input   logic [7:0] data_i,        
  //input   logic       transmit_i,     

  output  logic       TxD_o,


  //Receiver
  input   logic       RxD_i,

  output  logic [7:0] RxData_o
);

  logic valid, ready;
    

  //Receiver(keyboard) -  without Deboune_signals  - Transmitter - Receiver (Terminal) 

  uart_rx DUT_rx
  (
    .clk_i          ( clk_i         ),
    .srst_i         ( srst_i        ),
    .RxD_i          ( RxD_i         ),

    .ready_i        ( ready         ),
    .valid_o        ( valid         ),    

    .RxData_o       ( RxData_o      )       
  );


  uart_tx DUT_tx
  (
    .clk_i          ( clk_i         ),
    .srst_i         ( srst_i        ),
    .tr_but_i       ( RxD_i         ),
    .data_i         ( RxData_o      ),      

    .valid_i        ( valid         ),
    .ready_o        ( ready         ),

    .TxD_o          ( TxD_o         )       
  );





  //logic transmit_out;

 //Receiver - Transmitter 

   //Transmitter
 
/*
  Deboune_signals DB
  (
    .clk_i        ( clk_i         ),
    .btn_i        ( transmit_i    ),
    
    .tr_signal_o  ( transmit_out  )
  );


  Transmitter TR
  (
    .clk_i        ( clk_i         ),
    .srst_i       ( srst_i        ),
    .tr_but_i     ( transmit_out  ),
    .data_i       ( data_i        ),
    
    .TxD_o        ( TxD_o         )
  );



  //Receiver
  
  Receiver RC
  (
    .clk_i        ( clk_i         ),
    .srst_i       ( srst_i        ),
    .RxD_i        ( RxD_i         ),

    .RxData_o     ( RxData_o      )

  );
*/





 //Receiver(keyboard) - with Deboune_signals - Transmitter - Receiver (Terminal) 

/*
  uart_rx RC_w_T
  (
    .clk_i          ( clk_i         ),
    .srst_i         ( srst_i        ),
    .RxD_i          ( RxD_i         ),     1    

    .RxData_o       ( RxData_o      )      8
  );


    Deboune_signals DB_w_T
  (
    .clk_i          ( clk_i         ),
    .btn_i          ( RxD_i         ),   1
    
    .tr_signal_o    ( transmit_out  )    1  
  );


  uart_tx TR_w_T
  (
    .clk_i          ( clk_i         ),
    .srst_i         ( srst_i        ),
    .tr_but_i       ( transmit_out  ),
    .data_i         ( RxData_o      ),   8

    .TxD_o          ( TxD_o         )    1
  );
*/


endmodule

   //frequency = oversempling rate  bod rate
   //TxD_o, RxD_i- 1 - off, 0 = on