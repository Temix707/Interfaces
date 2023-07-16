module spi_master_v1(
  input   logic       clk_i,
  input   logic       srst_i,
  input   logic [7:0] data_i,

  output  logic       done_o,
  output  logic       ss_o,

  output  logic       MOSI_o
);  

logic [3:0] count;
logic       state;

parameter   IDLE    = 2'd0;
parameter   START   = 2'd1;
parameter   FINISH  = 2'd2;
parameter   NEXT    = 2'd3;


always_ff @( posedge clk_i ) begin
  if( srst_i ) begin
    ss_o    <= 0;
    MOSI_o  <= 0;
    done_o  <= 0;
    count   <= 4'd8;               // 8
    state   <= 2'b0; 
  end
  else begin
    case( state )

      IDLE: begin
        ss_o    <= 0;
        MOSI_o  <= 0;
        done_o  <= 0;
        count   <= 4'd8;
        state   <= START;
      end

      START: begin
        ss_o    <= 1;
        count   <= data_i[count];
        
        if( count == 4'd8 ) begin
          MOSI_o  <= MOSI_o;
          state   <= FINISH;
        end
        else begin
          state <= START;
        end

      end

      FINISH: begin
        ss_o    <= 1;
        done_o  <= 1;
        state   <= NEXT;
      end

      NEXT: begin
        done_o  <= 0;
      end

    endcase
  end
end


endmodule   
