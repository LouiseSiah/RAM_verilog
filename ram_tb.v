module ram_tb();

ram #.(data_size(16)) ram1 (clock, reset, write1_read0, data_in, data_out, data_out_by_bit);
	reg clock, WE;
	reg [4:0]address;
	reg [7:0]Input;

//output wire
	wire [7:0]Output;
  
//temp storage
  // reg [memorySize - 1:0] location; 
  integer i, j;
  
ram ram1 (clock, WE, address, Input, Output);

// initial 
 // begin 
   // reset <= 0;
   // @(posedge clock);
   // @(negedge clock);
   // reset <= 1;
 // end 

initial
  begin
  clock = 0;
  forever #1 clock = ~clock;
  end

initial 
  begin 
  #2 writeAndRead();
  // for( location = 0; location < 32; location = location + 1)
    // begin
    // @(negedge clock); Input = 0; WE = 0; address = location;
    // end
  end

initial 
  begin 
  $display("clock| WE | address | Input | Output | time");
  $monitor("%b  | %b |  %d   | %d   | %d  | %d", clock, WE, address, Input, Output, $time);
  end

  
  
//*************************

task writeAndRead;
begin
 
  for(i = 0; i < 2; i = i + 1)
    begin
    @(posedge clock)
    if(!i) WE = 1;
    else   WE = 0;
    for( j = 0; j < 32; j = j + 1)
      begin
       if(!i) begin @(negedge clock); address = j; Input = j + 1; end
       else begin @(negedge clock); address = j; Input = j + 4; end
      end
    end
end
endtask

// task read;
// // input [4:0] addressR;

// begin
 
    // begin
      // #2 address = location; 
    // end
// end
// endtask

endmodule