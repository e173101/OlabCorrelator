//file:shift8_64.v 8位64字RAM-based移位寄存器
//Lai Yongtian 2018-4-3

`define WIDTHofADDR 6

module shiftRam8_64 (
  clk,    //
  rst_n,  //
  
  clr,    //useless, hahaha
  
  din,    //data input
  sin,    //sync signal input
  
  dout,   // data output, (delay of din)
  dshift, // shift data output
  sout    // sync signal output
  );
input clk;
input rst_n;
input clr;

input [7:0] din; 
input sin;          //sample time,

output reg [7:0] dout, dshift;
output reg sout;  //sample time,
reg sout_r1;

(* ramstyle = "M9K" *) reg [7:0] ram[2**`WIDTHofADDR-1:0];
reg [`WIDTHofADDR-1:0] baseAddr, shiftAddr;
wire [7:0] data;

reg		[1:0]state;
parameter Swait = 0, Sshift = 1, Sout = 2;

//init the RAM
integer i;
initial
begin
	for(i=0;i<2**`WIDTHofADDR;i=i+1)
		ram[i] <= 8'd0;
end

always @ ( posedge clk)
    if(sin)
      ram[baseAddr] <= din;
      
assign data = ram[shiftAddr];
 
//state shift
always @ ( posedge clk or negedge rst_n )
if( !rst_n )
  state <= Swait;
else
  case (state)
   Swait: if(sin) state <= Sshift;
          else state <= Swait;
   Sshift: state <= Sout;
   //Stop judge
   Sout : if(shiftAddr + `WIDTHofADDR'd1 == baseAddr) state <= Swait;
          else state <= Sout;
   endcase

//combine: dshift
always @ (state or data)
  case (state)
   Swait:   dshift <= 8'd0;
   Sshift:  dshift <= 8'd0;
   Sout :   dshift <= data;
  endcase

//combine: Address  
always @ ( posedge clk or negedge rst_n )
if( !rst_n )
begin
  baseAddr <= `WIDTHofADDR'd0;
  shiftAddr <= `WIDTHofADDR'd0;
end
else
  case (state)
   Swait: begin baseAddr <= baseAddr; shiftAddr <= baseAddr; end
   Sshift: begin baseAddr <= baseAddr + `WIDTHofADDR'd1; shiftAddr <=  baseAddr + `WIDTHofADDR'd1;end
   Sout : begin baseAddr <= baseAddr; shiftAddr <= shiftAddr + `WIDTHofADDR'd1;end
   endcase

//  combine: data out
always @ ( posedge clk or negedge rst_n )
if( !rst_n )
  dout <= 8'd0;
else
  case (state)
   Swait:   dout <= din;
   Sshift:  dout <= dout;
   Sout:    dout <= dout;
  endcase
   
// signal out: wait 2 phase to sync the wire dout
always @ ( posedge clk or negedge rst_n )
	if( !rst_n )
	  sout <= 0;
	else
  begin
	  sout_r1 <= sin;
	  sout <= sout_r1;
  end
endmodule