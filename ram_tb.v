module ram_tb();

parameter data_size = 16;

//declares input as register, output as wire
reg clock, reset, write1_read0;
reg [data_size-1:0]data_in;
//output wire
wire [data_size-1:0]data_out;
wire [4:0]address;
wire [7:0]byte_counter;
wire [4:0]MSB_bit_display;
wire status_change;

ram #(.data_size(data_size)) ram1 (clock, reset, write1_read0, data_in, data_out, address, byte_counter, status_change);

//-------------------parameter---------------------------
reg [7:0] i, j;


initial
 begin
   reset <= 0;
   @(posedge clock);
   @(negedge clock);
   reset <= 1;
 end

//.................clock pulse generator.......................
always #1 clock = !clock;

/**************** main Block *******************************/
initial
begin
initialise();
#3 writeAndRead();
$finish;
end

/* initial
  begin
  $display("clock| WE | address | Input | Output | time");
  $monitor("%b  | %b |  %d   | %d   | %d  | %d", clock, WE, address, Input, Output, $time);
  end */



/************************* Task ************************/
task initialise;
begin
	data_in = 0;
	clock = 0;
	write1_read0 = 1;
end
endtask


task writeAndRead;
begin
  for(i = 0; i < 4; i = i + 1)
    begin
		@(posedge clock)
		if(i<2) write1_read0 = 1; //write mode
		else   write1_read0 = 0; //read mode
		for( j = 0; j < 255; j = j + 1)
		begin
			//write mode
			if(i<2) begin @(negedge clock); data_in = {i,j}; /*$display("i = %d, j = %b, j[(i+3)-:2] = %b\n", i, j, j[(i+3)-:2]);*/ end
			//read mode
			else begin @(negedge clock);  /*end*/ checking(i,j, data_out, address); end
		end
    end
end
endtask

reg [7:0]correct_row_index;
reg [15:0]expect_data;

task checking;
	input [7:0]row_index;
	input [7:0]column_index;
	input [15:0]data_input;
	input [4:0]address;
	begin
		correct_row_index = row_index-2;
		expect_data = {correct_row_index, column_index};
		if(address != correct_row_index && byte_counter != column_index)
		begin
			$display("!!! \n expect address = %d, actual address = %d \n expect byte = %d, actual byte = %d",
					address, correct_row_index, column_index, byte_counter);
		end
		else
		begin
			if(data_input != expect_data)
				$display(" -_-!!! \n expect_data = %d, actual data = %d", expect_data, data_input);
			else
				$display("^_^\n");
		end
	end
endtask

endmodule