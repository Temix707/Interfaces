`timescale 1ns / 1ps

module SPI_tb();

reg clk; // clk signal for master -> slave devices
//reg CE0; // Emulation of DS1722 Chip Enable
//reg CE1; // Emulation of ADC TLA2518 Chip Enable
//reg CE2; // Emulation of 74HC595 Chip Enable
//reg CE3; // Emulation of 7'H indicator Chip Enable
reg CPHA; // CPHA Mode
reg MAKE_SHIFT_REGISTER;
reg SHIFT_ENABLE; // load to shift register enabled signal

// FPGA register data control wires / MISO / MOSI / data control:

wire FPGA_MOSI;
reg FPGA_MISO;
wire MOSI_DATA; // WR/R

reg [23:0] data;
reg [4:0] size;
reg [2:0] CS;
reg [1:0] slot_select;

reg WR; // Enable data loading and slave select
reg RD; // Enable data reading and chip select
reg EN; // Enable actions with slaves peripheral



initial begin
//    CE0 = 0;
//    CE1 = 0;
//    CE2 = 0;
//    CE3 = 0;
    WR = 0;
    RD = 0;
    EN = 0;
    CPHA = 1;
    MAKE_SHIFT_REGISTER = 0;
    SHIFT_ENABLE = 0;
end

FPGA_Master FPGA(.SCLK(clk),
                 .CPHA(CPHA), 
                 .MISO(FPGA_MISO),
                 .ADRESS_DATA(data),
                 .DATA_SIZE(size),
                 .CS_TB(CS),
                 .slot_select(slot_select),
                 .WR(WR),
                 .RD(RD),
                 .EN(EN),
                 .MAKE_SHIFT_REGISTER(MAKE_SHIFT_REGISTER),
                 .SHIFT_ENABLE(SHIFT_ENABLE)
);

// Assignations and wires block
wire [23:0] CURRENT_DATA;
wire [15:0] slot0;
wire [15:0] slot1;

assign CS0 = FPGA.SS0;
assign CS1 = FPGA.SS1;
//assign CS2 = FPGA.SS2;
//assign CS3 = FPGA.SS3;
assign FPGA_MOSI = FPGA.MOSI;
//assign FPGA_MISO = FPGA.MISO;
assign CURRENT_DATA = FPGA.CURRENT_DATA;
assign MOSI_DATA = FPGA.sended_data;
assign slot0 = FPGA.slot0;
assign slot1 = FPGA.slot1;
assign D = FPGA.D;
assign STCP = FPGA.STCP;

initial clk = 0; // initial of clk signal

always #10 clk = ~clk;  

initial begin 
    configure_DS1722_11bit;
    write_temperature_addr; 
    get_temperature_init;
    configure_DS1722_shutdown_mode;
    write_temperature_addr;
    get_temperature_init_updated; 
    config_register_TLA2518;
    set_read_addr_tla2518;
    read_system_reg_TLA2518;
    indicator_load;
    $stop;         
  end

task configure_DS1722_11bit;
// Отправить конфигурацию в датчик температуры
// 80h - адрес регистра, далее - данные
begin
    #50;
    data = 16'b10000000_1111_011_0; // data ->ADRESS_DATA
    size = 5'b10000; // size -> SIZE_REGISTER
    CS = 2'b00;
    WR = 1;
    #10
    EN = 1;
    #400;
    EN = 0;
    WR = 0;
    data = 16'b0;
    size = 4'b0;
    #50;
end
endtask

task get_temperature_init;
begin
// Получить температуру с датчика
    size = 5'b10000;
    slot_select = 2'b00;
    // После установки адреса 
    // Адрес установлен, отправляем данные:
    // Ожидаем
    RD = 1;
    #20;
    EN = 1;
    FPGA_MISO = 0;
    #40;
    FPGA_MISO = 0;
    #10;
    FPGA_MISO = 0;
    #10;
    FPGA_MISO = 1;
    #20;
    FPGA_MISO = 1;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 1;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 1;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #40;
    EN = 0;
    RD = 0;
    #10;
end
endtask

task get_temperature_init_updated;
begin
// Получить температуру с датчика
    #10;
    size = 5'b10000;
    // После установки адреса 
    // Адрес установлен, отправляем данные:
    // Ожидаем
    RD = 1;
    #20;
    EN = 1;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 1;
    #20;
    FPGA_MISO = 1;
    #20;
    FPGA_MISO = 1;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #40;
    EN = 0;
    RD = 0;
    #10;
end
endtask

task config_register_TLA2518;
begin
    #50;
    data = 16'b00000001_00000_111; // data ->ADRESS_DATA
    size = 5'b10000; // size -> SIZE_REGISTER
    CS = 2'b01;
    WR = 1;
    #10
    EN = 1;
    #400;
    EN = 0;
    WR = 0;
    data = 16'b0;
    size = 4'b0;
    #50;
end
endtask

task set_read_addr_tla2518;
begin
    // Готовимся считать температуру, ставим адрес
    data = 8'h81;
    size = 4'b1000;
    CS = 2'b01;
    WR = 1;
    #10;
    EN = 1;
    #200;
    EN = 0;
    WR = 0;
    data = 16'b0;
    size = 4'b0;
end
endtask

task read_system_reg_TLA2518;
begin
    slot_select = 2'b01;
    size = 5'b01000;
    RD = 1;
    #10;
    EN = 1;
    FPGA_MISO = 1;
    #20;
    FPGA_MISO = 1;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 1;
    #20;
    FPGA_MISO = 1;
    #20;
    FPGA_MISO = 0;
    #20;
    FPGA_MISO = 0;
    #40;
    EN = 0;
    RD = 0;
    #10;
end
endtask


task write_temperature_addr;
begin   
    // Готовимся считать температуру, ставим адрес
    data = 8'h01;
    size = 4'b1000;
    CS = 2'b00;
    WR = 1;
    #10;
    EN = 1;
    #200;
    EN = 0;
    WR = 0;
    data = 16'b0;
    size = 4'b0;
end
endtask

task configure_DS1722_shutdown_mode;
// Отправить конфигурацию в датчик температуры
// 80h - адрес регистра, далее - данные
begin
    #50;
    data = 16'b10000000_1111_011_1; // data ->ADRESS_DATA
    size = 5'b10000; // size -> SIZE_REGISTER
    CS = 2'b00;
    WR = 1;
    #10
    EN = 1;
    #400;
    EN = 0;
    WR = 0;
    data = 16'b0;
    size = 4'b0;
    #50;
end
endtask

task indicator_load;
begin
    #10;
    MAKE_SHIFT_REGISTER = 1;
    #30; // Небольшая задержка перед выводом
    MAKE_SHIFT_REGISTER = 0;
    #10;
    SHIFT_ENABLE = 1;
    #200;
end
endtask


endmodule