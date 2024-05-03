//产生w_cnt计数器
//通过计数器w_cnt生成写地址 app_addr_wr，写地址有效信号app_addr_wr_valid，以及写数据有效信号app_data_wr_valid，写数据app_data_wr。并输出
//通过计数器w_cnt生成读地址app_addr_rd，读地址有效信号app_addr_rd_valid。并输出
//读入读数据有效信号app_data_rd_valid，读数据app_data_rd
//验证读数据信号是否与预设的数据是否一致
//写和读数据的传输速率
module ddr_app_demo 
   #
   (
      parameter      WR_NUM        =     32,
      parameter      RD_NUM        =     WR_NUM,
      parameter      ADDR_WIDTH    =     30,
      parameter      DATA_WIDTH    =     32,
      parameter      INIT_DATA     =     32'h00000000,
      parameter      DATA_NUM      =     32'd3200
   )
   (

      //--
      input                                  rst_n,
      //*******************************************
      //--应用接口
      //*******************************************
      input                                  app_clk,             //--App clk
      input                                  app_w_enable,        //--
      input                                  app_r_enable,
      //--Write 
      output   reg[ ADDR_WIDTH-1: 0]         app_addr_wr,
      output   reg                           app_addr_wr_valid,
      output   reg[ DATA_WIDTH-1: 0]         app_data_wr,
      output   reg                           app_data_wr_valid,
      //--Read
      output   reg[ ADDR_WIDTH-1: 0]         app_addr_rd,
      output   reg                           app_addr_rd_valid,
      input       [ DATA_WIDTH-1: 0]         app_data_rd,
      input                                  app_data_rd_valid,
      output                                 triger_app_wr2rd

   );
   
   
   

//************************************************
//--写控制
//************************************************
//--当app_w_enable有效，开始产生写数据计数器，计数器从1计数到WR_NUM+32（64），记满后归0
reg[31:0] app_data_wr_cnt;
reg[9:0] w_cnt;
reg app_wr_enable =1'b1;
always @ (posedge app_clk or negedge rst_n)begin
   if(!rst_n)
      w_cnt <= 10'b0;
   else if(app_data_wr_cnt==DATA_NUM*WR_NUM)begin
      w_cnt <= 10'b0;
      app_wr_enable <= 1'b0;
   end
   else if(w_cnt>=10'd1 && w_cnt <=WR_NUM*2)
      w_cnt <= w_cnt + 1'b1;
   else if(app_w_enable==1'b1 && app_wr_enable==1'b1)
      w_cnt <= 10'd1;
   else 
      w_cnt <= 10'b0;
end

//写计数器在3时，INIT_DATA（32'h1234AB00）给app_data_wr；
//写计数器在4~WR_NUM+2（34）时，拉高app_data_wr_valid，app_data_wr[7:0]+1；app_data_wr[15:8]+1；app_data_wr[23:16]+1；app_data_wr[31:24]+1；
//app_data_wr_valid持续32个时钟周期拉高，即写32个数，3~WR_NUM+2（34）。计数器达到34后，拉低app_data_wr_valid，记满64后再次拉高
reg triger_app_wr2rd;

always @ (posedge app_clk or negedge rst_n)begin
   if(!rst_n)begin
      app_data_wr       <= INIT_DATA;
      app_data_wr_valid <= 1'b0;
      end
   else if(app_data_wr_cnt == DATA_NUM*WR_NUM)begin
      app_data_wr_valid <= 1'b1;
      triger_app_wr2rd  <= 1'b1;
      app_data_wr       <= 32'b0;
      app_data_wr_cnt <= 32'b0;
   end 
   else if(w_cnt>=3 && w_cnt <= WR_NUM+2)begin
      if(w_cnt==3)
           app_data_wr <= app_data_wr+1;  
      else begin
           app_data_wr <= app_data_wr + 1'b1;
         end
      app_data_wr_valid <= 1'b1;
      app_data_wr_cnt <= app_data_wr_cnt + 1'b1;
      end
   else begin
           app_data_wr_valid <=1'b0;
           triger_app_wr2rd  <= 1'b0;
        end
end

//写地址app_addr_wr从0开始写
//当写计数器w_cnt=WR_NUM+3（34）时，即写满32个数据后，写地址app_addr_wr则+WR_NUM（32），并拉高app_addr_wr_valid一个时钟周期
always @ (posedge app_clk or negedge rst_n)begin
   if(!rst_n)begin
      app_addr_wr       <= 30'h0000;
      app_addr_wr_valid <= 1'b0;
      end
   else if(app_data_wr_cnt == DATA_NUM*WR_NUM)begin
      app_addr_wr_valid <=1'b1;
   end 
   else if(w_cnt == WR_NUM+3)begin 
      app_addr_wr       <= app_addr_wr+WR_NUM*4;
      app_addr_wr_valid <=1'b1;
      end
   else begin
      app_addr_wr_valid <=1'b0;
      end
end
//synthesis attribute keep of app_data_wr is true
//synthesis attribute keep of app_addr_wr is true
//************************************************
//--读控制
//************************************************
//--app_r_enable有效 当app_r_enable有效，开始产生读数据计数器，计数器从1计数到RD_NUM（32），记满后归0
reg[31:0]    app_addr_rd_clk_cnt;
reg[9:0]     r_cnt;
reg          app_rd_enable;

always @ (posedge app_clk or negedge rst_n)begin
   if(!rst_n)
      app_rd_enable <= 1'b0;
   else if (triger_app_wr2rd == 1'b1)
      app_rd_enable <= 1'b1;
   else if(app_addr_rd_clk_cnt > DATA_NUM)
      app_rd_enable <= 1'b0;  
end

always @ (posedge app_clk or negedge rst_n)begin
   if(!rst_n)
      r_cnt <= 10'b0;
   else if(app_addr_rd_clk_cnt > DATA_NUM)
      r_cnt <= 10'b0;      
   else if(r_cnt>=10'd1 && r_cnt<=RD_NUM*2)
      r_cnt <= r_cnt + 1'b1;
   else if(app_r_enable==1'b1&& app_rd_enable==1'b1 ) 
      r_cnt <= 10'd1;
   else 
      r_cnt <= 10'b0;
end

//读地址app_addr_rd从0开始写
//当写计数器w_cnt=WR_NUM+32（64）时，读地址app_addr_rd则+RD_NUM（32），并拉高app_addr_rd_valid一个时钟周期
always @ (posedge app_clk or negedge rst_n)begin
   if(!rst_n)begin
      app_addr_rd         <= 30'h0000;
      app_addr_rd_valid   <= 1'b0;
      app_addr_rd_clk_cnt <= 32'd0;
      end 
   else if(r_cnt == 2*RD_NUM )begin
      app_addr_rd         <= app_addr_rd+RD_NUM*4;
      app_addr_rd_valid   <= 1'b1;   
      app_addr_rd_clk_cnt <= app_addr_rd_clk_cnt+1;       
      end
   else begin
      app_addr_rd_valid <=1'b0;
      app_addr_rd         <= app_addr_rd;
      end
end


endmodule 