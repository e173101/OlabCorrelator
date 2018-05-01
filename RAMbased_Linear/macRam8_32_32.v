//file: macRam8_32_32.v 8位输入，32位输出RAM-based 乘法器组，一组32个
//Lai Yongtian 2018-4-3

//`define WIDTHofADDR 5

module macRam8_32_32 (
  clk,
  rst_n,
  clr,    //sync clear signal it need 32 clk
  sin,    //mac sig
  A,      //A*B+C A not change while B keep shifting
  B,      //A*B+C B is shift input
  
  read,   //read the ram enable 
  rAddr,  //read address
  rData   //read data
  );

input clk;
input rst_n;
input clr;

//A*B+C=M
input [7:0] A,B; 
wire [31:0] C;
reg [31:0] M;
input sin;  //sample time,

//read
input read;
input [5-1:0] rAddr;
output reg [31:0] rData;

//ram
(* ramstyle = "M9K" *) reg [31:0] ram[2**5-1:0];
reg [5-1:0] addr;

reg		[1:0]state;
parameter Swait = 0, Smac = 1, Sclr = 2, Sread = 3;

//init the RAM
integer i;
initial
begin
	for(i=0;i<2**5;i=i+1)
		ram[i] <= 8'd0;
end

// Read Port 
always @ (posedge clk) rData <= C;

//state shift  
always @ ( posedge clk or negedge rst_n )
if( !rst_n )
  state <= Swait;
else
  case (state)
   Swait: if(sin) state <= Smac;
          else 
            if(clr) state <= Sclr;
            else
              if (read) state <= Sread;
              else    state <= Swait;
   Smac:  if(addr + 5'd1 == 5'd0) state <= Swait;
          else state <= Smac;
   Sclr:  if(addr + 5'd1 == 5'd0) state <= Swait;
          else state <= Sclr;
   Sread: if (read) state <= Sread;
              else    state <= Swait;
   endcase
   
//ram mac
always @ ( posedge clk)
  if(state == Smac || state == Sclr)
      ram[addr] <= M;
assign C = ram[addr];	 

//combine: addr
always @ ( posedge clk or negedge rst_n )
if( !rst_n )
  addr <= 5'd0;
else
  case (state)
   Swait: addr <= 5'd0;
   Smac: addr <= addr + 5'd1;
   Sclr : addr <= addr + 5'd1;
   Sread : addr <= rAddr;
  endcase

//combine: Mac
always @ (state or A or B or C)
	begin
			case (state)
			  Swait:  M <= A*B+C;
        Smac:   M <= A*B+C;
        Sclr :  M <= 31'd0;
        Sread:  M <= A*B+C;
			endcase
	end
  
endmodule
