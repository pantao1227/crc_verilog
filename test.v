`timescale 1ns/1ps

module Test();

reg clk;
reg rst_n;
wire [1:0] check_status;

parameter INVALID = 2'b00;
parameter RUNNING = 2'b01;
parameter PASSED = 2'b10;
parameter FAILED = 2'b11;

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, Test);
    clk = 0;
    forever begin
        #50 clk = ~clk;
    end
end

initial begin
    rst_n = 0;
    #220 rst_n = 1;

    #2000 $finish;
end

crc32_check uut(
    .clk(clk),
    .rst_n(rst_n),
    .check_status(check_status)
);

endmodule

module crc32_check(
    input wire clk,
    input wire rst_n,
    output reg [1:0] check_status
);
parameter INVALID = 2'b00;
parameter RUNNING = 2'b01;
parameter PASSED = 2'b10;
parameter FAILED = 2'b11;

reg [31:0] data [0:7];

reg data_in_valid;
reg [31:0] data_in;
wire [31:0] next_crc32;

integer i;

initial begin
    $readmemh("data.txt", data);
    for(i=0; i<=7; i=i+1) begin
        $display("data[%1d] = 0x%08x", i, data[i]);
    end
end

always @ (posedge clk) begin
    if(!rst_n) begin
        check_status <= INVALID;
        data_in_valid <= 1'b0;
        i <= 0;
    end
    else if(i<8) begin
        check_status <= RUNNING;
        data_in_valid <= 1'b1;
        data_in <= data[i];
        i <= i + 1;
    end
    else begin
        data_in_valid <= 1'b0;
        check_status <= (next_crc32==32'd0)?(PASSED):(FAILED);
    end
end

crc32_32 uut(
        .clk(clk),
        .rst_n(rst_n),
        .data_in_valid(data_in_valid),
        .data_in(data_in),
        .next_crc32(next_crc32)
);


endmodule
// module Test();
//     reg clk;
//     reg rst_n;
//     reg data_in_valid;
//     reg [31:0] data_in;
//     wire [31:0] next_crc32;

//     reg [31:0] data [0:7];

//     integer i;

//     initial begin
//         $readmemh("data.txt", data);
//         for(i=0; i<=7; i=i+1) begin
//             $display("data[%1d] = 0x%08x", i, data[i]);
//         end
//         $dumpfile("wave.vcd");
//         $dumpvars(0, Test);
//         clk = 0;
//         forever begin
//             #5 clk = ~clk;
//         end
//     end

//     initial begin
//         rst_n = 1'b0;
//         data_in_valid = 1'b0;
//         #20;
//         rst_n = 1'b1;
//         for(i=0; i<=7; i=i+1) begin
//             data_in = data[i];
//             data_in_valid = 1'b1;
//             #5 $display("next_crc32 = 0x%08x", next_crc32);
//             #5;
//         end
//         data_in_valid = 1'b0;
//         #10 $finish;
//     end

//     crc32_32 uut(
//         .clk(clk),
//         .rst_n(rst_n),
//         .data_in_valid(data_in_valid),
//         .data_in(data_in),
//         .next_crc32(next_crc32)
//     );
// endmodule

module crc32_32 (
    input wire clk,
    input wire rst_n,
    input wire data_in_valid,
    input wire [31:0] data_in,
    output reg [31:0] next_crc32
);

wire [31:0] d;
wire [31:0] c;

assign d = data_in;
assign c = next_crc32;

always @(posedge clk) begin
    if(!rst_n) begin
        next_crc32 = 32'hffffffff;
    end
    else if(data_in_valid) begin
        next_crc32[ 0] <=   d[31] ^ d[30] ^ d[29] ^ d[28] ^ d[26] ^ d[25] ^ d[24] ^ d[16] ^ d[12] ^ d[10] ^ 
                            d[ 9] ^ d[ 6] ^ d[ 0] ^ c[ 0] ^ c[ 6] ^ c[ 9] ^ c[10] ^ c[12] ^ c[16] ^ c[24] ^ 
                            c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30] ^ c[31];

        next_crc32[ 1] <=   d[28] ^ d[27] ^ d[24] ^ d[17] ^ d[16] ^ d[13] ^ d[12] ^ d[11] ^ d[ 9] ^ d[ 7] ^ 
                            d[ 6] ^ d[ 1] ^ d[ 0] ^ c[ 0] ^ c[ 1] ^ c[ 6] ^ c[ 7] ^ c[ 9] ^ c[11] ^ c[12] ^ 
                            c[13] ^ c[16] ^ c[17] ^ c[24] ^ c[27] ^ c[28];

        next_crc32[ 2] <=   d[31] ^ d[30] ^ d[26] ^ d[24] ^ d[18] ^ d[17] ^ d[16] ^ d[14] ^ d[13] ^ d[ 9] ^ 
                            d[ 8] ^ d[ 7] ^ d[ 6] ^ d[ 2] ^ d[ 1] ^ d[ 0] ^ c[ 0] ^ c[ 1] ^ c[ 2] ^ c[ 6] ^ 
                            c[ 7] ^ c[ 8] ^ c[ 9] ^ c[13] ^ c[14] ^ c[16] ^ c[17] ^ c[18] ^ c[24] ^ c[26] ^ 
                            c[30] ^ c[31];

        next_crc32[ 3] <=   d[31] ^ d[27] ^ d[25] ^ d[19] ^ d[18] ^ d[17] ^ d[15] ^ d[14] ^ d[10] ^ d[ 9] ^ 
                            d[ 8] ^ d[ 7] ^ d[ 3] ^ d[ 2] ^ d[ 1] ^ c[ 1] ^ c[ 2] ^ c[ 3] ^ c[ 7] ^ c[ 8] ^ 
                            c[ 9] ^ c[10] ^ c[14] ^ c[15] ^ c[17] ^ c[18] ^ c[19] ^ c[25] ^ c[27] ^ c[31];

        next_crc32[ 4] <=   d[31] ^ d[30] ^ d[29] ^ d[25] ^ d[24] ^ d[20] ^ d[19] ^ d[18] ^ d[15] ^ d[12] ^ 
                            d[11] ^ d[ 8] ^ d[ 6] ^ d[ 4] ^ d[ 3] ^ d[ 2] ^ d[ 0] ^ c[ 0] ^ c[ 2] ^ c[ 3] ^ 
                            c[ 4] ^ c[ 6] ^ c[ 8] ^ c[11] ^ c[12] ^ c[15] ^ c[18] ^ c[19] ^ c[20] ^ c[24] ^ 
                            c[25] ^ c[29] ^ c[30] ^ c[31];

        next_crc32[ 5] <=   d[29] ^ d[28] ^ d[24] ^ d[21] ^ d[20] ^ d[19] ^ d[13] ^ d[10] ^ d[ 7] ^ d[ 6] ^ 
                            d[ 5] ^ d[ 4] ^ d[ 3] ^ d[ 1] ^ d[ 0] ^ c[ 0] ^ c[ 1] ^ c[ 3] ^ c[ 4] ^ c[ 5] ^ 
                            c[ 6] ^ c[ 7] ^ c[10] ^ c[13] ^ c[19] ^ c[20] ^ c[21] ^ c[24] ^ c[28] ^ c[29];

        next_crc32[ 6] <=   d[30] ^ d[29] ^ d[25] ^ d[22] ^ d[21] ^ d[20] ^ d[14] ^ d[11] ^ d[ 8] ^ d[ 7] ^ 
                            d[ 6] ^ d[ 5] ^ d[ 4] ^ d[ 2] ^ d[ 1] ^ c[ 1] ^ c[ 2] ^ c[ 4] ^ c[ 5] ^ c[ 6] ^ 
                            c[ 7] ^ c[ 8] ^ c[11] ^ c[14] ^ c[20] ^ c[21] ^ c[22] ^ c[25] ^ c[29] ^ c[30];

        next_crc32[ 7] <=   d[29] ^ d[28] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[16] ^ d[15] ^ d[10] ^ 
                            d[ 8] ^ d[ 7] ^ d[ 5] ^ d[ 3] ^ d[ 2] ^ d[ 0] ^ c[ 0] ^ c[ 2] ^ c[ 3] ^ c[ 5] ^ 
                            c[ 7] ^ c[ 8] ^ c[10] ^ c[15] ^ c[16] ^ c[21] ^ c[22] ^ c[23] ^ c[24] ^ c[25] ^ 
                            c[28] ^ c[29];

        next_crc32[ 8] <=   d[31] ^ d[28] ^ d[23] ^ d[22] ^ d[17] ^ d[12] ^ d[11] ^ d[10] ^ d[ 8] ^ d[ 4] ^ 
                            d[ 3] ^ d[ 1] ^ d[ 0] ^ c[ 0] ^ c[ 1] ^ c[ 3] ^ c[ 4] ^ c[ 8] ^ c[10] ^ c[11] ^ 
                            c[12] ^ c[17] ^ c[22] ^ c[23] ^ c[28] ^ c[31];

        next_crc32[ 9] <=   d[29] ^ d[24] ^ d[23] ^ d[18] ^ d[13] ^ d[12] ^ d[11] ^ d[ 9] ^ d[ 5] ^ d[ 4] ^ 
                            d[ 2] ^ d[ 1] ^ c[ 1] ^ c[ 2] ^ c[ 4] ^ c[ 5] ^ c[ 9] ^ c[11] ^ c[12] ^ c[13] ^ 
                            c[18] ^ c[23] ^ c[24] ^ c[29];

        next_crc32[10] <=   d[31] ^ d[29] ^ d[28] ^ d[26] ^ d[19] ^ d[16] ^ d[14] ^ d[13] ^ d[ 9] ^ d[ 5] ^ 
                            d[ 3] ^ d[ 2] ^ d[ 0] ^ c[ 0] ^ c[ 2] ^ c[ 3] ^ c[ 5] ^ c[ 9] ^ c[13] ^ c[14] ^ 
                            c[16] ^ c[19] ^ c[26] ^ c[28] ^ c[29] ^ c[31];

        next_crc32[11] <=   d[31] ^ d[28] ^ d[27] ^ d[26] ^ d[25] ^ d[24] ^ d[20] ^ d[17] ^ d[16] ^ d[15] ^ 
                            d[14] ^ d[12] ^ d[ 9] ^ d[ 4] ^ d[ 3] ^ d[ 1] ^ d[ 0] ^ c[ 0] ^ c[ 1] ^ c[ 3] ^ 
                            c[ 4] ^ c[ 9] ^ c[12] ^ c[14] ^ c[15] ^ c[16] ^ c[17] ^ c[20] ^ c[24] ^ c[25] ^ 
                            c[26] ^ c[27] ^ c[28] ^ c[31];

        next_crc32[12] <=   d[31] ^ d[30] ^ d[27] ^ d[24] ^ d[21] ^ d[18] ^ d[17] ^ d[15] ^ d[13] ^ d[12] ^ 
                            d[ 9] ^ d[ 6] ^ d[ 5] ^ d[ 4] ^ d[ 2] ^ d[ 1] ^ d[ 0] ^ c[ 0] ^ c[ 1] ^ c[ 2] ^ 
                            c[ 4] ^ c[ 5] ^ c[ 6] ^ c[ 9] ^ c[12] ^ c[13] ^ c[15] ^ c[17] ^ c[18] ^ c[21] ^ 
                            c[24] ^ c[27] ^ c[30] ^ c[31];

        next_crc32[13] <=   d[31] ^ d[28] ^ d[25] ^ d[22] ^ d[19] ^ d[18] ^ d[16] ^ d[14] ^ d[13] ^ d[10] ^ 
                            d[ 7] ^ d[ 6] ^ d[ 5] ^ d[ 3] ^ d[ 2] ^ d[ 1] ^ c[ 1] ^ c[ 2] ^ c[ 3] ^ c[ 5] ^
                            c[ 6] ^ c[ 7] ^ c[10] ^ c[13] ^ c[14] ^ c[16] ^ c[18] ^ c[19] ^ c[22] ^ c[25] ^ 
                            c[28] ^ c[31];
        next_crc32[14] <=   d[29] ^ d[26] ^ d[23] ^ d[20] ^ d[19] ^ d[17] ^ d[15] ^ d[14] ^ d[11] ^ d[ 8] ^ 
                            d[ 7] ^ d[ 6] ^ d[ 4] ^ d[ 3] ^ d[ 2] ^ c[ 2] ^ c[ 3] ^ c[ 4] ^ c[ 6] ^ c[ 7] ^ 
                            c[ 8] ^ c[11] ^ c[14] ^ c[15] ^ c[17] ^ c[19] ^ c[20] ^ c[23] ^ c[26] ^ c[29];

        next_crc32[15] <=   d[30] ^ d[27] ^ d[24] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[ 9] ^ 
                            d[ 8] ^ d[ 7] ^ d[ 5] ^ d[ 4] ^ d[ 3] ^ c[ 3] ^ c[ 4] ^ c[ 5] ^ c[ 7] ^ c[ 8] ^ 
                            c[ 9] ^ c[12] ^ c[15] ^ c[16] ^ c[18] ^ c[20] ^ c[21] ^ c[24] ^ c[27] ^ c[30];

        next_crc32[16] <=   d[30] ^ d[29] ^ d[26] ^ d[24] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[13] ^ d[12] ^ 
                            d[ 8] ^ d[ 5] ^ d[ 4] ^ d[ 0] ^ c[ 0] ^ c[ 4] ^ c[ 5] ^ c[ 8] ^ c[12] ^ c[13] ^ 
                            c[17] ^ c[19] ^ c[21] ^ c[22] ^ c[24] ^ c[26] ^ c[29] ^ c[30];
                            
        next_crc32[17] <=   d[31] ^ d[30] ^ d[27] ^ d[25] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[14] ^ d[13] ^ 
                            d[ 9] ^ d[ 6] ^ d[ 5] ^ d[ 1] ^ c[ 1] ^ c[ 5] ^ c[ 6] ^ c[ 9] ^ c[13] ^ c[14] ^ 
                            c[18] ^ c[20] ^ c[22] ^ c[23] ^ c[25] ^ c[27] ^ c[30] ^ c[31];

        next_crc32[18] <=   d[31] ^ d[28] ^ d[26] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[15] ^ d[14] ^ d[10] ^ 
                            d[ 7] ^ d[ 6] ^ d[ 2] ^ c[ 2] ^ c[ 6] ^ c[ 7] ^ c[10] ^ c[14] ^ c[15] ^ c[19] ^ 
                            c[21] ^ c[23] ^ c[24] ^ c[26] ^ c[28] ^ c[31];

        next_crc32[19] <=   d[29] ^ d[27] ^ d[25] ^ d[24] ^ d[22] ^ d[20] ^ d[16] ^ d[15] ^ d[11] ^ d[ 8] ^ 
                            d[ 7] ^ d[ 3] ^ c[ 3] ^ c[ 7] ^ c[ 8] ^ c[11] ^ c[15] ^ c[16] ^ c[20] ^ c[22] ^ 
                            c[24] ^ c[25] ^ c[27] ^ c[29];

        next_crc32[20] <=   d[30] ^ d[28] ^ d[26] ^ d[25] ^ d[23] ^ d[21] ^ d[17] ^ d[16] ^ d[12] ^ d[ 9] ^ 
                            d[ 8] ^ d[ 4] ^ c[ 4] ^ c[ 8] ^ c[ 9] ^ c[12] ^ c[16] ^ c[17] ^ c[21] ^ c[23] ^ 
                            c[25] ^ c[26] ^ c[28] ^ c[30];

        next_crc32[21] <=   d[31] ^ d[29] ^ d[27] ^ d[26] ^ d[24] ^ d[22] ^ d[18] ^ d[17] ^ d[13] ^ d[10] ^ 
                            d[ 9] ^ d[ 5] ^ c[ 5] ^ c[ 9] ^ c[10] ^ c[13] ^ c[17] ^ c[18] ^ c[22] ^ c[24] ^ 
                            c[26] ^ c[27] ^ c[29] ^ c[31];

        next_crc32[22] <=   d[31] ^ d[29] ^ d[27] ^ d[26] ^ d[24] ^ d[23] ^ d[19] ^ d[18] ^ d[16] ^ d[14] ^ 
                            d[12] ^ d[11] ^ d[ 9] ^ d[ 0] ^ c[ 0] ^ c[ 9] ^ c[11] ^ c[12] ^ c[14] ^ c[16] ^ 
                            c[18] ^ c[19] ^ c[23] ^ c[24] ^ c[26] ^ c[27] ^ c[29] ^ c[31];

        next_crc32[23] <=   d[31] ^ d[29] ^ d[27] ^ d[26] ^ d[20] ^ d[19] ^ d[17] ^ d[16] ^ d[15] ^ d[13] ^ 
                            d[ 9] ^ d[ 6] ^ d[ 1] ^ d[ 0] ^ c[ 0] ^ c[ 1] ^ c[ 6] ^ c[ 9] ^ c[13] ^ c[15] ^ 
                            c[16] ^ c[17] ^ c[19] ^ c[20] ^ c[26] ^ c[27] ^ c[29] ^ c[31];

        next_crc32[24] <=   d[30] ^ d[28] ^ d[27] ^ d[21] ^ d[20] ^ d[18] ^ d[17] ^ d[16] ^ d[14] ^ d[10] ^ 
                            d[ 7] ^ d[ 2] ^ d[ 1] ^ c[ 1] ^ c[ 2] ^ c[ 7] ^ c[10] ^ c[14] ^ c[16] ^ c[17] ^ 
                            c[18] ^ c[20] ^ c[21] ^ c[27] ^ c[28] ^ c[30];

        next_crc32[25] <=   d[31] ^ d[29] ^ d[28] ^ d[22] ^ d[21] ^ d[19] ^ d[18] ^ d[17] ^ d[15] ^ d[11] ^ 
                            d[ 8] ^ d[ 3] ^ d[ 2] ^ c[ 2] ^ c[ 3] ^ c[ 8] ^ c[11] ^ c[15] ^ c[17] ^ c[18] ^ 
                            c[19] ^ c[21] ^ c[22] ^ c[28] ^ c[29] ^ c[31];

        next_crc32[26] <=   d[31] ^ d[28] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[19] ^ d[18] ^ 
                            d[10] ^ d[ 6] ^ d[ 4] ^ d[ 3] ^ d[ 0] ^ c[ 0] ^ c[ 3] ^ c[ 4] ^ c[ 6] ^ c[10] ^ 
                            c[18] ^ c[19] ^ c[20] ^ c[22] ^ c[23] ^ c[24] ^ c[25] ^ c[26] ^ c[28] ^ c[31];

        next_crc32[27] <=   d[29] ^ d[27] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[20] ^ d[19] ^ d[11] ^ 
                            d[ 7] ^ d[ 5] ^ d[ 4] ^ d[ 1] ^ c[ 1] ^ c[ 4] ^ c[ 5] ^ c[ 7] ^ c[11] ^ c[19] ^ 
                            c[20] ^ c[21] ^ c[23] ^ c[24] ^ c[25] ^ c[26] ^ c[27] ^ c[29];

        next_crc32[28] <=   d[30] ^ d[28] ^ d[27] ^ d[26] ^ d[25] ^ d[24] ^ d[22] ^ d[21] ^ d[20] ^ d[12] ^ 
                            d[ 8] ^ d[ 6] ^ d[ 5] ^ d[ 2] ^ c[ 2] ^ c[ 5] ^ c[ 6] ^ c[ 8] ^ c[12] ^ c[20] ^ 
                            c[21] ^ c[22] ^ c[24] ^ c[25] ^ c[26] ^ c[27] ^ c[28] ^ c[30];

        next_crc32[29] <=   d[31] ^ d[29] ^ d[28] ^ d[27] ^ d[26] ^ d[25] ^ d[23] ^ d[22] ^ d[21] ^ d[13] ^ 
                            d[ 9] ^ d[ 7] ^ d[ 6] ^ d[ 3] ^ c[ 3] ^ c[ 6] ^ c[ 7] ^ c[ 9] ^ c[13] ^ c[21] ^ 
                            c[22] ^ c[23] ^ c[25] ^ c[26] ^ c[27] ^ c[28] ^ c[29] ^ c[31];

        next_crc32[30] <=   d[30] ^ d[29] ^ d[28] ^ d[27] ^ d[26] ^ d[24] ^ d[23] ^ d[22] ^ d[14] ^ d[10] ^ 
                            d[ 8] ^ d[ 7] ^ d[ 4] ^ c[ 4] ^ c[ 7] ^ c[ 8] ^ c[10] ^ c[14] ^ c[22] ^ c[23] ^ 
                            c[24] ^ c[26] ^ c[27] ^ c[28] ^ c[29] ^ c[30];

        next_crc32[31] <=   d[31] ^ d[30] ^ d[29] ^ d[28] ^ d[27] ^ d[25] ^ d[24] ^ d[23] ^ d[15] ^ d[11] ^ 
                            d[ 9] ^ d[ 8] ^ d[ 5] ^ c[ 5] ^ c[ 8] ^ c[ 9] ^ c[11] ^ c[15] ^ c[23] ^ c[24] ^ 
                            c[25] ^ c[27] ^ c[28] ^ c[29] ^ c[30] ^ c[31];
    end
end

endmodule