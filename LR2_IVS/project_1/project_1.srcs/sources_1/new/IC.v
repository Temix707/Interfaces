module IC(
    input         clk,
    input [31:0]  mie,
    input [31:0]  int_req,
    input         INT_RST,
    output [31:0] int_fin,//прерывание завершено
    output        INT,
    output [31:0] mcause
);

    reg  [4:0] counter =5'b0;
    reg  [31:0] from_DC;
    wire [31:0] to_int_fin;
    reg         INT_reg ;
    wire        to_INT_reg;
    
    always@(*)begin
    case(counter)
        5'b00000: from_DC <= 32'h00000001;
        5'b00001: from_DC <= 32'h00000002;
        5'b00010: from_DC <= 32'h00000004;
        5'b00011: from_DC <= 32'h00000008;
        5'b00100: from_DC <= 32'h00000010;
        5'b00101: from_DC <= 32'h00000020;
        5'b00110: from_DC <= 32'h00000040;
        5'b00111: from_DC <= 32'h00000080;
        5'b01000: from_DC <= 32'h00000100;
        5'b01001: from_DC <= 32'h00000200;
        5'b01010: from_DC <= 32'h00000400;
        5'b01011: from_DC <= 32'h00000800;
        5'b01100: from_DC <= 32'h00001000;
        5'b01101: from_DC <= 32'h00002000;
        5'b01110: from_DC <= 32'h00004000;
        5'b01111: from_DC <= 32'h00008000;
        5'b10000: from_DC <= 32'h00010000;
        5'b10001: from_DC <= 32'h00020000;
        5'b10010: from_DC <= 32'h00040000;
        5'b10011: from_DC <= 32'h00080000;
        5'b10100: from_DC <= 32'h00100000;
        5'b10101: from_DC <= 32'h00200000;
        5'b10110: from_DC <= 32'h00400000;
        5'b10111: from_DC <= 32'h00800000;
        5'b11000: from_DC <= 32'h01000000;
        5'b11001: from_DC <= 32'h02000000;
        5'b11010: from_DC <= 32'h04000000;
        5'b11011: from_DC <= 32'h08000000;
        5'b11100: from_DC <= 32'h10000000;
        5'b11101: from_DC <= 32'h20000000;
        5'b11110: from_DC <= 32'h40000000;
        5'b11111: from_DC <= 32'h80000000;
    endcase
end
  assign to_int_fin  =  from_DC &( mie  & int_req );  
  assign to_INT_reg  =  (|to_int_fin);
      always @(posedge clk)begin
        if(INT_RST) begin
         counter <= 5'b0;
         INT_reg <= 1'b0;
         end
       else  
         begin
         INT_reg <= to_INT_reg;
           if(~to_INT_reg)
              begin
              counter= counter + 1;
              end
         end
         end
         assign INT = to_INT_reg ^ INT_reg;
         assign int_fin = { 32{ INT_RST } } & to_int_fin;
         assign mcause = {27'h4000000, counter};
endmodule
