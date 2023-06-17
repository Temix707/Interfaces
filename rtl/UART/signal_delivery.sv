module signal_delivery
# (
  parameter     TRESHHOLD = 1_000_000     // [20] 
)
(
  input   logic clk_i,
  input   logic btn_i,

  output  logic tr_signal_o
);


  logic         button_ff1        = 0;            // button FF for synchronization, initially set to 0
  logic         button_ff2        = 0;            // button FF for synchronization, initially set to 0

  logic [30:0]  count             = 0;            // 20 bitsc count for increment and decrement when button is pressed or released
  logic [30:0]  count_get         = 0;
  logic         count_get_clear   = 0;

   
  // First use two FF to synchronize the button signal, clk
  always_ff @( posedge clk_i ) begin
    button_ff1  <= btn_i;
    button_ff2  <= button_ff1; 
  end


  // When push button is pressed or relased, increment or decrement the counter
  always_ff @( posedge clk_i ) begin
    if( button_ff2 ) begin
      if( ~&count ) begin                         // if it isnt at the cout limit, make sure you wont cout up at the limit. First AND all count and then not the AND
        count           <= count + 1;             // when btn is pressed, count up 
      end
    end
    else begin
      if( |count ) begin                          // if count has at least 1 is it, making sure no subtract when count is 0  
        count           <= count - 1;             // when btn is released, count down
        count_get       <= 0;
      end
    end

    // 1 click - 1 simbol
    if( count > TRESHHOLD ) begin     
      tr_signal_o       <= 1;
      count_get         <= count_get + 1;
      if( ( count_get > 10416 ) && ( button_ff2 ) ) begin
        tr_signal_o     <= 0;
        count           <= 0;
      end
      else begin
        tr_signal_o     <= 1;
        count           <= count + 1;
      end
    end
    else begin
      tr_signal_o <= 0;                
    end
  end
  
endmodule
