module AXI_stream_plus_tb
# (
  parameter width = 4, depth = 4
);

  //--------------------------------------------------------------------------
  // Signals to drive Device Under Test - DUT

  logic clk;
  logic rst;

  // Upstream

  logic               a_valid, b_valid;
  wire                a_ready, b_ready;
  logic [width - 1:0] a_data,  b_data;

  // Downstream

  wire                sum_valid;
  logic               sum_ready;
  wire  [width - 1:0] sum_data;

  //--------------------------------------------------------------------------
  // DUT instantiation


  AXI_stream_using_fifos
  # (.width (width), .depth (depth))
  wrapped_fifo (.*);

  //--------------------------------------------------------------------------
  // Driving clock

  initial
  begin
    clk = '1;
    forever #5 clk = ~ clk;
  end

  //--------------------------------------------------------------------------
  // Logging

  int unsigned cycle = 0;

  always @ (posedge clk)
  begin
    $write ("time %7d cycle %5d", $time, cycle ++);

    if ( rst       ) $write ( " rst"       ); else $write ( "    "       );

    if ( a_valid   ) $write ( " a_valid"   ); else $write ( "        "   );
    if ( a_ready   ) $write ( " a_ready"   ); else $write ( "        "   );

    if (a_valid & a_ready)
      $write (" %h", a_data);
    else
      $write ("  ");

    if ( b_valid   ) $write ( " b_valid"   ); else $write ( "        "   );
    if ( b_ready   ) $write ( " b_ready"   ); else $write ( "        "   );

    if (b_valid & b_ready)
      $write (" %h", b_data);
    else
      $write ("  ");

    if ( sum_valid ) $write ( " sum_valid" ); else $write ( "          " );
    if ( sum_ready ) $write ( " sum_ready" ); else $write ( "          " );

    if (sum_valid & sum_ready)
      $write (" %h", sum_data);
    else
      $write ("  ");

    $display;
  end

  //--------------------------------------------------------------------------
  // Modeling and checking

  logic [width - 1:0] a_queue [$], b_queue [$];
  logic [width - 1:0] sum_data_expected;

  logic was_reset = 0;

  always @ (posedge clk)
  begin
    if (rst)
    begin
      a_queue = {};
      b_queue = {};

      was_reset = 1;
    end
    else if (was_reset)
    begin
      if (a_valid & a_ready)
        a_queue.push_back (a_data);

      if (b_valid & b_ready)
        b_queue.push_back (b_data);

      if (sum_valid & sum_ready)
      begin
        if (a_queue.size () == 0 || b_queue.size () == 0)
        begin
          $display ("ERROR: unexpected sum %h", sum_data);
        end
        else
        begin
          `ifdef __ICARUS__
            // Some version of Icarus has a bug, and this is a workaround
            sum_data_expected = a_queue [0] + b_queue [0];

            a_queue.delete (0);
            b_queue.delete (0);
          `else
            sum_data_expected = a_queue.pop_front () + b_queue.pop_front ();
          `endif

          if (sum_data_expected != sum_data)
            $display ("ERROR: downstream data mismatch. Expected %h, actual %h",
              sum_data_expected, sum_data);
        end
      end
    end
  end

  //--------------------------------------------------------------------------
  // Check at the end of simulation

  final
  begin
    if (a_queue.size () != 0)
    begin
      $write ("ERROR: data is left sitting in the model a_queue:");

      for (int i = 0; i < a_queue.size (); i ++)
        $write (" %h", a_queue [a_queue.size () - i - 1]);

      $display;
    end

    if (b_queue.size () != 0)
    begin
      $write ("ERROR: data is left sitting in the model b_queue:");

      for (int i = 0; i < b_queue.size (); i ++)
        $write (" %h", b_queue [b_queue.size () - i - 1]);

      $display;
    end
  end

  //--------------------------------------------------------------------------
  // Driving reset and control signals

  initial
  begin
    `ifdef __ICARUS__
      $dumpvars;
    `endif

    //------------------------------------------------------------------------
    // Initialization

    a_valid   <= 1'b0;
    b_valid   <= 1'b0;
    sum_ready <= 1'b0;

    //------------------------------------------------------------------------
    // Reset

    repeat (3) @ (posedge clk);
    rst <= '1;
    repeat (3) @ (posedge clk);
    rst <= '0;

    //------------------------------------------------------------------------

    $display ("*** Run back-to-back");

    a_valid   <= 1'b1;
    b_valid   <= 1'b1;
    sum_ready <= 1'b1;

    repeat (20) @ (posedge clk);

    $display ("*** Supplying only \"a\"");

    a_valid   <= 1'b1;
    b_valid   <= 1'b0;
    sum_ready <= 1'b1;

    repeat (20) @ (posedge clk);

    $display ("*** Supplying only \"b\"");

    a_valid   <= 1'b0;
    b_valid   <= 1'b1;
    sum_ready <= 1'b1;

    repeat (20) @ (posedge clk);

    $display ("*** Applying backpressure");

    a_valid   <= 1'b1;
    b_valid   <= 1'b1;
    sum_ready <= 1'b0;

    repeat (20) @ (posedge clk);

    $display ("*** Draining the results");

    a_valid   <= 1'b0;
    b_valid   <= 1'b0;
    sum_ready <= 1'b1;

    repeat (20) @ (posedge clk);

    $display ("*** Random");

    repeat (50)
    begin
      a_valid   <= $urandom ();
      b_valid   <= $urandom ();
      sum_ready <= $urandom ();

      @ (posedge clk);
    end

    $display ("*** Draining the results - this can be skipped during a tutorial");

    // Draining all the pairs of "a" and "b" from their FIFOs and "sum" FIFO

    a_valid   <= 1'b0;
    b_valid   <= 1'b0;
    sum_ready <= 1'b1;

    repeat (depth * 2 + 3) @ (posedge clk);

    // Draining the disbalance on "a" FIFO

    repeat (a_queue.size ())
    begin
      b_valid <= 1'b1;
      @ (posedge clk);
    end

    b_valid <= 1'b0;

    // Draining the disbalance on "b" FIFO

    repeat (b_queue.size ())
    begin
      a_valid <= 1'b1;
      @ (posedge clk);
    end

    // Draining whatever is left in all three FIFOs

    a_valid <= 1'b0;

    repeat (3) @ (posedge clk);

    //------------------------------------------------------------------------

    `ifdef MODEL_TECH  // Mentor ModelSim and Questa
      $stop;
    `else
      $finish;
    `endif
  end

  //--------------------------------------------------------------------------
  // Driving data

  always @ (posedge clk)
    if (rst | (a_valid & a_ready))
      a_data <= $urandom;

  always @ (posedge clk)
    if (rst | (b_valid & b_ready))
      b_data <= $urandom;

endmodule
