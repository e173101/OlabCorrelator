//file:correlatorMult.v core of the mult-tau correlator
//
//1.three mode: 
//start: shift:shift the intut data; 	mac:work
//stop:	shift:pause 						mac:pause
//clr:	shift:shift	the input	 		max:fflush the data	(fflush need shift sig so don't stop the shift
//
//2.There are five linear Correlators in one chip the address of result
// 0x1000-0x101F first  Correlator
// 0x2000-0x203F second Correlator
// 0x3000-0x307F third  Correlator
// 0x4000-0x40FF fourth Correlator
// 0x5000-0x51FF fifth  Correlator
//
//3.In this version, frequency of the corrData, corrSig & corrClr must less than:
// 1/32 of the clk
//Lai Yongtian 2018-4-18 : Real final version before my graduation

module correlatorMulti
(
	clk, 
	rst_n, 

	corrData,   //correlate data
	corrSig,    //correlate data signal
	corrStart,	//start sig
	corrStop,	//stop sig
	corrClr,    //out put

	read,       //1:Enable the output of RamData 0:It will stop the whole correlator!
	RamAddr,   
	RamData
);

input           clk;
input           rst_n;

input   [7:0]   corrData;
input           corrSig;
input				 corrStart;
input				 corrStop;
input           corrClr;

input           read;
input   [15:0]  RamAddr;
output  [31:0]  RamData;

//the wire TauConfig(T) to Shift(S) _TS
wire [7:0]  corrAdataTS, corrBdataTS, corrCdataTS, corrDdataTS, corrEdataTS;
wire        corrASigTS, corrBSigTS, corrCSigTS, corrDSigTS, corrESigTS;

//the wire Shift(S) to Mac(M) _SM
wire        CorrAsigSM, CorrBsigSM, CorrCsigSM, CorrDsigSM, CorrEsigSM;
wire [7:0]  CorrAdataASM, CorrBdataASM, CorrCdataASM, CorrDdataASM, CorrEdataASM;
wire [7:0]  CorrAdataBSM, CorrBdataBSM, CorrCdataBSM, CorrDdataBSM, CorrEdataBSM;

//Five correlators have five difference size
wire [4:0] RamAAddr;
wire [5:0] RamBAddr;
wire [6:0] RamCAddr;
wire [7:0] RamDAddr;
wire [8:0] RamEAddr;
wire [31:0] RamAData,RamBData,RamCData,RamDData,RamEData;

/*
*   five correlators have five different tau
*   A 1us
*   B 3us
*   C 9us
*   D 27us
*   E 81us
*/
//The first config the start and stop, not the interval
startStopConfig uFirstTau( 
  .clk			(clk),
  .rst_n			(rst_n),
  .start			(corrStart),
  .stop			(corrStop),
  .clr			(corrClr),
  .din			(corrData),
  .sin			(corrSig),		
  .dout			(corrAdataTS),
  .sout			(corrASigTS)
  );

//Second difference from first, just config the interval of tau
tauConfig uTauB ( 
	.clk         (clk),
	.rst_n       (rst_n),
	.din         (corrAdataTS),
	.sin         (corrASigTS),
	.dout        (corrBdataTS),
	.sout        (corrBSigTS)
);
//3rd, 4th & 5th correlator tau
//Same port as aboout        xxxx_xxxxxx,  xxxx_xxxxx, xxxx_xxxxxx,  xxxx_xxxxx
tauConfig uTauC (clk,rst_n,  corrBdataTS,  corrBSigTS, corrCdataTS,  corrCSigTS);
tauConfig uTauD (clk,rst_n,  corrCdataTS,  corrCSigTS, corrDdataTS,  corrDSigTS);
tauConfig uTauE (clk,rst_n,  corrDdataTS,  corrDSigTS, corrEdataTS,  corrESigTS);

/*
* Sifft x 5
* Input From uTauA to E
*/
//First shift
shiftRam8_32 uShiftA(
	.clk          (clk),
	.rst_n        (rst_n),
	.clr          (corrClr),           
	.din          (corrAdataTS),
	.sin          (corrASigTS),
	.dout         (CorrAdataASM),      
	.dshift       (CorrAdataBSM),      
	.sout         (CorrAsigSM)         
);
//2nd, 3rd, 4th & 5th Same port as about
shiftRam8_64    uShiftB(clk,rst_n,corrClr,  corrBdataTS,  corrBSigTS, CorrBdataASM, CorrBdataBSM, CorrBsigSM);
shiftRam8_128   uShiftC(clk,rst_n,corrClr,  corrCdataTS,  corrCSigTS, CorrCdataASM, CorrCdataBSM, CorrCsigSM);
shiftRam8_256   uShiftD(clk,rst_n,corrClr,  corrDdataTS,  corrDSigTS, CorrDdataASM, CorrDdataBSM, CorrDsigSM);
shiftRam8_512   uShiftE(clk,rst_n,corrClr,  corrEdataTS,  corrESigTS, CorrEdataASM, CorrEdataBSM, CorrEsigSM);

/*
* Multiply-accumulater (RAM-based) x 5
* Attention! their difference size!
*/
//First MAC
macRam8_32_32 uMacA(
	.clk          (clk),
	.rst_n        (rst_n),
	.clr          (corrClr),     
	.sin          (CorrAsigSM),  
	.A            (CorrAdataASM),
	.B            (CorrAdataBSM),
	.read         (read),
	.rAddr        (RamAAddr),
	.rData        (RamAData)
);
//2nd, 3rd, 4th & 5th MAC
macRam8_32_64   uMacB(clk,rst_n,corrClr,  CorrBsigSM, CorrBdataASM, CorrBdataBSM, read, RamBAddr, RamBData);
macRam8_32_128  uMacC(clk,rst_n,corrClr,  CorrCsigSM, CorrCdataASM, CorrCdataBSM, read, RamCAddr, RamCData);
macRam8_32_256  uMacD(clk,rst_n,corrClr,  CorrDsigSM, CorrDdataASM, CorrDdataBSM, read, RamDAddr, RamDData);
macRam8_32_512  uMacE(clk,rst_n,corrClr,  CorrEsigSM, CorrEdataASM, CorrEdataBSM, read, RamEAddr, RamEData);

/*
*   Out Put of the five Correlators
*/ 

readRamConfig uReadRam
( 
	.RamAddr        (RamAddr),
	.RamData        (RamData),
	.RamAAddr       (RamAAddr),
	.RamAData       (RamAData),
	.RamBAddr       (RamBAddr),
	.RamBData       (RamBData),
	.RamCAddr       (RamCAddr),
	.RamCData       (RamCData),
	.RamDAddr       (RamDAddr),
	.RamDData       (RamDData),
	.RamEAddr       (RamEAddr),
	.RamEData       (RamEData)
);


endmodule
