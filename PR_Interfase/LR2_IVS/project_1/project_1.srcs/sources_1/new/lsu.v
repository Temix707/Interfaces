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
input  [31:0]  instr_addr_o, // ����� ������
input data_req_o,  //������ ������ 1
input data_we_o, // ������
input [31:0] data_addr_o, //������ ������ � ������
input [31:0] data_wdata_o , // ��� ����������
 
input  data_be_o, //������ �����
output [31:0]  instr_rdata_i,
output [31:0] data_rdata_i //����������� ������ �� ������
    );
    reg [31:0] lsu1 [0:63]; // ������ ��� ����������
    
initial $readmemb ("instructions.mem",RAM);
                     
assign instr_rdata_i =  lsu1[instr_addr_o];// ������ ����������
    
    
      
      assign data_rdata_i =(data_req_o | lsu1[data_addr_o]); //������ ������
        
    always @ (posedge clk) //������
            if(data_req_o | data_we_o ) 
              lsu1[data_addr_o] <= data_wdata_o;
              
              else if (data_req_o |data_be_o )
                 lsu1[data_addr_o] <= data_wdata_o;
                 
        
endmodule
