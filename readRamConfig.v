//file:tauConfig.v config the mult correlator
//for real final version
//Lai Yongtian 2018-4-7
// 0x1000-0x101F first  Correlator
// 0x2000-0x203F second Correlator
// 0x3000-0x307F third  Correlator
// 0x4000-0x40FF fourth Correlator
// 0x5000-0x51FF fifth  Correlator
module readRamConfig
( 
  RamAddr,
  RamData,
  
  RamAAddr,
  RamAData,
  RamBAddr,
  RamBData,
  RamCAddr,
  RamCData,
  RamDAddr,
  RamDData,
  RamEAddr,
  RamEData,
  );

input     [15:0] RamAddr;
output reg[31:0] RamData;

output  [5:0]   RamAAddr;
input   [31:0]  RamAData;
output  [6:0]   RamBAddr;
input   [31:0]  RamBData;
output  [7:0]   RamCAddr;
input   [31:0]  RamCData;
output  [8:0]   RamDAddr;
input   [31:0]  RamDData;
output  [9:0]   RamEAddr;
input   [31:0]  RamEData;

wire    [3:0]   RamSel;

assign  RamSel = RamAddr[15:12];
  
always@(RamAddr or RamAddr or RamBData or RamCData or RamDData or RamEData)
case(RamSel)
  4'd1: RamData = RamAData;
  4'd2: RamData = RamBData;
  4'd3: RamData = RamCData;
  4'd4: RamData = RamDData;
  4'd5: RamData = RamEData;
  default RamData = 32'hAAAAAAAA;
endcase

assign RamAAddr = RamAddr[4:0];
assign RamBAddr = RamAddr[5:0];
assign RamCAddr = RamAddr[6:0];
assign RamDAddr = RamAddr[7:0];
assign RamEAddr = RamAddr[8:0];

  
endmodule
