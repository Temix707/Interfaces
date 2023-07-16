module kuznechik(
    input               clk_i,      // Clock signal
                        resetn_i,   // Synchronous reset signal with active LOW level
                      
                        request_i,  // The signal of the request to start encryption
                        ack_i,      // Confirmation signal for receiving encrypted data
                            
                [127:0] data_i,     // Encrypted data ( Which will begin its encryption campaign )

  output   reg          busy_o,     // A signal indicating that reception is impossible
                                    // the next encryption request, because
                                    // module in the process of encrypting the previous request
                                    
           reg          valid_o,    // Signal of readiness of encrypted data ( termination )
           reg  [127:0] data_o      // Encrypted data
);

  reg [127:0] key_mem [0:9]; 
  
  reg [7:0] S_box_mem [0:255]; 

  reg [7:0] L_mul_16_mem  [0:255]; 
  reg [7:0] L_mul_32_mem  [0:255];
  reg [7:0] L_mul_133_mem [0:255];
  reg [7:0] L_mul_148_mem [0:255];
  reg [7:0] L_mul_192_mem [0:255];
  reg [7:0] L_mul_194_mem [0:255];
  reg [7:0] L_mul_251_mem [0:255];

  initial begin
    $readmemh("keys.mem",key_mem );
    $readmemh("S_box.mem",S_box_mem );

    $readmemh("L_16.mem", L_mul_16_mem );
    $readmemh("L_32.mem", L_mul_32_mem );
    $readmemh("L_133.mem",L_mul_133_mem);
    $readmemh("L_148.mem",L_mul_148_mem);
    $readmemh("L_192.mem",L_mul_192_mem);
    $readmemh("L_194.mem",L_mul_194_mem);
    $readmemh("L_251.mem",L_mul_251_mem);
  end
  
  typedef enum logic [3:0] { 
                     IDLE    = 0,
                     KEY_PH  = 1,
                     S_PH    = 2,
                     L_PH    = 3,
                     FINISH  = 4
                           
                   } type_enum;
   
  type_enum state, next_st;


  logic [3:0]   round;                                 
  logic [127:0] trial_input_mux;                    
  logic [127:0] data_key_result;                    

  logic [7:0]   data_key_result_bytes [15:0];            
  logic [7:0]   data_linear_result    [15:0];          

  logic [7:0]   data_galua_in         [15:0];                 

  logic [4:0]   counter;                                
  logic [7:0]   data_galua_result     [15:0];               
  logic [7:0]   galua_summ;                              

  logic [7:0]   data_galua_shifted    [15:0];              



    // State Change Block / Block for State
  always_ff @( posedge clk_i or negedge resetn_i ) begin
    if( ~resetn_i ) begin
      next_st <= IDLE;    
    end 
    else begin
      state <= next_st;
    end
  end


  always_ff @( posedge clk_i or negedge resetn_i ) begin
    if( ~resetn_i ) begin
      //state            = IDLE;
      round            = 0;
      trial_input_mux  = 0;   // data_i
      data_key_result  = 0;
      counter          = 0;
      busy_o           = 0;
      valid_o          = 0;
    end else begin
      case( state )
        IDLE: 
          begin
            if( request_i ) begin
              trial_input_mux  = data_i;
              counter          = 0;
              round            = 0;
              valid_o          = 0;
              busy_o           = 1;
              next_st          = KEY_PH;
            end
          end

        KEY_PH:
          begin
            data_key_result    = trial_input_mux  ^ key_mem[round]; 
           
            for ( int i = 0; i < 16; i++ ) begin
              data_key_result_bytes[i] = data_key_result[((i+1)*8)-1 -: 8]; 
            end
          
            if( round == 9 ) begin
              data_o           = data_key_result;
              busy_o           = 0;
              valid_o          = 1;
              next_st          = FINISH;
            end else begin
              next_st          = S_PH;
            end
          end

        S_PH: 
          begin   
            for ( int i = 0; i < 16; i++ ) begin
              data_linear_result[i] = S_box_mem[data_key_result_bytes[i]];
            end
            data_galua_in      = data_linear_result;
            next_st            = L_PH;   
          end

        L_PH: 
          begin // 148, 32, 133, 16, 194, 192, 1, 251, 1, 192, 194, 16, 133, 32, 148, 1
            if( counter < 16 ) begin
              data_galua_result[0]   = L_mul_148_mem [data_galua_in[15]];
              data_galua_result[1]   = L_mul_32_mem  [data_galua_in[14]]; 
              data_galua_result[2]   = L_mul_133_mem [data_galua_in[13]]; 
              data_galua_result[3]   = L_mul_16_mem  [data_galua_in[12]]; 
              data_galua_result[4]   = L_mul_194_mem [data_galua_in[11]]; 
              data_galua_result[5]   = L_mul_192_mem [data_galua_in[10]]; 
              data_galua_result[6]   =                data_galua_in[9]  ; 
              data_galua_result[7]   = L_mul_251_mem [data_galua_in[8]] ; 
              data_galua_result[8]   =                data_galua_in[7]  ; 
              data_galua_result[9]   = L_mul_192_mem [data_galua_in[6]] ; 
              data_galua_result[10]  = L_mul_194_mem [data_galua_in[5]] ; 
              data_galua_result[11]  = L_mul_16_mem  [data_galua_in[4]] ; 
              data_galua_result[12]  = L_mul_133_mem [data_galua_in[3]] ; 
              data_galua_result[13]  = L_mul_32_mem  [data_galua_in[2]] ; 
              data_galua_result[14]  = L_mul_148_mem [data_galua_in[1]] ; 
              data_galua_result[15]  =                data_galua_in[0]  ;
               
          
              galua_summ             ='0;

              for( int i = 0; i < 16; i++ ) begin
                galua_summ = galua_summ ^ data_galua_result[i];
              end
                 
              data_galua_shifted[15]   = galua_summ;
              data_galua_shifted[14:0] = data_galua_in [15:1];
            //data_galua_shifted <= {galua_summ, data_galua_in [15:1]};
              data_galua_in            = data_galua_shifted;
                
              counter                  = counter + 1;

            end 
            else begin
              for( int i = 0; i < 16; i++ ) begin
                trial_input_mux[( i+1 ) * 8 - 1 -: 8] = data_galua_in[i];
              end
               
              counter                  = 0;
              round                    = round + 1;
              next_st                  = KEY_PH;
            end
          end
        
        FINISH:
          begin
            if( request_i ) begin
              trial_input_mux          = data_i;
              counter                  = 0;
              round                    = 0; 
              busy_o                   = 1;
              valid_o                  = 0;
                
              next_st                  = KEY_PH;
            
            end 
            else if( ack_i ) begin
              valid_o                  = 0;
              next_st                  = IDLE;
            end
          end
      endcase
    end
end

endmodule
