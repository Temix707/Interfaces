module temp_sens_top(
  input  logic        CLK100MHZ_i,        // nexys clk signal
  input  logic        srst_i,             // btnC on nexys

  inout  logic        TMP_SDA_io,         // i2c sda on temp sensor - bidirectional
  
  output logic        TMP_SCL_o,          // i2c scl on temp sensor
  
  output logic [6:0]  SEG_o,              // 7 segments of each display
  output logic [3:0]  AN_o,               // 4 anodes of 4 displays
  output logic [3:0]  NAN_o,              // 4 anodes always OFF

  output logic [7:0]  LED_o               // nexys leds = binary temp in deg C
);
        
  logic       sda_dir;                    // direction of SDA signal - to or from master
  logic       w_200kHz;                   // 200kHz SCL
  logic [7:0] w_data;                     // 8 bits of temperature data


  // Instantiate 200kHz clock generator
  clk_200kHz clkgen(
    .clk_100MHz_i ( CLK100MHZ_i ),

    .clk_200kHz_o ( w_200kHz    )
  );

  // Instantiate i2c master
  i2c interf_i2c(
    .clk_200kHz_i ( w_200kHz    ),
    .srst_i       ( srst_i      ),

    .SDA_io       ( TMP_SDA_io  ),

    .temp_data_o  ( w_data      ),
    .SDA_dir_o    ( sda_dir     ),
    .SCL_o        ( TMP_SCL_o   )
  );
    
  // Instantiate 7 segment control
  seg7 seg(
    .clk_100MHz_i ( CLK100MHZ_i ),
    .temp_data_i  ( w_data      ),

    .SEG_o        ( SEG_o       ),
    .NAN_o        ( NAN_o       ),
    .AN_o         ( AN_o        )
  );
    
  // Set LED value to temp data
  assign LED_o = w_data;

endmodule