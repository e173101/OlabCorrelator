//file:correlatorMult_tb.v 多延迟时间相关器的测试文件
//for real final version
//Lai Yongtian 2018-4-6
`timescale 1ns/1ns

module correlatorMulti_tb();

  reg clk;
  reg rst_n;
  
  reg [7:0] corrData;
  reg corrSig;
  
	reg corrStart;
	reg corrStop;
	reg corrClr;
  
  reg [15:0]RamAddr;
  reg read;
  
  reg [8:0] cnt = 0;
  
  wire[31:0] RamData;
  
correlatorMulti utest
(
	clk, 
	rst_n, 
  
  corrData,   //correlate data
	corrSig,    //correlate data signal
    
	corrClr,    //out put
  
  read,
  RamAddr,   
  RamData
	);

initial 
begin
  clk = 1;
  rst_n = 0;
  corrStart = 0;
  corrStop = 0;
  corrClr = 0;
  corrData = 8'd0;
  RamAddr = 16'd0;
  read = 0;
#77 rst_n = 1;
#200 corrClr = 1;
#210 corrClr = 0;
#30000 read = 1;
      RamAddr = 16'h1008;
      
#20 read = 0;
#6000 read = 1;
#20 read = 0;
end

always begin
  #5 
  clk = ~clk;
end  

always@(posedge clk)
  if(cnt < 8'd50) cnt <= cnt + 8'd1;
  else cnt <= 8'd0;

always@(posedge clk) if (cnt == 8'd49) begin
  corrSig = 1; corrData = $random%256;
  end 
 else 
  begin
  corrSig = 0; corrData = 8'd0;
end  



endmodule
