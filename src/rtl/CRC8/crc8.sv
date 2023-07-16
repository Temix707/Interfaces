module crc8 (
  input             clk_i,
  input             rst_i,
  
  input       [7:0] din_i,
  input             data_valid_i,
  input             crc_rd,
  output reg  [7:0] crc_o
);

  // Параметры для состояний автомата
  localparam IDLE = 2'b00;
  localparam BUSY = 2'b01;
  localparam READ = 2'b10;

  reg [2:0] state; // Регистр состояний
  reg [7:0] data_current; // Текущие данные (сдвиговый регистр)
  reg [3:0] crc_counter; // Регистр счетчик обработанных бит входного байта данных для состояния вычисления

  always @( posedge clk_i ) begin
    if ( rst_i ) // Сигнал сброса - обнуляем все регистры
    begin
      state <= IDLE;
      data_current <= 8'b0;
      crc_o <= 8'b0;
      crc_counter <= 4'b0;
    end
    else begin
      case (state)
        IDLE:
          begin
            crc_counter <= 4'b0;
            if (data_valid_i) // Если пришли новые данные - переходимв состояние вычисления
            begin
              state <= BUSY;
              data_current <= din_i;
            end
            else if (crc_rd)state <= READ; // Если пришел запрос на чтение переходим в состояние чтения
        end
        
        BUSY:
          begin
            crc_o[7] <= crc_o[0]^data_current[0];
            crc_o[6] <= crc_o[7];
            crc_o[5] <= crc_o[6];
            crc_o[4] <= crc_o[5];
            crc_o[3] <= (crc_o[0] ^ data_current[0])^ crc_o[4];
            crc_o[2] <= (crc_o[0] ^ data_current[0])^ crc_o[3];
            crc_o[1] <= crc_o[2];

            crc_o[0] <= crc_o[1];
            data_current  <= {1'b0,data_current[7:1]};
            crc_counter   <= crc_counter+ 1'b1;
 
            if( crc_counter == 4'b111 ) state <= IDLE;
          end
          
        READ:
          begin
            crc_o <= 8'b0;
            state <= IDLE;
          end
      endcase
    end
  end
  
 endmodule