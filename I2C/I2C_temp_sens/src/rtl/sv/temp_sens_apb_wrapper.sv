module temp_sens_apb_wrapper
#(
  parameter APB_ADDR_WIDTH = 12,
  parameter APB_DATA_WIDTH = 32
)
(
  input   logic                       clk_i,
  input   logic                       srst_i,

  /*input   logic [APB_ADDR_WIDTH-1:0]  apb_ts_p_addr_i,
  input   logic [APB_DATA_WIDTH-1:0]  apb_ts_p_wdata_i,
  input   logic                       apb_ts_p_write_i,
  input   logic                       apb_ts_p_sel_i,
  input   logic                       apb_ts_p_enable_i,

  output  logic [APB_DATA_WIDTH-1:0]  apb_ts_p_rdata_o,
  output  logic                       apb_ts_p_ready_o,
  output  logic                       apb_ts_p_slverr_o,*/

  // I/O TEMP SENS
  inout  logic        TMP_SDA_io,         // i2c sda on temp sensor - bidirectional
  
  output logic        TMP_SCL_o,          // i2c scl on temp sensor
  
  output logic [7:0]  TMP_DATA_o

/*  
  output logic [7:0]  LED_o,              // nexys leds = binary temp in deg C

  output logic [6:0]  SEG_o,              // 7 segments of each display
  output logic [3:0]  AN_o,               // 4 anodes of 4 displays
  output logic [3:0]  NAN_o              // 4 anodes always OFF
*/
);
  
        
  logic       sda_dir;                    // direction of SDA signal - to or from master
  logic       w_200kHz;                   // 200kHz SCL
  //logic [7:0] w_data;                     // 8 bits of temperature data


  // Instantiate 200kHz clock generator
  clk_200kHz clkgen(
    .clk_100MHz_i ( clk_i       ),

    .clk_200kHz_o ( w_200kHz    )
  );

  // Instantiate i2c master
  i2c interf_i2c(
    .clk_200kHz_i ( w_200kHz    ),
    .srst_i       ( srst_i      ),

    .SDA_io       ( TMP_SDA_io  ),

    //.temp_data_o  ( w_data    ),
    .temp_data_o  ( TMP_DATA_o  ),
    .SDA_dir_o    ( sda_dir     ),
    .SCL_o        ( TMP_SCL_o   )
  );

/*
  // Set LED value to temp data
  assign LED_o = w_data;
    
  // Instantiate 7 segment control
  seg7 seg(
    .clk_100MHz_i ( clk_i       ),
    .temp_data_i  ( w_data      ),

    .SEG_o        ( SEG_o       ),
    .NAN_o        ( NAN_o       ),
    .AN_o         ( AN_o        )
  );
*/    

  /* ///////////////////////////////////////////// */

  //assign apb_ts_p_rdata_o = w_data;

  /*logic r_cs_1;
  logic r_cs_2;

  // ФИЧА // Формирование строба cs цикла чтения или записи по системной шине
  always_ff @ ( posedge clk_i ) begin
    r_cs_1 <= apb_ts_p_sel_i & apb_ts_p_enable_i;
    r_cs_2 <= r_cs_1;
  end

  logic r_cs = r_cs_1 & ( ~r_cs_2 );


  // Формирование ВЫХОДНЫХ данных (режим чтения) системной шины
  always_ff @ ( * ) begin //Для чтения crc используем адрес 1
    if ( r_cs & ( ~apb_ts_p_write_i ) & apb_ts_p_addr_i[3:0] == 4'd4 )
      apb_ts_p_rdata_o <= {24'b0, w_data}; 
  end


  // Формирование сигналов на модуль-вычислитель
  //Для записи данных для расчета crc используем адрес 0 
  //assign data_valid_i = ( r_cs & apb_ts_p_write_i & apb_ts_p_addr_i[3:0] == 4'd0 );

  //Для записи данных для расчета crc используем адрес 0 
  //assign din_i        = ( r_cs & apb_ts_p_write_i & apb_ts_p_addr_i[3:0] == 4'd0 );

  //Для чтения crc используем адрес 4
  assign r_ts_rd     = ( r_cs & ~apb_ts_p_write_i & apb_ts_p_addr_i[3:0] == 4'd4 );

  logic r_cs_ack1;
  logic r_cs_ack2;
  // Формирование сигнала готовности системной шины p_ready
  always @( posedge clk_i ) begin
    r_cs_ack1 <= r_cs_2;
    r_cs_ack2 <= r_cs_ack1;
  end

  always @( posedge clk_i ) begin
    apb_ts_p_ready_o <= (r_cs_ack1 & (~r_cs_ack2));
  end

*/




endmodule
