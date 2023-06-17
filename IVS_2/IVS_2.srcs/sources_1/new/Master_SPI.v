module Master_SPI(
  input               SCLK,
  input       [23:0]  address_data,    // Данные
  input               seg7_EN,         // 7-сегментный индикатор
  input               EN,              // Взаимодействие с периферией
  input               WE,              // Запись
  input               RD,              // Чтение
  input       [4:0]   data_size,       // Размер данных
  input       [1:0]   cs,              // cs/ss SPI выбирает, с каким ведомым SPI устанавливать связь
  input       [1:0]   memory_select,
  input               CPHA,            // Фаза
  input               MISO,            
  
  output reg          SS0,             // DS1722  (Датчик температур)
  output reg          SS1,             // TLA2518 (АЦП)
  output reg          MOSI,
  output reg          sent_data,      
  output reg          DS,              // Вход данных сдвигового регистра
  output              nMR,             // Вход сброса сдвигового регистра
  output reg          STCP,            // Тактовый вход регистра хранения
  output              nOE              // Вход разрешения выходных буферов
);

  reg      [23:0] current_data;     
  reg      [4:0]  input_package_size;
  reg      [15:0] memory_slot0;
  reg      [15:0] memory_slot1;
  reg      [7:0]  seg7_1;
  reg      [7:0]  seg7_2;
  wire     [15:0] seg7_out            = {seg7_2, seg7_1};
  reg      [3:0]  seg7_counter        = 4'b0;
  reg      [4:0]  STCP_counter        = 5'b0;
  integer         package_size        = 0;                    // Счетчик пакетов
    
  initial begin
    SS0           <= 1;
    SS1           <= 1;
    memory_slot0  <= 16'b0;
    memory_slot1  <= 16'b0;
    sent_data     <= 0;
    current_data  <= 23'b0;
  end
    
  always @( SCLK )
    begin
      // *Низкий уровень означает, что выбран подчиненный (низкий уровень эффективен) //
      // Запись (параллельное подключение)
      if ( WE == 1 & EN == 0 ) begin 
        current_data       [23:0]  <= address_data;
        input_package_size [4:0]   <= data_size;
        case( cs )
          2'b00: SS0     <= 0;
          2'b01: SS1     <= 0;
        endcase
      end 
      
      // Считывание (параллельное подключение)
      else if ( RD == 1 & EN == 0 ) begin
        case( cs )
          2'b00: SS0 <= 0;
          2'b01: SS1 <= 0;
        endcase
      end
      
      // 5.Настроить внешний АЦП TLA2518. Считать, что это первая команда после включения устройства. (CPHA = 1, CPOL = 1.)
      // Тактовая последовательность SCLK начинается с формирования отрицательного фронта. 
      // Считывание данных осуществляется по положительному фронту на линии SCLK. Смена данных по отрицательному фронту.
      
      // Master-устройство устанавливает на линии SS выбранного Slave-устройства высокий уровень сигнала для начала сеанса обмена.
      // Запись
      else if ( WE == 1 & EN == 1 & RD == 0 ) begin
        if ( CPHA == 1 ) begin
          if ( ( package_size != data_size ) & ( ~SS0 || ~SS1 ) ) begin
                   
            if ( SCLK == 0 ) begin
              MOSI         <= current_data[data_size-1];
              current_data <= current_data << 1'b1;
              package_size <= package_size + 1;
            end
            else if ( SCLK == 1 ) //
              sent_data    <= MOSI;         
            end 
          
          // Не устанавливает связь
          else begin
            current_data <= 24'b0; 
            sent_data    <= 0;
            MOSI         <= 0;
            SS0          <= 1;
            SS1          <= 1;
            package_size <= 0;
          end
          
        end
      end   
        
      // Считывание
      else if ( EN == 1 & WE == 0 & RD == 1 ) begin
      
        if (( package_size != data_size + 1 ) & ( ~SS0 || ~SS1 )) begin
          if ( SCLK == 0 ) begin
            package_size <= package_size + 1;      
          end            
          else if ( SCLK == 1 ) begin // Отображение на индикаторах
            case( memory_select )
              2'b00: memory_slot0 [15:0] <= {memory_slot0[14:0], MISO};
              2'b01: memory_slot1 [15:0] <= {memory_slot1[14:0], MISO};
            endcase
          end
        end
        
      else begin
        SS0          <= 1;
        SS1          <= 1;
        package_size <= 0;
      end                    
    end
  end
    
    
  // Работа с 74HC595 (Индикаторы)
  always @( * ) begin
    case( memory_slot0[11:8] )
      4'h0: seg7_1 = 8'b01000000;
      4'h1: seg7_1 = 8'b01111001;
      4'h2: seg7_1 = 8'b00100100;
      4'h3: seg7_1 = 8'b00110000;
      4'h4: seg7_1 = 8'b00011001;
      4'h5: seg7_1 = 8'b00010010;
      4'h6: seg7_1 = 8'b00000010;
      4'h7: seg7_1 = 8'b01111000;
      4'h8: seg7_1 = 8'b00000000;
      4'h9: seg7_1 = 8'b00010000;
      4'hA: seg7_1 = 8'b00001000;
      4'hB: seg7_1 = 8'b00000011;
      4'hC: seg7_1 = 8'b01000110;
      4'hD: seg7_1 = 8'b00100001;
      4'hE: seg7_1 = 8'b00000110;
      4'hF: seg7_1 = 8'b00001110;
    endcase
    
    case( memory_slot1[3:0] )
      4'h0: seg7_2 = 8'b01000000;
      4'h1: seg7_2 = 8'b01111001;
      4'h2: seg7_2 = 8'b00100100;
      4'h3: seg7_2 = 8'b00110000;
      4'h4: seg7_2 = 8'b00011001;
      4'h5: seg7_2 = 8'b00010010;
      4'h6: seg7_2 = 8'b00000010;
      4'h7: seg7_2 = 8'b01111000;
      4'h8: seg7_2 = 8'b00000000;
      4'h9: seg7_2 = 8'b00010000;
      4'hA: seg7_2 = 8'b00001000;
      4'hB: seg7_2 = 8'b00000011;
      4'hC: seg7_2 = 8'b01000110;
      4'hD: seg7_2 = 8'b00100001;
      4'hE: seg7_2 = 8'b00000110;
      4'hF: seg7_2 = 8'b00001110;
    endcase
  end
      
  // Сдвиговыые регисьры   
  assign nMR = ~seg7_EN;  // Вход сброса сдвигового регистра
  assign nOE = 1'b0;      // Вход разрешения выходных буферов
    
  always @( SCLK ) begin
    // По положительному перепаду тактового сигнала на входе STCP данные с выхода сдвигового регистра записываются в регистр хранения.
    if ((( STCP_counter == 5'b01000 ) || ( STCP_counter == 5'b10000 )) && ( SCLK == 1'b0 )) begin
      STCP <= 1'b1;
    end
    else begin
      STCP <= 1'b0;
    end
  end
    
    
  always @(negedge SCLK) begin
    if ( seg7_EN ) begin
      seg7_counter <= seg7_counter + 1'b1;
      STCP_counter <= STCP_counter + 1'b1;
      DS           <= seg7_out[seg7_counter];
    end 
    else begin
      seg7_counter <= 4'b0;
      STCP_counter <= 5'b0;
      DS           <= 1'b0;
    end
  end

endmodule