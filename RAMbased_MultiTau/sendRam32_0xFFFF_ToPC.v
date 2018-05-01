//file:sendRam32_0xFFFF_ToPC.v
//dend startAddr to endAddr using the uart to PC
//Lai Yongtian 2018-4-18
//0xFFFF

module sendRam32_0xFFFF_ToPC(
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
      
/*You need define there par outside this file
`define SENDWORD 48
`define SENDWIDTH `SENDWORD*8
`define WIDTHofSNEDWORDCTN 10
*/
      
input clk;		// 100MHz主时钟
input rst_n;	//低电平复位信号
input sendSig;	//发一拍
input [15:0] startAddr;
input [15:0] endAddr;
input [31:0]data; //

output reg read;
output reg [15:0] addr;
output rs232_tx;
output reg ok;

reg oneByteSend       = 0;
reg [7:0] data8bit    = 8'd0;
wire oneByteOk;

parameter Swait = 0,
  Ssend1 = 1, SwaitSendOver1=2, 
  Ssend2 = 3, SwaitSendOver2=4, 
  Ssend3 = 5, SwaitSendOver3=6, 
  Ssend4 = 7, SwaitSendOver4=8, 
  SnextAddr=9, Send = 10;
reg		[4:0]state      = Swait;

//state machine
always @ ( posedge clk or negedge rst_n)
if( !rst_n )
  state <= Swait;
else
  case (state)
   Swait: if(sendSig) state <= Ssend1;         
          else state <= Swait;
   Ssend1: state <= SwaitSendOver1;
   SwaitSendOver1: if(oneByteOk)  state <= Ssend2;
          else state <= SwaitSendOver1;
   Ssend2: state <= SwaitSendOver2;
   SwaitSendOver2: if(oneByteOk)  state <= Ssend3;
          else state <= SwaitSendOver2;
   Ssend3: state <= SwaitSendOver3;
   SwaitSendOver3: if(oneByteOk)  state <= Ssend4;
          else state <= SwaitSendOver3;
   Ssend4: state <= SwaitSendOver4;
   SwaitSendOver4: if(oneByteOk)  state <= SnextAddr;
          else state <= SwaitSendOver4;
   SnextAddr: if(addr != endAddr) state <= Ssend1;
          else state <= Send;
   Send:  state <= Swait;
   endcase
				
//
always @ ( posedge clk or negedge rst_n )
if( !rst_n )
  addr <= 16'd0;
else
  case (state)
   Swait: addr <= startAddr;
   Ssend1: addr <= addr;
   SwaitSendOver1: addr <=  addr;
   Ssend2: addr <= addr;
   SwaitSendOver2: addr <=  addr;
   Ssend3: addr <= addr;
   SwaitSendOver3: addr <=  addr;
   Ssend4: addr <= addr;
   SwaitSendOver4: addr <=  addr;
   SnextAddr: addr <= addr + 16'd1;
   Send: addr <= addr;
   endcase
   
   //combine
always @ (state)
  case (state)
   default:          oneByteSend <= 1'd0;
   Ssend1:           oneByteSend <= 1'd1;
   Ssend2:           oneByteSend <= 1'd1;
   Ssend3:           oneByteSend <= 1'd1;
   Ssend4:           oneByteSend <= 1'd1;
  endcase
  
always @ (state)
  case (state)
   default:          ok <= 1'd0;
   Send:             ok <= 1'd1;
  endcase

always @ (state or data8bit or data)
  case (state)
   default:           data8bit <= 8'd0;
   Ssend1:            data8bit <= data[7:0];
   SwaitSendOver1:    data8bit <= data[7:0];
   Ssend2:            data8bit <= data[15:8];
   SwaitSendOver2:    data8bit <= data[15:8];
   Ssend3:            data8bit <= data[23:16];
   SwaitSendOver3:    data8bit <= data[23:16];
   Ssend4:            data8bit <= data[31:24];
   SwaitSendOver4:    data8bit <= data[31:24];
  endcase
  
always @ (state or data8bit)
  case (state)
   default:           read <= 1'd0;
   Ssend1:            read <= 1'd1;
   SwaitSendOver1:    read <= 1'd1;
   Ssend2:            read <= 1'd1;
   SwaitSendOver2:    read <= 1'd1;
   Ssend3:            read <= 1'd1;
   SwaitSendOver3:    read <= 1'd1;
   Ssend4:            read <= 1'd1;
   SwaitSendOver4:    read <= 1'd1;
  endcase

uart_tx uuartt( 
			.clk(clk),
			.rst_n(rst_n),
			.tx_data(data8bit),
			.tx_int(oneByteSend),
			.tx_ok(oneByteOk),
			.rs232_tx(rs232_tx)
			);

endmodule
