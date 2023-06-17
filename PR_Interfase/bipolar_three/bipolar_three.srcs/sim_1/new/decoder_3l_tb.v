`timescale 1ns / 1ps

module decoder_3l_tb();
    reg     clk_tb;
    reg     pos_volt_tb;
    reg     n_volt_tb;
    reg     neg_volt_tb;
    wire    out_num_tb;
    wire    out_accuracy_tb;

decoder_3l dut(
        .clk_d        (clk_tb),
        .out_num_d    (out_num_tb),
        .pos_volt_d   (pos_volt_tb),
        .n_volt_d     (n_volt_tb),
        .neg_volt_d   (neg_volt_tb),
        .out_accuracy_d   (out_accuracy_tb)
      //.Сигналы внешнего мод-ля(Сигналы внутреннего мод-ля)
    );


    initial
        forever
            #10 clk_tb = ~clk_tb;
    
    initial begin
        clk_tb = 1;
        pos_volt_tb = 0;
        n_volt_tb = 1;
        neg_volt_tb = 0; 
        
        #100 n_volt_tb = 0;
        pos_volt_tb = 1;
        #20 //pos_volt_tb = 0;
        n_volt_tb = 1;
        #20 n_volt_tb = 0;
        pos_volt_tb = 1;
        #20 pos_volt_tb = 0;
        n_volt_tb = 1;
        #140 n_volt_tb = 0;
        pos_volt_tb = 1;
        #20 pos_volt_tb = 0;
        n_volt_tb = 1;
        #40 n_volt_tb = 0;
        neg_volt_tb = 1;
        n_volt_tb = 1;
        #40 neg_volt_tb = 0;         
       
        #10;
       
        $finish;
    end
endmodule
