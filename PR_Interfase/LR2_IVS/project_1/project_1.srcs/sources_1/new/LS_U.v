
`define LDST_B           3'b000
`define LDST_H           3'b001
`define LDST_W           3'b010
`define LDST_BU          3'b100
`define LDST_HU          3'b101


module LS_U( 

    input         clk_i,    // синхронизация
    input         arstn_i, //сброс внутренних регистров 
    //core protocol
    input [31:0]       lsu_addr_i,      // адрес, по которому хотим обратиться
    input              lsu_req_i,       // 1 - обратиться к памяти
    input              lsu_we_i,        // 1 – если нужно записать в память
    input  [31:0]      lsu_data_i,      //данные для записи в память
    input  [2:0]       lsu_size_i,      // размер обрабатываемых данных
    output             lsu_stall_req_o, //бращение к памяти, сообщает ядру ждать, пока работает с памятью
    output reg [31:0]  lsu_data_o,      //данные считанные из памяти
    // memory protocol
    output reg  [3:0]  data_be_o,       //указание на необходимые байты
    output  [31:0]     data_addr_o,     // адрес, по которому идет обращение
    output reg  [31:0] data_wdata_o,    // данные, которые требуется записать
    output             data_req_o,      //обращение к памяти от лсу
    output             data_we_o,       // 1 - это запрос на запись
    input  [31:0]      data_rdata_i     //то что пришло от памяти
    
    );
    
    
   assign data_addr_o = lsu_addr_i;
   reg stall= 1'b0;
   assign lsu_stall_req_o = ~ (stall) & lsu_req_i; 
   assign data_we_o = lsu_stall_req_o & ~stall;
   assign data_req_o = lsu_stall_req_o & ~stall;

   always@(posedge clk_i)begin
        stall <= lsu_stall_req_o;
   end
 
 
 always@(*)
        begin
 
  
  //загрузка

    if(lsu_we_i)
    begin 
  
 case(lsu_size_i)
        `LDST_B:
        begin
         data_wdata_o  <= {4{lsu_data_i[7:0]}} ;
         case(lsu_addr_i[1:0])
         2'b00: data_be_o <= 4'b0001;
         2'b01: data_be_o <= 4'b0010;
         2'b10: data_be_o <= 4'b0100;
         2'b11: data_be_o <= 4'b1000;
         endcase
         end
         
        `LDST_H: begin
        data_wdata_o  <={2{lsu_data_i[15:0]}} ;
        case(lsu_addr_i[1:0])
        2'b00: data_be_o <= 4'b0011;
        2'b10: data_be_o <= 4'b1100;
        endcase
        end
        `LDST_W: begin
        data_be_o <= 4'b1111;
        data_wdata_o  <= lsu_data_i [31:0];
                  end
endcase
     end    
     else//выгрузка
     begin
case(lsu_size_i)
     
     `LDST_B:
     begin
     case (lsu_addr_i[1:0])
       2'b00:lsu_data_o <= {{24{data_rdata_i[7]}},data_rdata_i[7:0]};
       2'b01:lsu_data_o <= {{24{data_rdata_i[15]}},data_rdata_i[15:8]};
       2'b10:lsu_data_o <= {{24{data_rdata_i[23]}},data_rdata_i[23:16]};
       2'b11:lsu_data_o <= {{24{data_rdata_i[31]}},data_rdata_i[31:24]};
    endcase
    end
      `LDST_H:
      begin
        case(lsu_addr_i[1:0])
         2'b00:lsu_data_o <= {{16{data_rdata_i[15]}},data_rdata_i[15:0]};
         2'b10:lsu_data_o <= {{16{data_rdata_i[31]}},data_rdata_i[31:16]};
         endcase
         end
      `LDST_W: begin
      if (lsu_addr_i[1:0]== 2'b00)
         lsu_data_o <= data_rdata_i;
           end
      `LDST_BU:
      begin  
       case (lsu_addr_i[1:0]) 
       2'b00: lsu_data_o <= {24'b0,data_rdata_i[7:0]};  
       2'b01: lsu_data_o <= {24'b0,data_rdata_i[15:8]};  
       2'b10: lsu_data_o <= {24'b0,data_rdata_i[23:16]};  
       2'b11: lsu_data_o <= {24'b0,data_rdata_i[31:24]};
       endcase
       end
         `LDST_HU:
         begin
         case (lsu_addr_i[1:0])
         2'b00: lsu_data_o <= {16'b0,data_rdata_i[15:0]}; 
         2'b11: lsu_data_o <= {16'b0,data_rdata_i[31:16]};
         endcase
         end
endcase           
      end  
     end     
       
     endmodule
