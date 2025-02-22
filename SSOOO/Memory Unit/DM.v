
`define MEMORY_SIZE 4096
`define MEMORY_BITS 12
`define ROB_SIZE_bits (4)
`define BUFFER_SIZE_bitslsbuffer (4)
`define BUFFER_SIZE_bitsRS (4)
`define ROB_SIZE ((1 << `ROB_SIZE_bits))


module DM
(
    input clk, 
    input [`ROB_SIZE_bits:0] ROBEN,
    input Read_en, Write_en,
    input [31:0] LdStB_MEMU_ROBEN1_VAL,
    input [31:0] LdStB_MEMU_Immediate,
    input [31 : 0] address,
    input [31 : 0] data,
    output reg MEMU_invalid_address,
    output reg [`ROB_SIZE_bits:0] MEMU_ROBEN,
`ifdef vscode
    output reg [31:0] MEMU_Result
`else
    output [31:0] MEMU_Result
    `ifdef VGA
        ,input [10:0] VGA_address,
        input VGA_clk,
        output [31:0] VGA_data
    `endif
`endif
);


integer i;

`ifdef vscode

    reg [31 : 0] DataMem [0 : (`MEMORY_SIZE-1)];
    always @(negedge clk) begin
        if (~MEMU_invalid_address) begin
            if (Read_en) begin
                MEMU_Result <= DataMem[address[(`MEMORY_BITS-1):0]];
            end
            if (Write_en) begin
                DataMem[address[(`MEMORY_BITS-1):0]] <= data;
            end
        end
        MEMU_ROBEN <= ROBEN;
    end
    initial begin
    for (i = 0; i <= (`MEMORY_SIZE-1); i = i + 1)
        DataMem[i] <= 0;

    `ifdef test
            `include "./Memory Unit/DM_INIT.INIT"
    `else
            `include "DM_INIT.INIT"
    `endif 
    end

`else
    always@(negedge clk) begin
        MEMU_ROBEN <= ROBEN;
    end
    `ifdef VGA
        DataMemory_IP2PORT DataMemory
        (
            .address_a(address[10:0]),
            .address_b(VGA_address),
            .clock_a(~clk),
            .clock_b(VGA_clk),
            .data_a(data),
            .data_b(32'd0),
            .wren_a(Write_en),
            .wren_b(1'b0),
            .q_a(MEMU_Result),
            .q_b(VGA_data)
        );
    `else
        DataMemory_IP DataMemory
        (
            address[(`MEMORY_BITS-1):0],
            ~clk,
            data,
            Write_en,
            MEMU_Result
        );
    `endif
`endif

always@(posedge clk) begin
    MEMU_invalid_address <= (LdStB_MEMU_ROBEN1_VAL + LdStB_MEMU_Immediate) > (`MEMORY_SIZE-1);
end




`ifdef vscode
    initial begin
        #(`MAX_CLOCKS + `reset);
        // iterating through some of the addresses of the memory to check if the program loaded and stored the values properly
        $display("Data Memory Content : ");
        for (i = 0; i <= (`MEMORY_SIZE-1); i = i + 1)
            $display("Mem[%d] = %d",i[(`MEMORY_BITS-1):0],$signed(DataMem[i]));
    end 
`endif
endmodule
