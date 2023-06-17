
module fifo_dp_ram
  #(
    parameter ADR = 3, BIT_D = 32, NUM_REG = 6
  )(
  input                    clk_i,
  input                    srst_i,
  input                    rd_i,
  input                    wr_i,
  input       [BIT_D-1:0]  data_i,
    
  output  reg [BIT_D-1:0]  data_o,
  output  reg [2:0]        fifo_cnt_o,
  output                   wr_full_o,
  output                   rd_empty_o
);
    
  reg [BIT_D-1:0] fifo_ram [0:NUM_REG-1]; 
  reg [ADR-1:0]   rd_ptr, wr_ptr;
    
  assign wr_full_o  = ( fifo_cnt_o == NUM_REG ); 
  assign rd_empty_o = ( fifo_cnt_o == 0 );


  // Write and Read block
  // Write
  always @( posedge clk_i ) begin
    if( wr_i && !wr_full_o ) begin
      fifo_ram[wr_ptr] <= data_i;
    end 
    else if( wr_i && rd_i ) begin
      fifo_ram[wr_ptr] <= data_i;
    end
  end


  // Read
  always @( posedge clk_i ) begin
    if( rd_i && !rd_empty_o ) begin
      data_o <= fifo_ram[rd_ptr];
    end 
    else if( rd_i && wr_i ) begin
      data_o <= fifo_ram[rd_ptr];
    end
  end


  // Pointer block
  always @( posedge clk_i ) begin
    if( srst_i ) begin
      fifo_cnt_o  <= 3'd0;
      wr_ptr      <= 3'd0;
      rd_ptr      <= 3'd0;
    end else begin
      wr_ptr <= ( ( wr_i && !wr_full_o  )||( wr_i && rd_i ) ) ? ( wr_ptr + 1 ) : ( wr_ptr );
      rd_ptr <= ( ( rd_i && !rd_empty_o )||( wr_i && rd_i ) ) ? ( rd_ptr + 1 ) : ( rd_ptr );
    end
  end
    
    
  // Counter
  always @( posedge clk_i ) begin
    if( srst_i ) begin
      fifo_cnt_o <= 3'd0;
    end 
    else begin
      case( {wr_i,rd_i} )
        2'b00  : fifo_cnt_o   <=   fifo_cnt_o;
        2'b01  : fifo_cnt_o   <= ( fifo_cnt_o == 0 ) ? ( 0 ) : ( fifo_cnt_o - 1 );              
        2'b10  : fifo_cnt_o   <= ( fifo_cnt_o == NUM_REG ) ? ( NUM_REG ) : ( fifo_cnt_o + 1 );   
        2'b11  : fifo_cnt_o   <=   fifo_cnt_o;                                                    
        default: fifo_cnt_o   <=   fifo_cnt_o;
      endcase
    end
  end
    
endmodule












