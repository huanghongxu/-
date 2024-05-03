//����w_cnt������
//ͨ��������w_cnt����д��ַ app_addr_wr��д��ַ��Ч�ź�app_addr_wr_valid���Լ�д������Ч�ź�app_data_wr_valid��д����app_data_wr�������
//ͨ��������w_cnt���ɶ���ַapp_addr_rd������ַ��Ч�ź�app_addr_rd_valid�������
//�����������Ч�ź�app_data_rd_valid��������app_data_rd
//��֤�������ź��Ƿ���Ԥ��������Ƿ�һ��
//д�Ͷ����ݵĴ�������
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
      //--Ӧ�ýӿ�
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
//--д����
//************************************************
//--��app_w_enable��Ч����ʼ����д���ݼ���������������1������WR_NUM+32��64�����������0
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

//д��������3ʱ��INIT_DATA��32'h1234AB00����app_data_wr��
//д��������4~WR_NUM+2��34��ʱ������app_data_wr_valid��app_data_wr[7:0]+1��app_data_wr[15:8]+1��app_data_wr[23:16]+1��app_data_wr[31:24]+1��
//app_data_wr_valid����32��ʱ���������ߣ���д32������3~WR_NUM+2��34�����������ﵽ34������app_data_wr_valid������64���ٴ�����
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

//д��ַapp_addr_wr��0��ʼд
//��д������w_cnt=WR_NUM+3��34��ʱ����д��32�����ݺ�д��ַapp_addr_wr��+WR_NUM��32����������app_addr_wr_validһ��ʱ������
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
//--������
//************************************************
//--app_r_enable��Ч ��app_r_enable��Ч����ʼ���������ݼ���������������1������RD_NUM��32�����������0
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

//����ַapp_addr_rd��0��ʼд
//��д������w_cnt=WR_NUM+32��64��ʱ������ַapp_addr_rd��+RD_NUM��32����������app_addr_rd_validһ��ʱ������
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