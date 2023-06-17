module top_bip_3l(
    input        clk,
    //input        reset,
    input inp_num,
    //output  reg out_num,
    output  reg pos_volt, n_volt, neg_volt
);
    reg [4:0] parity_cout;
    
    initial begin  
        //out_num = 0;
        pos_volt = 0;
        n_volt = 0;
        neg_volt = 0;
        parity_cout = 0;   
    end
    
    
    always @(posedge clk) begin
            if(inp_num) begin
                n_volt <= 1'b1;
                pos_volt <=  1'b0;
                neg_volt <=  1'b0;
                parity_cout <= parity_cout + 1;
            end else begin
                if(parity_cout % 2 == 0) begin
                    n_volt <= 1'b0;
                    pos_volt <=  1'b0;
                    neg_volt <=  1'b1;
                    if (neg_volt) begin
                        parity_cout <= parity_cout;
                    end else begin
                        parity_cout <= 0;
                    end
                        
                end else begin
                    n_volt <= 1'b0;
                    pos_volt <=  1'b1;
                    neg_volt <=  1'b0;
                    if (pos_volt) begin
                        parity_cout <= parity_cout;
                    end else begin
                        parity_cout <= 0;
                    end
                end
            end
        //out_num <= inp_num;
    end

endmodule
