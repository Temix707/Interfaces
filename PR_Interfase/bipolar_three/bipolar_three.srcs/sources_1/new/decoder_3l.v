module decoder_3l(
    input clk_d,
    input inp_num_d,
    input pos_volt_d, n_volt_d, neg_volt_d,
    output reg out_num_d,
    output reg out_accuracy_d
    );
    
    reg [4:0] parity_cout_d;
     
    initial begin
        parity_cout_d [4:0] = 0;
    end
    
    always @(posedge clk_d) begin
      
        if ((n_volt_d && neg_volt_d) || (n_volt_d && pos_volt_d) || (neg_volt_d && pos_volt_d)) begin
            out_accuracy_d <= 1'b1;
            //out_num_d <= 1'bx;
            
        end else if(n_volt_d) begin
            out_num_d <= 1'b1; 
            parity_cout_d <= parity_cout_d + 1;
            out_accuracy_d <= 1'b0;
                
        end else if (parity_cout_d % 2 == 0) begin
            out_num_d <= 1'b0;
            if (neg_volt_d) begin
                parity_cout_d <= parity_cout_d;
                out_accuracy_d <= 1'b0;
            end else begin
                parity_cout_d <= 0;
                out_accuracy_d <= 1'b0;
            end
                
        end else if (parity_cout_d % 2 == 1) begin
            out_num_d <= 1'b0;
            if (neg_volt_d) begin
                parity_cout_d <= parity_cout_d;
                out_accuracy_d <= 1'b0;
            end else begin
                parity_cout_d <= 0;
                out_accuracy_d <= 1'b0;
            end
        end
    end
endmodule
