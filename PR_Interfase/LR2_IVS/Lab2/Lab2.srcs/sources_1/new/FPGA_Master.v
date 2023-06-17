module FPGA_Master(SCLK,
                   CPHA, 
                   D, 
                   SHCP,
                   STCP,  
                   MOSI, 
                   sended_data, 
                   MISO, 
                   WR, 
                   RD, 
                   EN, 
                   ADRESS_DATA, 
                   DATA_SIZE, 
                   CS_TB, 
                   slot_select, 
                   SS0, 
                   SS1, 
                   SS2, 
                   SS3,
                   MAKE_SHIFT_REGISTER,
                   SHIFT_ENABLE);
    input SCLK; //  clk signal
    input CPHA; // CPHA Mode
    output reg D; // FPGA -> 74HC595
    output reg SHCP;
    output reg STCP;
    
    input MISO; // Master input from slave output
    output reg MOSI; // Master output to slave input
    output reg sended_data; // Data -> per. device
    
    input [23:0] ADRESS_DATA; // Data to send (from testbench module); [2 bits-data_size + 16 bits]
    input [4:0] DATA_SIZE;
    input [2:0] CS_TB;
    input [1:0] slot_select;    
    
    input EN; // Communicate with peripheral enabled / disabled
    input WR; // Write enable
    input RD; // Read enable
    input MAKE_SHIFT_REGISTER;
    input SHIFT_ENABLE;
    
    output reg SS0; // Slave 1 select (DS1722)
    output reg SS1; // Slave 2 select (ADC TLA2518)
    output reg SS2; // Slave 4 select (7H'Indicator)
    output reg SS3; // Slave 3 select (74HC595 Register)
    
//FPGA Memory:
reg [23:0] CURRENT_DATA;
reg [4:0] input_package_size;
// 2 ячейки памяти
reg [15:0] slot0;
reg [15:0] slot1;
reg [15:0] register_shift; // Отправляет на семисегментные индикаторы


// reg [15:0] DATA_SIZE_REGISTER; // To control the size of package

// FPGA Drivers:
parameter CPOL = 1'b1;
integer package_size = 0;
integer shifted = 0;

initial begin
SS0 = 1;
SS1 = 1;
SS2 = 1;
SS3 = 1;
slot0 = 16'b0;
slot1 = 16'b0;
sended_data = 0;
CURRENT_DATA = 23'b0;
end

// SPI Interface description:
// Modes: 
//_____________________________________________
//| 2    | 1                    | 0           |
//+------+----------------------+-------------+
//| 3    | 1                    | 1           |
//+------+----------------------+-------------+

always @(SCLK, WR, RD, EN) begin

if (MAKE_SHIFT_REGISTER == 1) begin
    register_shift = {slot0[7:0], slot1[7:0]};
end

else if (WR==1 & EN == 0) begin
    $display("In WR block");
    // Настройка перед записью
    CURRENT_DATA = ADRESS_DATA; // Даннные для записи в устройство
    input_package_size = DATA_SIZE;
    //DATA_SIZE_REGISTER = {1'b1{DATA_SIZE}};  
    // Выбираем устройство для записи
    case(CS_TB)
        2'b00: SS0 = 0;
        2'b01: SS1 = 0;
        2'b10: SS2 = 0;
        2'b11: SS3 = 0;
    endcase
    end

else if (RD == 1 & EN == 0) begin
    case(CS_TB)
        2'b00: SS0 = 0;
        2'b01: SS1 = 0;
        2'b10: SS2 = 0;
        2'b11: SS3 = 0;
    endcase
    end
    
else if (EN == 1 & WR == 1 & RD == 0) begin
    // Работа интерфейса
    
    if (CPHA == 1) begin // Для CPHA = 1 Mode
        if ((package_size != DATA_SIZE) & (~SS0 || ~SS1 || ~SS2 || ~SS3)) begin         
            if (SCLK == 0) begin // По негативному фронту производим смену данных
                MOSI = CURRENT_DATA[DATA_SIZE-1];
                CURRENT_DATA = CURRENT_DATA << 1'b1;
                package_size = package_size + 1;
                end
            else if (SCLK == 1) 
                sended_data = MOSI;         
            end 
        else begin
            $display("Finished frame");
            // Сбрасываем все параметры передачи, если пакет закончился
            CURRENT_DATA = 24'b0; 
            sended_data = 0;
            MOSI = 0;
            SS0=1;
            SS1=1; 
            SS2=1;
            SS3=1;
            package_size=0;
            end
        end
    end   


else if (EN == 1 & WR == 0 & RD == 1) begin
    // Считываем данные с источника
    if ((package_size != DATA_SIZE + 1) & (~SS0 || ~SS1 || ~SS2 || ~SS3)) begin
        if (SCLK == 0) begin
            // Данные считываются
            package_size = package_size + 1;      
            end            
        else if (SCLK == 1) begin
            case(slot_select)
                2'b00: slot0 = {slot0[14:0], MISO};
                2'b01: slot1 = {slot1[14:0], MISO};
                endcase
            $display("MISO getted: %d", MISO);
            end
        $display("%d", package_size);
        end
    else begin
        SS0=1;
        SS1=1; 
        SS2=1;
        SS3=1;
        package_size=0;
        end                    
    end

else if (SHIFT_ENABLE == 1) begin
    if (SCLK == 1 & shifted <= 15) begin
        D = register_shift[0];
        register_shift = register_shift >> 1'b1;
        shifted = shifted + 1;
        STCP = 0;
        if (shifted == 7 || shifted == 15) begin
            STCP = 1;
            end
        end
    else if (shifted > 15) begin
        STCP = 0;
        end            
    end       
end

endmodule