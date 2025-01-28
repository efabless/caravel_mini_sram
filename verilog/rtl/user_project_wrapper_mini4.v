// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

module user_project_wrapper_mini4 #(
    parameter BITS = 30,
    parameter COUNT_STEP = 1
) (
`ifdef USE_POWER_PINS
    inout VPWR,  // User area 1 1.8V supply
    inout VGND,  // User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [31:0] la_data_in,
    output [31:0] la_data_out,
    input  [31:0] la_oenb,

    // IOs
    input  [35:0] io_in,
    output [35:0] io_out,
    output [35:0] io_oeb,

    // Independent clock (on independent integer divider)
    input user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

    // Counter to drive some logic
    reg [7:0] counter;
    always @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i)
            counter <= 0;
        else
            counter <= counter + COUNT_STEP;
    end

    // Assign the counter value to output for demonstration
    assign io_out[7:0] = counter;

    // Set output enable for the counter outputs
    assign io_oeb[7:0] = 8'b0; // Active low, enabled

    // Unused outputs
    assign io_out[35:8] = 28'b0;
    assign io_oeb[35:8] = 28'b1; // Disabled

    // SRAM instance
    SRAM_1024x32_wb_wrapper mprj (
`ifdef USE_POWER_PINS
        .VPWR(VPWR),    // User area 1 1.8V power
        .VGND(VGND),    // User area 1 digital ground
`endif
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),
        // MGMT SoC Wishbone Slave
        .wbs_cyc_i(wbs_cyc_i),
        .wbs_stb_i(wbs_stb_i),
        .wbs_we_i(wbs_we_i),
        .wbs_sel_i(wbs_sel_i),
        .wbs_adr_i(wbs_adr_i),
        .wbs_dat_i(wbs_dat_i),
        .wbs_ack_o(wbs_ack_o),
        .wbs_dat_o(wbs_dat_o)
    );

endmodule