`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:36:03 01/20/2016 
// Design Name: 
// Module Name:    ddr_ctrl_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module ddr_ctrl_top
      (
      //***********************************************************
      //--System Signals
      //***********************************************************
      input                                            sys_clk,       //--50M
//      input                                            sys_rst_n,
      //***********************************************************
      //--DDR3 Interface
      //***********************************************************
      inout  [16-1:0]                                  mcb1_dram_dq,
      output [14-1:0]                                  mcb1_dram_a,
      output [ 3-1:0]                                  mcb1_dram_ba,
      output                                           mcb1_dram_ras_n,
      output                                           mcb1_dram_cas_n,
      output                                           mcb1_dram_we_n,
      output                                           mcb1_dram_odt,
      output                                           mcb1_dram_reset_n,
      output                                           mcb1_dram_cke,
      output                                           mcb1_dram_dm,
      inout                                            mcb1_dram_udqs,
      inout                                            mcb1_dram_udqs_n,
      inout                                            mcb1_rzq,
      inout                                            mcb1_zio,
      output                                           mcb1_dram_udm,
      inout                                            mcb1_dram_dqs,
      inout                                            mcb1_dram_dqs_n,
      output                                           mcb1_dram_ck,
      output                                           mcb1_dram_ck_n,
      //*************************************
      //--LED
      //*************************************
      output [ 1 : 0]                                  led
    );

assign  sys_rst_n = 1'b1;




//***************************************************************
//--信号定义
//***************************************************************
localparam     DDR2_ADDR_WIDTH  = 30;
localparam     DDR2_DATA_WIDTH  = 32;


wire                                  app_r_enable;
wire                                  app_w_enable;
wire       [DDR2_ADDR_WIDTH-1: 0]     app_addr_wr;
wire                                  app_addr_wr_valid;
wire       [DDR2_DATA_WIDTH-1: 0]     app_data_wr;
wire                                  app_data_wr_valid;
//--Read
wire       [DDR2_ADDR_WIDTH-1: 0]     app_addr_rd;
wire                                  app_addr_rd_valid;


wire       [DDR2_DATA_WIDTH-1: 0]     app_data_rd;
wire                                  app_data_rd_valid;



wire                                  c1_clk0;
wire                                  c1_rst0;
wire                                  c1_calib_done;
      //--
wire                                  c1_p2_cmd_clk;
wire                                  c1_p2_cmd_en;
wire       [2:0]                      c1_p2_cmd_instr;
wire       [5:0]                      c1_p2_cmd_bl;
wire       [29:0]                     c1_p2_cmd_byte_addr;
wire                                  c1_p2_cmd_empty;
wire                                  c1_p2_cmd_full;
      //--
wire                                  c1_p2_wr_clk;
wire                                  c1_p2_wr_en;
wire       [3:0]                      c1_p2_wr_mask;
wire       [31:0]                     c1_p2_wr_data;
wire                                  c1_p2_wr_full;
wire                                  c1_p2_wr_empty;
wire       [6:0]                      c1_p2_wr_count;
wire                                  c1_p2_wr_underrun;
wire                                  c1_p2_wr_error;
      //--
wire                                  c1_p3_cmd_clk;
wire                                  c1_p3_cmd_en;
wire       [2:0]                      c1_p3_cmd_instr;
wire       [5:0]                      c1_p3_cmd_bl;
wire       [29:0]                     c1_p3_cmd_byte_addr;
wire                                  c1_p3_cmd_empty;
wire                                  c1_p3_cmd_full;
      //--
wire                                  c1_p3_rd_clk;
wire                                  c1_p3_rd_en;
wire       [31:0]                     c1_p3_rd_data;
wire                                  c1_p3_rd_full;
wire                                  c1_p3_rd_empty;
wire       [6:0]                      c1_p3_rd_count;
wire                                  c1_p3_rd_overflow;
wire                                  c1_p3_rd_error;


//***************************************************************
//--复位
//***************************************************************
rst_ctrl rst_ctrl (
    .sys_clk                              (sys_clk             ),
    .sys_rst_n                            (sys_rst_n           ),
    //***********************************************************
    //--
    //***********************************************************
    .ddr_reset_n                          (ddr_reset_n         )
    );

assign c1_sys_rst_i =  ~ddr_reset_n;
assign rst_n        =  ~c1_rst0;

//***************************************************************
//--
//***************************************************************
clk_ctrl clk_ctrl (
    .sys_clk                              (sys_clk             ),
    .sys_rst_n                            (sys_rst_n           ),
    //***********************************************************
    //--
    //***********************************************************
    .clk_FX                               (c1_sys_clk          )
    );


//***************************************************************
//--Example Design
//***************************************************************
ddr_app_demo #
   (
    .ADDR_WIDTH                           (DDR2_ADDR_WIDTH     ),
    .DATA_WIDTH                           (DDR2_DATA_WIDTH     )
   )
   ddr_app_demo (
    .rst_n                                (rst_n               ),
    .app_clk                              (c1_clk0             ), 
    .app_w_enable                         (app_w_enable        ),
    .app_r_enable                         (app_r_enable        ),
    .app_addr_wr                          (app_addr_wr         ), 
    .app_addr_wr_valid                    (app_addr_wr_valid   ), 
    .app_data_wr                          (app_data_wr         ), 
    .app_data_wr_valid                    (app_data_wr_valid   ), 
    .app_addr_rd                          (app_addr_rd         ), 
    .app_addr_rd_valid                    (app_addr_rd_valid   ), 
    .app_data_rd                          (app_data_rd         ), 
    .app_data_rd_valid                    (app_data_rd_valid   ),
    .triger_app_wr2rd                     (triger_app_wr2rd)
    );


ddr_ctrl_driver #
   (
    .ADDR_WIDTH                           (DDR2_ADDR_WIDTH     ),
    .DATA_WIDTH                           (DDR2_DATA_WIDTH     )
   )
   ddr_ctrl_driver (
//   .rst_n                                 (rst_n               ), 
   .app_clk                               (app_clk             ), 
   .app_w_enable                          (app_w_enable        ), 
   .app_r_enable                          (app_r_enable        ), 
   .app_addr_wr                           (app_addr_wr         ), 
   .app_addr_wr_valid                     (app_addr_wr_valid   ), 
   .app_data_wr                           (app_data_wr         ), 
   .app_data_wr_valid                     (app_data_wr_valid   ), 
   .app_addr_rd                           (app_addr_rd         ), 
   .app_addr_rd_valid                     (app_addr_rd_valid   ), 
   .app_data_rd                           (app_data_rd         ), 
   .app_data_rd_valid                     (app_data_rd_valid   ), 
    
   .c1_calib_done                         (c1_calib_done       ),
   .c1_clk0                               (c1_clk0             ),
   .c1_rst0                               (c1_rst0             ),

    //--
   .c1_p2_cmd_clk                         (c1_p2_cmd_clk       ), 
   .c1_p2_cmd_en                          (c1_p2_cmd_en        ), 
   .c1_p2_cmd_instr                       (c1_p2_cmd_instr     ), 
   .c1_p2_cmd_bl                          (c1_p2_cmd_bl        ), 
   .c1_p2_cmd_byte_addr                   (c1_p2_cmd_byte_addr ), 
   .c1_p2_cmd_empty                       (c1_p2_cmd_empty     ), 
   .c1_p2_cmd_full                        (c1_p2_cmd_full      ), 
   .c1_p2_wr_clk                          (c1_p2_wr_clk        ), 
   .c1_p2_wr_en                           (c1_p2_wr_en         ), 
   .c1_p2_wr_mask                         (c1_p2_wr_mask       ), 
   .c1_p2_wr_data                         (c1_p2_wr_data       ), 
   .c1_p2_wr_full                         (c1_p2_wr_full       ), 
   .c1_p2_wr_empty                        (c1_p2_wr_empty      ), 
   .c1_p2_wr_count                        (c1_p2_wr_count      ), 
   .c1_p2_wr_underrun                     (c1_p2_wr_underrun   ), 
   .c1_p2_wr_error                        (c1_p2_wr_error      ), 
   .c1_p3_cmd_clk                         (c1_p3_cmd_clk       ), 
   .c1_p3_cmd_en                          (c1_p3_cmd_en        ), 
   .c1_p3_cmd_instr                       (c1_p3_cmd_instr     ), 
   .c1_p3_cmd_bl                          (c1_p3_cmd_bl        ), 
   .c1_p3_cmd_byte_addr                   (c1_p3_cmd_byte_addr ), 
   .c1_p3_cmd_empty                       (c1_p3_cmd_empty     ), 
   .c1_p3_cmd_full                        (c1_p3_cmd_full      ), 
   .c1_p3_rd_clk                          (c1_p3_rd_clk        ), 
   .c1_p3_rd_en                           (c1_p3_rd_en         ), 
   .c1_p3_rd_data                         (c1_p3_rd_data       ), 
   .c1_p3_rd_full                         (c1_p3_rd_full       ), 
   .c1_p3_rd_empty                        (c1_p3_rd_empty      ), 
   .c1_p3_rd_count                        (c1_p3_rd_count      ), 
   .c1_p3_rd_overflow                     (c1_p3_rd_overflow   ), 
   .c1_p3_rd_error                        (c1_p3_rd_error      )
    );

//***************************************************************
//--DDR3 IP
//***************************************************************
ddr3 ddr3 (
   .c1_sys_clk                            (c1_sys_clk          ),
   .c1_sys_rst_i                          (c1_sys_rst_i        ),
   .mcb1_dram_dq                          (mcb1_dram_dq        ),  
   .mcb1_dram_a                           (mcb1_dram_a         ),  
   .mcb1_dram_ba                          (mcb1_dram_ba        ),
   .mcb1_dram_ras_n                       (mcb1_dram_ras_n     ),                        
   .mcb1_dram_cas_n                       (mcb1_dram_cas_n     ),                        
   .mcb1_dram_we_n                        (mcb1_dram_we_n      ),                          
   .mcb1_dram_odt                         (mcb1_dram_odt       ),
   .mcb1_dram_cke                         (mcb1_dram_cke       ),                          
   .mcb1_dram_ck                          (mcb1_dram_ck        ),                          
   .mcb1_dram_ck_n                        (mcb1_dram_ck_n      ),       
   .mcb1_dram_dqs                         (mcb1_dram_dqs       ),                          
   .mcb1_dram_dqs_n                       (mcb1_dram_dqs_n     ),
   .mcb1_dram_udqs                        (mcb1_dram_udqs      ),     // for X16 parts                        
   .mcb1_dram_udqs_n                      (mcb1_dram_udqs_n    ),     // for X16 parts
   .mcb1_dram_udm                         (mcb1_dram_udm       ),     // for X16 parts
   .mcb1_dram_dm                          (mcb1_dram_dm        ),
   .mcb1_dram_reset_n                     (mcb1_dram_reset_n   ),
   .mcb1_rzq                              (mcb1_rzq            ),  
   .mcb1_zio                              (mcb1_zio            ),
    //--
   .c1_calib_done                         (c1_calib_done       ),
   .c1_clk0                               (c1_clk0             ),
   .c1_rst0                               (c1_rst0             ),

    //--
   .c1_p2_cmd_clk                         (c1_p2_cmd_clk       ), 
   .c1_p2_cmd_en                          (c1_p2_cmd_en        ), 
   .c1_p2_cmd_instr                       (c1_p2_cmd_instr     ), 
   .c1_p2_cmd_bl                          (c1_p2_cmd_bl        ), 
   .c1_p2_cmd_byte_addr                   (c1_p2_cmd_byte_addr ), 
   .c1_p2_cmd_empty                       (c1_p2_cmd_empty     ), 
   .c1_p2_cmd_full                        (c1_p2_cmd_full      ), 
   .c1_p2_wr_clk                          (c1_p2_wr_clk        ), 
   .c1_p2_wr_en                           (c1_p2_wr_en         ), 
   .c1_p2_wr_mask                         (c1_p2_wr_mask       ), 
   .c1_p2_wr_data                         (c1_p2_wr_data       ), 
   .c1_p2_wr_full                         (c1_p2_wr_full       ), 
   .c1_p2_wr_empty                        (c1_p2_wr_empty      ), 
   .c1_p2_wr_count                        (c1_p2_wr_count      ), 
   .c1_p2_wr_underrun                     (c1_p2_wr_underrun   ), 
   .c1_p2_wr_error                        (c1_p2_wr_error      ), 
   .c1_p3_cmd_clk                         (c1_p3_cmd_clk       ), 
   .c1_p3_cmd_en                          (c1_p3_cmd_en        ), 
   .c1_p3_cmd_instr                       (c1_p3_cmd_instr     ), 
   .c1_p3_cmd_bl                          (c1_p3_cmd_bl        ), 
   .c1_p3_cmd_byte_addr                   (c1_p3_cmd_byte_addr ), 
   .c1_p3_cmd_empty                       (c1_p3_cmd_empty     ), 
   .c1_p3_cmd_full                        (c1_p3_cmd_full      ), 
   .c1_p3_rd_clk                          (c1_p3_rd_clk        ), 
   .c1_p3_rd_en                           (c1_p3_rd_en         ), 
   .c1_p3_rd_data                         (c1_p3_rd_data       ), 
   .c1_p3_rd_full                         (c1_p3_rd_full       ), 
   .c1_p3_rd_empty                        (c1_p3_rd_empty      ), 
   .c1_p3_rd_count                        (c1_p3_rd_count      ), 
   .c1_p3_rd_overflow                     (c1_p3_rd_overflow   ), 
   .c1_p3_rd_error                        (c1_p3_rd_error      )
);


//仿真
wire [35:0] CONTROL0;
wire [255:0] TRIG0;

ddr3_test_icon ddr3_test_icon_u (
    .CONTROL0(CONTROL0) // INOUT BUS [35:0]
);

ddr3_test_ila ddr3_test_ila_u (
    .CONTROL(CONTROL0), // INOUT BUS [35:0]
    .CLK(c1_clk0), // IN
    .TRIG0(TRIG0) // IN BUS [255:0]
);

assign TRIG0[0]       = c1_p2_wr_en;  
assign TRIG0[32:1]    = c1_p2_wr_data;
assign TRIG0[33]      = c1_p2_cmd_en;
assign TRIG0[36:34]   = c1_p2_cmd_instr;
assign TRIG0[42:37]   = c1_p2_cmd_bl;
assign TRIG0[72:43]   = c1_p2_cmd_byte_addr;

assign TRIG0[73]      = c1_p3_rd_en; 
assign TRIG0[105:74]  = c1_p3_rd_data;
assign TRIG0[106]     = c1_p3_cmd_en;
assign TRIG0[109:107] = c1_p3_cmd_instr;
assign TRIG0[115:110] = c1_p3_cmd_bl;
assign TRIG0[145:116] = c1_p3_cmd_byte_addr;

assign TRIG0[146]     = c1_p2_cmd_empty; //input
assign TRIG0[147]     = c1_p2_cmd_full;
assign TRIG0[148]     = c1_p2_wr_empty;
assign TRIG0[149]     = c1_p2_wr_error;
assign TRIG0[150]     = c1_p2_wr_full;

assign TRIG0[151]     = c1_p3_cmd_empty;
assign TRIG0[152]     = c1_p3_cmd_full;
assign TRIG0[153]     = c1_p3_rd_empty;
assign TRIG0[154]     = c1_p3_rd_error;
assign TRIG0[155]     = c1_p3_rd_full;

assign TRIG0[162:156]     = c1_p2_wr_count;
assign TRIG0[169:163]     = c1_p3_rd_count;

assign TRIG0[170]     = c1_calib_done;
assign TRIG0[171]     = triger_app_wr2rd;

endmodule
