//file:sendRam32_0xFFFF_ToPC_tb.v
//dend startAddr to endAddr using the uart to PC
//Lai Yongtian 2018-4-7
`timescale 1ns/1ns
`define WIDTHofADDR 16  //0xFFFF

module sendRam32_0xFFFF_ToPC_tb();

      
/*You need define there par outside this file
`define SENDWORD 48
`define SENDWIDTH `SENDWORD*8
`define WIDTHofSNEDWORDCTN 10
*/
      
reg clk;		// 100MHz主时钟
reg rst_n;	//低电平复位信号
reg sendSig;	//发一拍
reg [`WIDTHofADDR-1:0] startAddr;
reg [`WIDTHofADDR-1:0] endAddr;
reg [31:0]data; //
wire read;
wire [`WIDTHofADDR-1:0] addr;
wire  rs232_tx;
wire ok;


sendRam32_0xFFFF_ToPC uTest(
	clk,
	rst_n,
  sendSig,    // signal to send
  startAddr,  //  startAddr
  endAddr,    // endAddrs
	
	read,
	addr,
	data, //data to send
  rs232_tx,
  ok
			);
      
      
initial 
begin
  clk = 1;
  rst_n = 0;
  startAddr = 16'h1000;
  endAddr = 16'h100F;
  
  data = $random;
  sendSig = 0;
#100 rst_n = 1;
#10005 sendSig = 1;
#20 sendSig = 0;

end

always begin
  #5 
  clk = ~clk;
end  


endmodule
