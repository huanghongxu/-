
module led_ctrl
   (
      //--
      input                                  rst_n,
      input                                  clk,
      output         [1:0]                   led
   );
reg[27:0]cnt;
always @ (posedge clk or negedge rst_n)begin
   if(!rst_n)
      cnt <= 28'd0;
   else if(cnt == 28'd50000000) //--50Mhz 1s 钟循环计数
      cnt <= 28'b0;
   else
      cnt <= cnt + 1'b1;
end
reg led_r;
always @ (posedge clk or negedge rst_n)begin
   if(!rst_n)
      led_r <= 1'b0;
   else if(cnt == 28'd50000000)
      led_r <= ~led_r;
end
assign led = {led_r,~led_r};   //  2个LED循环闪烁
endmodule
