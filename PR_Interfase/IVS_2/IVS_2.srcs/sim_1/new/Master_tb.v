`timescale 1ns / 1ps

module Master_tb();

    reg clk;
    reg CE0;
    reg CE1;
    reg CPHA;
    wire Master_MOSI;
    reg Master_MISO;
    wire MOSI_data;
    reg [23:0] data;
    reg [4:0]  size;
    reg [1:0]  cs;
    reg [1:0]  memory_select;
    wire [23:0] current_data;
    wire [15:0] memory_slot0;
    wire [15:0] memory_slot1;
    reg        WE; // Включить загрузку данных и выбор ведомого
    reg        RD; // Включить чтение данных и выбор чипа
    reg        EN; // Включить действия с подчиненными периферийными устройствами
    reg        seg7_EN;
    wire       DS;
    wire       nMR;
    wire       STCP;
    wire       nOE;
    
    
    initial begin
      CE0     = 0;
      CE1     = 0;
      WE      = 0;
      RD      = 0;
      EN      = 0;
      CPHA    = 1;
      seg7_EN = 0;
    end
    
    Master_SPI Master
      (
      .SCLK          ( clk ),
      .CPHA          ( CPHA ), 
      .MISO          ( Master_MISO ),
      .MOSI          ( Master_MOSI ),
      .address_data  ( data ),
      .data_size     ( size ),
      .cs            ( cs ),
      .memory_select ( memory_select ),
      .WE            ( WE ),
      .RD            ( RD ),
      .EN            ( EN ),
      .seg7_EN       ( seg7_EN ),
      .DS            ( DS ),
      .nMR           ( nMR ),
      .STCP          ( STCP ),
      .nOE           ( nOE ),
      .sent_data     ( MOSI_data )
    );
    
    assign cs0          = Master.SS0;
    assign cs1          = Master.SS1;
    assign current_data = Master.current_data;
    //assign MOSI_data  = Master.sent_data;
    assign memory_slot0 = Master.memory_slot0;
    assign memory_slot1 = Master.memory_slot1;
    
    initial clk    = 0;
    
    always #10 clk = ~clk;  
    
    initial begin 
      config_for_11bit_DS1722;
      write_temperature_addr;         // Запись температуры
      get_temperature_init;           // Получение инициализации температуры
      shutdown_mode_DS1722;           // Режим выключения
      write_temperature_addr;
      get_temperature_init_updated; 
      config_register_TLA2518;
      set_read_addr_TLA2518;
      read_system_reg_TLA2518;
      out_to_7seg;
      $stop;         
    end
    
    task get_temperature_init;
    begin
      size = 5'b10000;
      memory_select = 2'b00;
      RD          = 1;
      #20;
      EN          = 1;
      Master_MISO = 1;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 1;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 1;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 1;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 1;
      #20;
      Master_MISO = 1;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 1;
      #40;
      EN          = 0;
      RD          = 0;
      #10;
    end
    endtask
    
    task config_register_TLA2518;
    begin
      #50;
      data = 16'b0000000100000111;
      size = 5'b10000;
      cs   = 2'b01;
      WE   = 1;
      #10
      EN   = 1;
      #400;
      EN   = 0;
      WE   = 0;
      data = 16'b0;
      size = 4'b0;
      #50;
    end
    endtask
    
    task config_for_11bit_DS1722;
    // 80h - адрес регистра
    begin
      #50;
      data = 16'b1000000011110110;
      size = 5'b10000;
      cs   = 2'b00;
      WE   = 1;
      #10
      EN   = 1;
      #400;
      EN   = 0;
      WE   = 0;
      data = 16'b0;
      size = 4'b0;
      #50;
    end
    endtask
    
    task get_temperature_init_updated;
    begin
      #10;
      size        = 5'b10000;
      RD          = 1;
      #20;
      EN          = 1;
      Master_MISO = 1;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 1;
      #20;
      Master_MISO = 1;
      #20;
      Master_MISO = 1;
      #20;
      Master_MISO = 1;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 1;
      #20;
      Master_MISO = 1;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 1;
      #40;
      EN          = 0;
      RD          = 0;
      #10;
    end
    endtask
    
    task set_read_addr_TLA2518;
    begin
      // Установка адреса
      data = 8'h81;
      size = 4'b1000;
      cs   = 2'b01;
      WE   = 1;
      #10;
      EN   = 1;
      #200;
      EN   = 0;
      WE   = 0;
      data = 16'b0;
      size = 4'b0;
    end
    endtask
    
    task read_system_reg_TLA2518;
    begin
      memory_select = 2'b01;
      size        = 5'b01000;
      RD          = 1;
      #10;
      EN          = 1;
      Master_MISO = 1;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 1;
      #20;
      Master_MISO = 0;
      #20;
      Master_MISO = 1;
      #20;
      Master_MISO = 1;
      #20;
      Master_MISO = 1;
      #20;
      Master_MISO = 0;
      #40;
      EN          = 0;
      RD          = 0;
      #10;
    end
    endtask
    
    
    task write_temperature_addr;
    begin
      data = 8'h01;
      size = 4'b1000;
      cs   = 2'b00;
      WE   = 1;
      #10;
      EN   = 1;
      #200;
      EN   = 0;
      WE   = 0;
      data = 16'b0;
      size = 4'b0;
    end
    endtask
    
    task shutdown_mode_DS1722;
    // 80h - адрес регистра
    begin
      #50;
      data = 16'b1000000011110111;
      size = 5'b10000;
      cs   = 2'b00;
      WE   = 1;
      #10
      EN   = 1;
      #400;
      EN   = 0;
      WE   = 0;
      data = 16'b0;
      size = 4'b0;
      #50;
    end
    endtask
    
    task out_to_7seg;
    begin
      #50;
      seg7_EN = 1'b1;
      #340
      seg7_EN = 1'b0;
      #50;
    end
    endtask
    
endmodule