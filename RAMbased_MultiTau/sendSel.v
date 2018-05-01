//file: sendSel.v send RAM to PC using UART
//after a read signal, upload data in RAM to PC
//Lai Yongtian 2018-4-8

`define RAMASTARTADDR 16'h1000
`define RAMBSTARTADDR 16'h2000
`define RAMCSTARTADDR 16'h3000
`define RAMDSTARTADDR 16'h4000
`define RAMESTARTADDR 16'h5000
`define RAMAENDADDR   16'h101F
`define RAMBENDADDR   16'h203F
`define RAMCENDADDR   16'h307F
`define RAMDENDADDR   16'h40FF
`define RAMEENDADDR   16'h51FF

module sendSel(
	clk,
	rst_n,
	//command
  corrTest,				  //Test signal
  corrReadCF,			  //Read Correlation function signal, It contain the CPS and sample count	2018-1-4
  corrReadSetting,	//Read Setting Now been set signal
  corrReadCps,			//Read CPS signal
  //Reg data
  setting,				  //The Setting
  cps,					    //Pohtons per second
  sampleCnt,			  //Sample count
  //Ram data
	CFRead,           //CF = Correlation fuction
	CFAddr,   
	CFData,						
	//Uart  
  rs232_tx,
  ok
			);

input clk;		// 50MHz主时钟
input rst_n;	//低电平复位信号

input  corrTest;  //A
input  corrReadCps; //B
input  corrReadCF;  //C
input  corrReadSetting; //C

//要发送的数据， reg
input [127:0] setting;
input [31:0]  sampleCnt;
input [31:0]  cps;
//RAM
output CFRead;
output [15:0] CFAddr;
input [31:0] CFData;
//uart
output rs232_tx;
output ok;

/*****************************************/
//Inside module

reg flagTest,flagRAMA,flagRAMB,flagRAMC,flagRAMD,flagRAME;
reg send;

reg [15:0]  startAddr, endAddr;
reg [31:0]  data;
wire uartOK;

//state
reg		[8:0]state;
parameter Sidle = 0, SwaitUart = 1,  Ssend = 2,
          Stest = 4,SRAMA = 5, SRAMB = 6,SRAMC = 7,SRAMD = 8,SRAME = 9;

//state  
always @ ( posedge clk or negedge rst_n )
if( !rst_n )
  state <= Sidle;
else
  case (state)
   Sidle: if(flagTest) state <= Stest; else
          if(flagRAMA) state <= SRAMA; else
          if(flagRAMB) state <= SRAMB; else
          if(flagRAMC) state <= SRAMC; else
          if(flagRAMD) state <= SRAMD; else
          if(flagRAME) state <= SRAME; else state <= Sidle;
   Stest: state <= Ssend;
   SRAMA: state <= Ssend;
   SRAMB: state <= Ssend;
   SRAMC: state <= Ssend;
   SRAMD: state <= Ssend;
   SRAME: state <= Ssend;
   Ssend: state <= SwaitUart;
   SwaitUart: if(uartOK) state <= Sidle; else state <= SwaitUart;
   default: state <= Sidle;
   endcase

//flag
// Set & Clr
always @ ( posedge clk or negedge rst_n )
if( !rst_n ) begin
  flagTest = 0;
  flagRAMA = 0;
  flagRAMB = 0;
  flagRAMC = 0;
  flagRAMD = 0;
  flagRAME = 0;
end
else
  case (state)
   default begin 
            flagTest = flagTest;
            flagRAMA = flagRAMA;
            flagRAMB = flagRAMB;
            flagRAMC = flagRAMC;
            flagRAMD = flagRAMD;
            flagRAME = flagRAME;
           end
   Sidle: begin
            if(corrTest) flagTest = 1;
            if(corrReadCF) begin flagRAMA = 1; flagRAMB = 1;flagRAMC = 1;flagRAMD = 1;flagRAME = 1;       end
          end
   Stest: flagTest = 0;
   SRAMA: flagRAMA = 0;
   SRAMB: flagRAMB = 0;
   SRAMC: flagRAMC = 0;
   SRAMD: flagRAMD = 0;
   SRAME: flagRAME = 0;
  endcase
  
//Ram Reg
//Addr
always @ ( posedge clk or negedge rst_n )
if( !rst_n )
  begin startAddr = 16'd0; endAddr = 16'd0; end
else
  case (state)
    default:    begin startAddr = startAddr;        endAddr = endAddr;      end
    Stest:      begin startAddr = 16'd0;            endAddr = 16'd0;        end
    SRAMA:      begin startAddr = `RAMASTARTADDR;   endAddr = `RAMAENDADDR; end
    SRAMB:      begin startAddr = `RAMBSTARTADDR;   endAddr = `RAMBENDADDR; end
    SRAMC:      begin startAddr = `RAMCSTARTADDR;   endAddr = `RAMCENDADDR; end
    SRAMD:      begin startAddr = `RAMDSTARTADDR;   endAddr = `RAMDENDADDR; end
    SRAME:      begin startAddr = `RAMESTARTADDR;   endAddr = `RAMEENDADDR; end
  endcase
  
//combine
//send
always @ (state)
  case (state)
   default: send <= 0;
   Ssend:   send <= 1;
  endcase

//combine
//data
always @ (startAddr or CFData)
  case (startAddr)
    default:  			data <= 32'haaaaaaaa;
    16'd0:    			data <= 32'h00134b4f;//OK\r
    `RAMASTARTADDR: data <= CFData;
    `RAMBSTARTADDR: data <= CFData;
    `RAMCSTARTADDR: data <= CFData;
    `RAMDSTARTADDR: data <= CFData;
    `RAMESTARTADDR: data <= CFData;
  endcase
                           
//RAM                      
sendRam32_0xFFFF_ToPC uUart(
	.clk             (clk),
	.rst_n           (rst_n),
  .sendSig         (send),      // signal to send
  .startAddr       (startAddr), //  startAddress
  .endAddr         (endAddr),   // endAddress
	
	.read            (CFRead),
	.addr            (CFAddr),
	.data            (data), //data to send
  .rs232_tx        (rs232_tx),
  .ok              (uartOK)
			);

endmodule
