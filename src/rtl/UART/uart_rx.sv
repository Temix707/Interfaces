module uart_rx                                                                  // Computer to fpga
#(
  parameter           CLK_FREQ    = 150_000_000,                        
                      BOD_RATE    = 14400,
                      DIV_SAMPLE  = 4,                                          // increasing frequency in 4 times, to make sure that the receiver module and the transmitter module are synchronized

                      //this is the frequency we have to divide the system clock frequency to get a frequency (div_sample) time higher than the baudrate
                      DIV_COUNTER = ( CLK_FREQ / ( BOD_RATE * DIV_SAMPLE ) ),   // 2604

                      MID_SAMPLE  = ( DIV_SAMPLE / 2 ),                         // this is the middle point of a bit where you want to sample the data
                      DIV_BIT     = 10                                          // 1 start, 8 data, 1 stop
)
(
  input  logic        clk_i,                                    
  input  logic        srst_i,                                   
  input  logic        RxD_i,                                          // input signal wire, (uart_txd_in, button on keyboard)

  input  logic        ready_i,
  output logic        valid_o,        

  output logic [7:0]  RxData_o                                        // data that we receive at the receiving end, using 8 right most leds on the FPGA
);


  typedef enum logic [0:0] { 
                      IDLE = 0,
                      REC  = 1       
                   }  type_enum;
   
  type_enum state, nextstate;


  // Internal variables

  logic         shift;                                                // triggering the shifting of data  

  logic [3:0]   bit_counter;                                          // total length of the bits is 10, 1 byte of data
  logic [1:0]   sample_counter;                                       // frequency = 4 times the BodRate
  logic [13:0]  bod_rate_counter;                                     // for setting up a BodRate of 9600
  logic [9:0]   rxshift_reg;                                          // data byte (10 bits) [8:1] --> data byte                             

  //to clear and increment the bit counter and sample counter
  logic         inc_bitcounter,     clear_bitcounter;            
  logic         inc_samplecounter,  clear_samplecounter;         


  // If all bits are received and the receiver is ready, then the valid_o signal is set
  always_ff @( posedge clk_i ) begin 
    if( srst_i ) begin
      valid_o   <= 0;
    end
    else if( ready_i && ( bit_counter == DIV_BIT - 1 ) ) begin
      valid_o   <= 1;
      RxData_o  <= rxshift_reg [8:1];
    end
    else begin
      valid_o   <= 0;
    end
  end



  //UART //Receiver Logic

  always_ff @( posedge clk_i ) begin 
    if( srst_i ) begin                    
      state             <= IDLE;                                  
      bit_counter       <= 0;
      bod_rate_counter  <= 0; 
      sample_counter    <= 0; 
    end 
    else begin 
      bod_rate_counter  <= bod_rate_counter + 1; 
        
      if( bod_rate_counter >= DIV_COUNTER - 1 ) begin                 // if the counter reach the BR with sampling ( if( >= 2604-1) )   
        bod_rate_counter  <= 0;                                       // reset counter
        state             <= nextstate;                               // it should be ready to receive the data/switch to receiving state
                
        if( shift               ) begin
          rxshift_reg     <= { RxD_i, rxshift_reg[9:1] };             // if shift is asserted , then load the receiving data                
        end
                
        if( clear_samplecounter ) begin
          sample_counter  <= 0;                                   
        end

        if( inc_samplecounter   ) begin
          sample_counter  <= sample_counter + 1;                 
        end    
                 
        if( clear_bitcounter    ) begin
          bit_counter     <= 0;                            
        end
                 
        if( inc_bitcounter      ) begin
          bit_counter     <= bit_counter + 1;               
        end

      end
    end
  end


  //State Machine

  always_ff @( posedge clk_i ) begin        
    shift               <= 0;                                         // set shift to 0 to avoid any shifting, this is an idle state
    clear_samplecounter <= 0; 
    inc_samplecounter   <= 0; 
    clear_bitcounter    <= 0; 
    inc_bitcounter      <= 0; 
    nextstate           <= IDLE;                       
    
    case ( state )

      IDLE: begin
        if( RxD_i ) begin                                             // setting pin uart_txd_in
          nextstate             <= IDLE;                                // stay in the idle state, RxD needs to be low to start the transmission
        end
        else begin 
          nextstate             <= REC;                          
          clear_bitcounter      <= 1;                                   // trigger ti clear the bitcounter
          clear_samplecounter   <= 1;                                   // triggerto clear the sample counter.
        end
      end

      REC: begin 
          nextstate             <= REC;                                      
            
          if( sample_counter == MID_SAMPLE - 1 ) begin
            shift               <= 1;                                       
          end 
          else begin
            shift               <= 0;
          end

          if( sample_counter == DIV_SAMPLE - 1 ) begin                // if the sample counter us 3 as the sample rate used is 4
            if( bit_counter == DIV_BIT - 1 ) begin                    // check if the bit counter is9 or not (0-9)
              nextstate         <= IDLE;               
            end

            inc_bitcounter      <= 1;                                 // trigger the increment bit counter if bit count is not 9,
            clear_samplecounter <= 1;                                 // trigger the sample counter to reset the sample counter
          end 
          else begin 
            inc_samplecounter   <= 1;                                 // if the sample counter is not 4, or not equal to 3 (0-3)
          end

      end

      default: nextstate      <= IDLE;                         
    endcase
  end      

endmodule

