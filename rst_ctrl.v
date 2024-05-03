

module  rst_ctrl
   (
      input                               sys_clk,
      input                               sys_rst_n,
      
      output                              ddr_reset_n
   );

//***************************************************************
//--Reset Generation 
//--∆Ù∂Ø—” ±£∫20ns*28'hFFFFF00=5368704000ns
//***************************************************************

reg[27:0] ddr_rst_cnt=0;
reg       ddr_reset_n=0;

always @ (posedge sys_clk or negedge sys_rst_n)begin
   if(!sys_rst_n)
     ddr_rst_cnt <= 28'b0;
   else if(ddr_rst_cnt==28'hFFFFFFE)
     ddr_rst_cnt <= 28'hFFFFFFE;
   else 
     ddr_rst_cnt <= ddr_rst_cnt + 1'b1;
end
always @ (posedge sys_clk or negedge sys_rst_n)begin
   if(!sys_rst_n)
     ddr_reset_n <= 1'b0;
   else if(ddr_rst_cnt>=28'hFFFFF00)
     ddr_reset_n <= 1'b1;
   else 
     ddr_reset_n <= 1'b0;
end

endmodule 