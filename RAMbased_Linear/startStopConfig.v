//file:startStopConfig.v config is the correlator data available
//for real final version
//
//Lai Yongtian 2018-4-18
//
module startStopConfig
( 
  clk,
  rst_n,
  start,
  stop,
  clr,
  din,
  sin,
  dout,
  sout
  );

input clk;
input rst_n;

input start;
input stop;
input clr;

input [7:0] din;
input sin;

output [7:0]dout;
output sout;

reg enable;	//1:ok 2:nonono
    

always@(posedge clk or negedge rst_n)
  if(!rst_n)
	enable = 0;
	else if(clr)
	enable = 1;
	else if(stop)
		enable = 0;
		else if(start)
		 enable = 1;
		  else
		   enable = enable;

//assign dout=enable?din:8'd0; is unnecessary
assign dout = din;
assign sout = enable?sin:1'd0;
  
endmodule
