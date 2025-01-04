module test();


parameter param = 20;
// desired syntax, to make it easier to modify
// reg [param * 8 - 1 : 0] word = "hallah wallah"; 
reg [0 : param * 8 - 1] word = "hallah wallah"; 
// approaches:
//		- function that indexes the input every 8-bit through a for loop
integer j;
// reg [7:0] data [param - 1'b1 : 0];
reg [7:0] data [0 : param - 1'b1];
reg [10:0] offset = 0;
initial begin
	for (j = 0; j < param; j = j + 1) begin
		// data[j] <= word[8*(param -1-j) +: 8];
		data[j] <= word[8*(j) +: 8];
	end

    #11;

    for (j = 0; j < param; j = j + 1) begin
        if (data[j] == 0)
            offset = offset + 1;
    end
    $display("offset = %d", offset);

    #11;

	for (j = 0; j < param; j = j + 1) begin
        $display("char = %c, data = %b", data[j+offset], data[j+offset]);
	end

end


endmodule