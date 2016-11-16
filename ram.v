module ram(clock, reset, write1_read0, data_in, data_out_display, address_display, byte_counter_display, status_change);

parameter data_size = 16;
input clock, reset, write1_read0;
input [data_size-1:0]data_in;
output wire [data_size-1:0]data_out_display;
// output reg [4095:0]data_out; no much pin
// output reg data_out_by_bit;
output wire[4:0]address_display;
output wire[7:0]byte_counter_display;
output wire status_change;

reg [data_size-1:0]data_out;
reg [4095:0]register[31:0];
reg [4095:0]temp_data;
reg [7:0] byte_counter; //256 (8 bit) * data (16 bit)
reg [12:0] bit_counter; //count to 4096 bits
reg [4:0]address; // address_for_bit;

wire current_WR_status, last_WR_status;
wire change_WR_status_found;

/************************** wiring output ***************/
assign data_out_display = data_out;

/****** taped out signals for checking purpose **************/
assign status_change = change_WR_status_found;
assign address_display = address;
assign byte_counter_display = byte_counter;

/****** checking read write values *****************/
assign current_WR_status = write1_read0;
assign last_WR_status = current_WR_status;
assign change_WR_status_found = current_WR_status ^ last_WR_status;

/********************* program start here **********************/
always@(posedge clock or negedge reset)
begin
	if(!reset)
	begin
		temp_data <= 0;
	end
	else
	begin
		temp_data <={data_in[data_size-1:0], temp_data[4095:data_size]};
	end
end


/********** control of increment of address, byte_counter, bit_counter *********/
always@(posedge clock or negedge reset or posedge change_WR_status_found)
begin
	if(!reset | change_WR_status_found)
	begin
		address <= 0;
//		address_for_bit <= 0;
		bit_counter <= 0;
		byte_counter <= 0;

	end
	else
	begin
		if(byte_counter < 255)
		begin
			byte_counter <= byte_counter + 1;
			address <= address;
		end
		else
		begin
			address <= address + 1;
			byte_counter <= 0;
		end

//		if(bit_counter < 15'd4096)
//		begin
//			bit_counter <= bit_counter + 1;
//			address_for_bit <= address_for_bit;
//		end
//		else
//		begin
//			bit_counter <= 0;
//			address_for_bit <= address_for_bit + 1;
//		end

	end
end


always@(posedge clock)
begin
	if(write1_read0) //write
	begin
		register[address] <= temp_data;
	end
	else	//read
	begin
		data_out <= {register[address][((byte_counter + 1) * 16 -1)-:16]};
//		data_out_by_bit <= register[address_for_bit][bit_counter];
	end
end

endmodule
