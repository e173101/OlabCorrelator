//file:tuConfig.v config the mult correlator
//for real final version
//Lai Yongtian 2018-4-17
//
module tauConfig
( 
  clk,
  rst_n,
  din,
  sin,
  dout,
  sout
  );

input clk;
input rst_n;
input [7:0] din;
input sin;

output reg[7:0]dout;
output reg sout;

reg[2:0] cnt;
reg[7:0] sum;
    

always@(posedge clk or negedge rst_n)
  if(!rst_n)begin
  cnt <= 3'd0;
  sum <= 8'd0;
  end
  else
    if (cnt < 3'd3)
      if (sin)begin
        cnt <= cnt + 3'd1;
        sum <= sum + din;
      end
      else begin
        cnt <= cnt;
        sum <= sum;
      end
    else begin
        cnt <= 3'd0;
        sum <= 8'd0;
    end
      
always@(posedge clk or negedge rst_n) 
  if(!rst_n)begin
    sout <= 1'd0;
    dout <= 8'd0;
  end
  else
    if (cnt == 3'd3)begin
      sout <= 1'd1;
      dout <= sum;
    end
    else begin
      sout <= 1'd0;
      dout <= 8'd0;
    end
  
endmodule
