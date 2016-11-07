module ram(clock, reset, write1_read0, data_in, data_out, data_out_by_bit);
 
	parameter data_size = 16;
	input clock, reset, write1_read0;
	input [data_size-1:0]data_in;
	output reg [data_size-1:0]data_out;
	// output reg [4095:0]data_out; no much pin
	output reg data_out_by_bit;
	

reg [4095:0]register[31:0];
reg [4095:0]temp_data;
reg [4:0]address;
reg [7:0] byte_counter; //256 (8 bit) * data (16 bit)
reg [12:0] bit_counter; //count to 4096 bits

reg [11:0]MSB_bit,LSB_bit;

always@(posedge clock or negedge reset)
begin
	if(!reset)
	begin
		temp_data <= 0;
	end
	else
	begin
		temp_data <={data_in, temp_data[4095:data_size]};
	end
end

always@(posedge clock or negedge reset)
begin
	if(!reset)
	begin
		address <= 0;
		bit_counter <= 0;
		byte_counter <= 0;
	end
	else
	begin
		if(byte_counter < 255)
		begin
			byte_counter <= byte_counter + 1;
			MSB_bit <= (byte_counter + 1) * 16 -1;
			LSB_bit <= byte_counter * 16 - 1;
		end
		else
		begin
			byte_counter <= 0;
			MSB_bit <= 15;
			LSB_bit <= 0;
		end
		
		if(!write1_read0)
		begin
			address <= 0;
			if(bit_counter < 15'd4096)
				bit_counter <= bit_counter + 1;
			else
				bit_counter <= 0;
		end
		else
		if(address < 5'd32)
			address <= address + 1;
		else
			address <= address;
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
		data_out <= {register[address][MSB_bit-:16 ]};
		// data_out_by_bit <= regi`ster[address][bit_counter];
	end
end

endmodule
