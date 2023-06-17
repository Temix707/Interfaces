`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.09.2022 17:15:39
// Design Name: 
// Module Name: RF_tb
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
//    reg       clk;
//    reg [4:0] a1;
//    reg [4:0] a2;
//    reg [4:0] a3;
//    reg       we3;
//    reg [31:0] wd3;
//    wire [31:0] rd1, rd2;
//           initial clk = 0;
//           always #10 clk =~clk;
//RF dut (a1, a2, a3, we3, wd3, rd1, rd2);
//    initial begin
//     RF_op(); 
//        end
//    task RF_op;
//        input [4:0] a1_op, a2_op, a3_op;
//        input [31:0] wd3_op;
//        input we3_op, clk_op;
//    begin                             
//            if(we3_op ==1) // запись
//         begin
//            clk_op = clk;
//            a3_op  = a3;
//            wd3_op = wd3;
//            #10;
//        end
//            else 
//                 begin //if(a1_op == 1 | a2_op == 1) чтение
//                     a1_op = a1;
//                     a2_op = a2;
//                     #10; 
//                end 
//    end            
//    endtask
//////////////////////////////////////////////////////////////////////////////////


module RF_tb();
    reg [31:0]   IN;
    reg         clk;
    reg         _en;
    reg         rst;
    wire        OUT;
    initial clk = 0;
    always #10 clk =~clk;
wrapper dut (.IN(IN), .rst(rst), .en(_en), .clk(clk), .OUT(OUT));
        initial begin
        #20;
        IN = 15; _en =1; rst = 0;
        
        
         
      // rd = 32'b00100000000000000000000001000001; //записать в первую €чейку 2
     //  rd = 32'b00100000000000000000000000100010;//записать во вторую €чейку 1 
      // rd = 32'b00110000000001000100000000000011; //записать результат сложени€ в третью €чейку
        end
       endmodule