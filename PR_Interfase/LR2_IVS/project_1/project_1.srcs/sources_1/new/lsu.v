`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2022 15:40:23
// Design Name: 
// Module Name: lsu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module lsu(
input clk,
input  [31:0]  instr_addr_o, // адрес чтения
input data_req_o,  //чтение запись 1
input data_we_o, // запись
input [31:0] data_addr_o, //адресс записи и чтения
input [31:0] data_wdata_o , // что записываем
 
input  data_be_o, //запись битов
output [31:0]  instr_rdata_i,
output [31:0] data_rdata_i //прочитанные данные до записи
    );
    reg [31:0] lsu1 [0:63]; // память для инструкций
    
initial $readmemb ("instructions.mem",RAM);
                     
assign instr_rdata_i =  lsu1[instr_addr_o];// чтение инструкций
    
    
      
      assign data_rdata_i =(data_req_o | lsu1[data_addr_o]); //чтение данных
        
    always @ (posedge clk) //запись
            if(data_req_o | data_we_o ) 
              lsu1[data_addr_o] <= data_wdata_o;
              
              else if (data_req_o |data_be_o )
                 lsu1[data_addr_o] <= data_wdata_o;
                 
        
endmodule
