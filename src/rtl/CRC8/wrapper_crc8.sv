module wrapper_crc8(
  input                 p_clk_i,
  input                 p_rst_i,

  input       [31:0]    p_dat_i,

  output  reg [31:0]    p_dat_o,

  input                 p_sel_i,
  input                 p_enable_i,
  input                 p_we_i,     // write
  input       [31:0]    p_adr_i,
  
  output  reg           p_ready
);


  wire [7:0]  din_i;                  // Объявляем провода, которые будут подключаться к сигналам модуля
  wire [7:0]  crc_o;
  wire        crc_rd;
  wire        data_valid_i;

  crc8 crc8 
  (
    .clk_i        ( p_clk_i      ),
    .rst_i        ( !p_rst_i     ),
    .din_i        ( din_i        ),
    .data_valid_i ( data_valid_i ),
    .crc_rd       ( crc_rd       ),
    .crc_o        ( crc_o        )
  );

  reg cs_1;
  reg cs_2;

  // ФИЧА // Формирование строба cs цикла чтения или записи по системной шине
  always @ ( posedge p_clk_i ) begin
    cs_1 <= p_enable_i & p_sel_i;
    cs_2 <= cs_1;
  end
  wire cs = cs_1 & ( ~cs_2 );   

  // Формирование выходных данных системной шины
  always @ (*) begin //Для чтения crc используем адрес 1
    if ( cs & ( ~p_we_i ) & p_adr_i[3:0] == 4'd4 )
      p_dat_o <= {24'b0, crc_o}; 
  end

  // Формирование сигналов на модуль-вычислитель
  //Для записи данных для расчета crc используем адрес 0 
  assign data_valid_i = ( cs & p_we_i & p_adr_i[3:0] == 4'd0 );

  //Для записи данных для расчета crc используем адрес 0 
  assign din_i        = ( cs & p_we_i & p_adr_i[3:0] == 4'd0 );

  //Для чтения crc используем адрес 4
  assign crc_rd       = ( cs & ~p_we_i & p_adr_i[3:0] == 4'd4 );

  reg cs_ack1;
  reg cs_ack2;
  // Формирование сигнала готовности системной шины p_ready
  always @( posedge p_clk_i ) begin
    cs_ack1 <= cs_2;
    cs_ack2 <= cs_ack1;
  end

  always @( posedge p_clk_i ) begin
    p_ready <= (cs_ack1 & (~cs_ack2));
  end
  
endmodule