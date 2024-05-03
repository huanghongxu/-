module ddr_ctrl_driver 
   #
   (
      parameter      ADDR_WIDTH    =     30,
      parameter      DATA_WIDTH    =     32
   )
   (

      //--
//      input                                  rst_n,
      //*******************************************
      //--应用接口
      //*******************************************
      input                                  app_clk,             //--App clk
      //--
      output                                 app_w_enable,        //--
      output                                 app_r_enable,
      //--Write 
      input       [29:0]                     app_addr_wr,
      input                                  app_addr_wr_valid,
      input       [31:0]                     app_data_wr,
      input                                  app_data_wr_valid,
      //--Read
      input       [29:0]                     app_addr_rd,
      input                                  app_addr_rd_valid,
      output   reg[31:0]                     app_data_rd,
      output   reg                           app_data_rd_valid,
      //*******************************************
      //--DDR2 IP Interface
      //*******************************************
      input                                  c1_clk0,
      input                                  c1_rst0,
      input                                  c1_calib_done,
      //--
      output                                 c1_p2_cmd_clk,
      output   reg                           c1_p2_cmd_en,
      output   reg[2:0]                      c1_p2_cmd_instr,
      output   reg[5:0]                      c1_p2_cmd_bl,
      output   reg[29:0]                     c1_p2_cmd_byte_addr,
      input                                  c1_p2_cmd_empty,
      input                                  c1_p2_cmd_full,
      //--
      output                                 c1_p2_wr_clk,
      output   reg                           c1_p2_wr_en,
      output   reg[3:0]                      c1_p2_wr_mask,
      output   reg[31:0]                     c1_p2_wr_data,
      input                                  c1_p2_wr_full,
      input                                  c1_p2_wr_empty,
      input       [6:0]                      c1_p2_wr_count,
      input                                  c1_p2_wr_underrun,
      input                                  c1_p2_wr_error,
      //--
      output                                 c1_p3_cmd_clk,
      output   reg                           c1_p3_cmd_en,
      output   reg[2:0]                      c1_p3_cmd_instr,
      output   reg[5:0]                      c1_p3_cmd_bl,
      output   reg[29:0]                     c1_p3_cmd_byte_addr,
      input                                  c1_p3_cmd_empty,
      input                                  c1_p3_cmd_full,
      //--
      output                                 c1_p3_rd_clk,
      output   reg                           c1_p3_rd_en,
      input       [31:0]                     c1_p3_rd_data,
      input                                  c1_p3_rd_full,
      input                                  c1_p3_rd_empty,
      input       [6:0]                      c1_p3_rd_count,
      input                                  c1_p3_rd_overflow,
      input                                  c1_p3_rd_error
   );
assign rst_n = ~c1_rst0;
//********************************************
//--
//********************************************

assign app_w_enable = (c1_calib_done==1'b1 && c1_p2_wr_full==1'b0 && c1_p2_cmd_full==1'b0) ? 1'b1 : 1'b0;

always @ (posedge c1_clk0 or negedge rst_n)begin
   if(!rst_n)begin
      c1_p2_wr_en   <= 1'b0;
      c1_p2_wr_mask <= 4'b0;
      c1_p2_wr_data <= 32'b0;
      end
   else begin
      c1_p2_wr_en   <= app_data_wr_valid;
      c1_p2_wr_mask <= 4'b0;
      c1_p2_wr_data <= app_data_wr;
      end
end
always @ (posedge c1_clk0 or negedge rst_n)begin
   if(!rst_n)begin
      c1_p2_cmd_en         <= 1'b0;
      c1_p2_cmd_instr      <= 3'b0;
      c1_p2_cmd_bl         <= 6'b0;
      c1_p2_cmd_byte_addr  <= 30'b0;
      end
   else begin
      c1_p2_cmd_en         <= app_addr_wr_valid;
      c1_p2_cmd_instr      <= 3'b0;
      c1_p2_cmd_bl         <= 6'd31; //一次读写32字节数据
      c1_p2_cmd_byte_addr  <= app_addr_wr;
      end
end

//--RD
assign app_r_enable = (c1_calib_done==1'b1 && c1_p3_cmd_full==1'b0 && c1_p3_rd_full==1'b0) ? 1'b1 : 1'b0;
always @ (posedge c1_clk0 or negedge rst_n)begin
   if(!rst_n)begin
      c1_p3_cmd_en         <= 1'b0;
      c1_p3_cmd_instr      <= 3'b0;
      c1_p3_cmd_bl         <= 6'b0;
      c1_p3_cmd_byte_addr  <= 30'b0;
      end
   else begin
      c1_p3_cmd_en         <= app_addr_rd_valid;
      c1_p3_cmd_instr      <= 3'b1;
      c1_p3_cmd_bl         <= 6'd31;//突发长度32个字节数据，表示一次读写1到32个字节数据
      c1_p3_cmd_byte_addr  <= app_addr_rd; //c1_p3_cmd_byte_addr字节起始地址，
      end
end
always @ (posedge c1_clk0 or negedge rst_n)begin
   if(!rst_n)
      c1_p3_rd_en   <= 1'b0;
   else if(c1_p3_rd_empty==1'b0 && c1_p3_rd_count >1)
      c1_p3_rd_en   <= 1'b1;
   else 
      c1_p3_rd_en   <= 1'b0;
end
//synthesis attribute keep of c1_p3_rd_count is true
//--
always @ (posedge c1_clk0 or negedge rst_n)begin
   if(!rst_n)
      app_data_rd_valid   <= 1'b0;
   else if(c1_p3_rd_en==1'b1)
      app_data_rd_valid   <= 1'b1;
   else 
      app_data_rd_valid   <= 1'b0;
end
always @ (posedge c1_clk0 or negedge rst_n)begin
   if(!rst_n)
      app_data_rd   <= 32'b0;
   else if(c1_p3_rd_en==1'b1)
      app_data_rd   <= c1_p3_rd_data;
   else 
      app_data_rd   <= 32'b0;
end

assign c1_p2_cmd_clk = c1_clk0;
assign c1_p2_wr_clk  = c1_clk0;
assign c1_p3_cmd_clk = c1_clk0;
assign c1_p3_rd_clk  = c1_clk0;


endmodule 