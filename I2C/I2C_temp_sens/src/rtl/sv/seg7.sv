module seg7(
    input  logic       clk_100MHz_i,          // Nexys A7 clock
    input  logic [7:0] temp_data_i,           // Temp data from i2c master
    
    output logic [6:0] SEG_o,                 // 7 Segments of Displays
    output logic [3:0] NAN_o = 4'hF,          // 4 Anodes of 8 turned OFF
    output logic [3:0] AN_o                   // 4 Anodes of 8 to display Temp
);
    
    // Binary to BCD conversion of temperature data
    logic [3:0] tens, ones;
    assign tens = temp_data_i / 10;           // Tens value of temp data
    assign ones = temp_data_i % 10;           // Ones value of temp data
    
    // Parameters for segment patterns
    parameter ZERO  = 7'b000_0001;            // 0
    parameter ONE   = 7'b100_1111;            // 1
    parameter TWO   = 7'b001_0010;            // 2 
    parameter THREE = 7'b000_0110;            // 3
    parameter FOUR  = 7'b100_1100;            // 4
    parameter FIVE  = 7'b010_0100;            // 5
    parameter SIX   = 7'b010_0000;            // 6
    parameter SEVEN = 7'b000_1111;            // 7
    parameter EIGHT = 7'b000_0000;            // 8
    parameter NINE  = 7'b000_0100;            // 9
    parameter DEG   = 7'b001_1100;            // degrees symbol
    parameter C     = 7'b011_0001;            // C
    
    // To select each digit in turn
    logic [1:0]  anode_select;                // 2 bit counter for selecting each of 4 digits
    logic [16:0] anode_timer;                 // counter for digit refresh
    
    // Logic for controlling digit select and digit timer
    always_ff @( posedge clk_100MHz_i ) begin
      // 1ms x 4 displays = 4ms refresh period
      if( anode_timer == 99_999 ) begin       // The period of 100MHz clock is 10ns (1/100,000,000 seconds)
        anode_timer  <= 0;                    // 10ns x 100,000 = 1ms
        anode_select <=  anode_select + 1;
      end
      else
        anode_timer  <=  anode_timer + 1;
    end
    
    // Logic for driving the 4 bit anode output based on digit select
    always_ff @( anode_select ) begin
      case( anode_select ) 
        2'b00 : AN_o = 4'b1110;               // Turn on ones digit
        2'b01 : AN_o = 4'b1101;               // Turn on tens digit
        2'b10 : AN_o = 4'b1011;               // Turn on hundreds digit
        2'b11 : AN_o = 4'b0111;               // Turn on thousands digit
      endcase
    end
    
    always @( * )
        case( anode_select )
            2'b00 : SEG_o = C;                // Set to C for Celsuis
                        
            2'b01 : SEG_o = DEG;              // Set to degrees symbol
                    
            2'b10 : begin                     // TEMPERATURE ONES DIGIT
                        case( ones )
                            4'b0000 : SEG_o = ZERO;
                            4'b0001 : SEG_o = ONE;
                            4'b0010 : SEG_o = TWO;
                            4'b0011 : SEG_o = THREE;
                            4'b0100 : SEG_o = FOUR;
                            4'b0101 : SEG_o = FIVE;
                            4'b0110 : SEG_o = SIX;
                            4'b0111 : SEG_o = SEVEN;
                            4'b1000 : SEG_o = EIGHT;
                            4'b1001 : SEG_o = NINE;
                        endcase
                    end
                    
            2'b11 : begin                     // TEMPERATURE TENS DIGIT
                        case( tens )
                            4'b0000 : SEG_o = ZERO;
                            4'b0001 : SEG_o = ONE;
                            4'b0010 : SEG_o = TWO;
                            4'b0011 : SEG_o = THREE;
                            4'b0100 : SEG_o = FOUR;
                            4'b0101 : SEG_o = FIVE;
                            4'b0110 : SEG_o = SIX;
                            4'b0111 : SEG_o = SEVEN;
                            4'b1000 : SEG_o = EIGHT;
                            4'b1001 : SEG_o = NINE;
                        endcase
                    end
        endcase
    
endmodule
