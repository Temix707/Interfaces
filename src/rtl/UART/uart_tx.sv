module uart_tx                                          // FPGA to comp
#(
  parameter     [13:0]  COUNT_NUM = 14'd10415,
  parameter             TRESHHOLD = 1_000_000           // [20]                                                                                   
)
(
  input   logic         clk_i,
  input   logic         srst_i,
  input   logic [7:0]   data_i,
  input   logic         tr_but_i,

  input   logic         valid_i,
  output  logic         ready_o,

  output  logic         TxD_o                           // output signal reg, (uart_rxd_out, outgoing characters in the terminal)
);


  // SIGNAL DELIVERY 

  logic         tr_signal_o         ;
  logic         button_ff1       = 0;                   // button FF for synchronization, initially set to 0
  logic         button_ff2       = 0;                   // button FF for synchronization, initially set to 0

  logic [30:0]  count            = 0;                   // 20 bitsc count for increment and decrement when button is pressed or released
  logic [30:0]  count_get        = 0;
  logic         count_get_clear  = 0;


  // First use two FF to synchronize the button signal, clk
  always_ff @( posedge clk_i ) begin
    button_ff1  <= tr_but_i;
    button_ff2  <= button_ff1; 
  end


  // When push button is pressed or relased, increment or decrement the counter
  always_ff @( posedge clk_i ) begin
    if( button_ff2 ) begin
      if( ~&count ) begin                               // if it isnt at the cout limit, make sure you wont cout up at the limit. First AND all count and then not the AND
        count           <= count + 1;                   // when btn is pressed, count up 
      end
    end
    else begin
      if( |count ) begin                                // if count has at least 1 is it, making sure no subtract when count is 0  
        count           <= count - 1;                   // when btn is released, count down
        count_get       <= 0;
      end
    end

    // 1 click - 1 simbol
    if( count > TRESHHOLD ) begin     
      tr_signal_o       <= 1;
      count_get         <= count_get + 1;

      if( ( count_get > COUNT_NUM ) && ( button_ff2 ) ) begin
        tr_signal_o     <= 0;
        count           <= 0;
      end
      else begin
        tr_signal_o     <= 1;
        count           <= count + 1;
      end

    end
    else begin
      tr_signal_o       <= 0;                
    end
  end



  // UART TRANSMISSION

  logic         tr_but_w = tr_signal_o;

  logic [3:0]   bit_counter;                            // counter to coutn the 10 bit                                                    
  logic [13:0]  bod_rate_counter;                       // Rate, counter = clock / Bod rate = 150MHz / 14400 = 10416            
  logic [9:0]   shift_right_reg;                        // 10 bits that will be serially transmitted through UART to the FPGA

  
  logic         shift;                                  // shift signal to start shifting the bits in the UART
  logic         load;                                   // load signal to start loading the into the shiftright register, and add start and stop bits  
  logic         clear;                                  // reset the bit_counter for UART transmittion


  typedef enum logic [0:0] { 
                IDLE   = 0,
                TRANS  = 1       
  } type_enum;
   
  type_enum     state, next_state;


  // If the transmitter is not busy, then the ready_o signal is set
  always_ff @( posedge clk_i ) begin 
    if( srst_i ) begin
      ready_o   <= 0;
    end
    else if ( ~valid_i && ( bit_counter != 10 ) ) begin
      ready_o   <= 1;
    end
    else begin
      ready_o   <= 0;
    end 
  end



  always_ff @( posedge clk_i ) begin
    if( srst_i ) begin
      state               <= IDLE;                    
      bit_counter         <= 0;                       
      bod_rate_counter    <= 0;

    end else begin
      bod_rate_counter    <= bod_rate_counter + 1;

      if( bod_rate_counter == COUNT_NUM ) begin         // reaches 10415 and then resets
        state             <= next_state;                // state changes from idle to transmitting 
        bod_rate_counter  <= 0;                         // reset counter  

        if( load ) begin                          
          shift_right_reg <= { 1'b1, data_i, 1'b0 };    // the data is loaded into the register, 10 bits                                 
        end

        if( shift ) begin                           
          shift_right_reg <= shift_right_reg >> 1;      // start shifting the data and transmitting bit by bit
          bit_counter     <= bit_counter + 1;           // counts to 10, because assert all 10 bits have been transmitted
        end

        if( clear ) begin                       
          bit_counter     <= 0;
        end
      end 
    end
  end



  // STATES

  always_ff @( posedge clk_i ) begin
    load    <= 0;                   
    shift   <= 0; 
    clear   <= 0;

    TxD_o   <= 1;                                       // when set to 1, there is NO transmission in progress       

    case( state ) 
      IDLE: begin 
        if( tr_but_w ) begin                            // transmit button is pressed   
          next_state  <= TRANS;                         // moves / switches to transmission state
          load        <= 1;                             // start loading the bits
          shift       <= 0;                             // no shift at this moment
          clear       <= 0;                             // to avoid any clearing of any counter
        end
        else begin                                      // if transmit button is NOT pressed
          next_state  <= IDLE;                          // stays at the idle mode (mode waiting)
          TxD_o       <= 1;                             // no transmittion
        end
      end


      TRANS: begin    
        if( bit_counter == 10 ) begin
          next_state  <= IDLE;                          // it should switch from transmitton mode to idle mode, when 10 bits were transmitted
          clear       <= 1;                             // clear all the counter 
        end
        else begin 
          next_state  <= TRANS;                      
          shift       <= 1;                             // continue shifting the data, new bit arrives at the RMB
          TxD_o       <= shift_right_reg[0];
        end
      end

      default: next_state <= IDLE;

    endcase
  end 


endmodule