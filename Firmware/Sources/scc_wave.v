//--------------------------------------------------------------
//  Title     : scc_wave.v
//  Function  : Sound Creation Chip (KONAMI)
//  Date      : 28th,August,2000
//  Revision  : 1.01
//  Author    : Kazuhiro TSUJIKAWA (ESE Artists' factory)
//--------------------------------------------------------------

module scc_wave(
  input wire pSltClk_n,
  input wire pSltRst_n,
  input wire [7:0] pSltAdr,
  inout wire [7:0] pSltDat,
  output reg [10:0] SccAmp,
  input wire SccRegWe,
  input wire SccModWe,
  input wire SccWavCe,
  input wire SccWavOe,
  input wire SccWavWe,
  input wire SccWavWx,
  input wire [4:0] SccWavAdr,
  input wire [7:0] SccWavDat,
  input wire DOutEn_n,
  input wire [7:0] DOut
);

  // Wave memory control
  wire WaveWe;
  wire [7:0] WaveAdr;
  wire [7:0] iWaveDat;
  wire [7:0] oWaveDat;

  // SCC resisters
  reg [11:0] SccFreqChA;
  reg [11:0] SccFreqChB;
  reg [11:0] SccFreqChC;
  reg [11:0] SccFreqChD;
  reg [11:0] SccFreqChE;
  reg [3:0] SccVolChA;
  reg [3:0] SccVolChB;
  reg [3:0] SccVolChC;
  reg [3:0] SccVolChD;
  reg [3:0] SccVolChE;
  reg [4:0] SccChanSel;
  reg [7:0] SccModeSel;

  // SCC temporaries
  reg SccRstChA;
  reg SccRstChB;
  reg SccRstChC;
  reg SccRstChD;
  reg SccRstChE;
  wire [4:0] SccPtrChA;
  wire [4:0] SccPtrChB;
  wire [4:0] SccPtrChC;
  wire [4:0] SccPtrChD;
  wire [4:0] SccPtrChE;
  reg [2:0] SccClkEna;
  reg SccChEna;
  reg [2:0] SccChNum;

  // SCC Mixer temporaries
  wire SccMixSel;
  wire [3:0] SccMixVol;
  wire [7:0] SccMixDat;
  wire [14:0] SccMixMul;
  wire [14:0] SccMixOut;
  reg [14:0] SccMix;

  //--------------------------------------------------------------
  // Misceracle control
  //--------------------------------------------------------------
  always @( posedge pSltClk_n, negedge pSltRst_n ) begin
    if ( pSltRst_n == 1'b0 ) begin
      SccClkEna <= 3'b000;
      SccChNum <= 3'b000;
    end else begin
      // Clock Enable (clock divider)
      SccClkEna <= SccClkEna + 3'b001;
      if ( SccClkEna == 3'b111 ) begin
        SccChNum <= 3'b000;
      end
      else if ( SccChEna == 1'b1 ) begin
        SccChNum <= SccChNum + 3'b001;
      end
    end
  end

  //--------------------------------------------------------------
  // Wave memory control
  //--------------------------------------------------------------
  assign WaveAdr = SccWavCe == 1'b1   ? pSltAdr[7:0]
                 : SccWavWx == 1'b1   ? {3'b100,SccWavAdr}
                 : SccChNum == 3'b000 ? {3'b000,SccPtrChA}
                 : SccChNum == 3'b001 ? {3'b001,SccPtrChB}
                 : SccChNum == 3'b010 ? {3'b010,SccPtrChC}
                 : SccChNum == 3'b011 ? {3'b011,SccPtrChD}
                 :                      {3'b100,SccPtrChE};
  assign iWaveDat = SccWavWx == 1'b0 ? pSltDat : SccWavDat;
  assign WaveWe = SccWavWe | SccWavWx;
  ram WaveMem(
    WaveAdr,
    pSltClk_n,
    WaveWe,
    iWaveDat,
    oWaveDat
  );

  assign pSltDat = SccWavOe == 1'b1 ? oWaveDat : DOutEn_n == 1'b0 ? DOut : {8{1'bZ}};

  always @( posedge pSltClk_n, negedge pSltRst_n ) begin

    if(pSltRst_n == 1'b0) begin

      SccChEna <= 1'b0;

    end else begin

      SccChEna <= ~(SccWavCe | SccWavWx);

    end
  end

  //--------------------------------------------------------------
  // SCC resister access
  //--------------------------------------------------------------
  always @( posedge pSltClk_n, negedge pSltRst_n ) begin
    if ( pSltRst_n == 1'b0 ) begin
      SccFreqChA <= 12'd0;
      SccFreqChB <= 12'd0;
      SccFreqChC <= 12'd0;
      SccFreqChD <= 12'd0;
      SccFreqChE <= 12'd0;
      SccVolChA <= 4'd0;
      SccVolChB <= 4'd0;
      SccVolChC <= 4'd0;
      SccVolChD <= 4'd0;
      SccVolChE <= 4'd0;
      SccChanSel <= 5'd0;
    end else begin
      // Mapped I/O port access on 9880-988Fh / B8A0-B8AF ... Resister write
      if ( SccRegWe == 1'b1 ) begin
        case(pSltAdr[3:0])
        4'b0000 : begin
          SccFreqChA[7:0] <= pSltDat[7:0];
        end
        4'b0001 : begin
          SccFreqChA[11:8] <= pSltDat[3:0];
        end
        4'b0010 : begin
          SccFreqChB[7:0] <= pSltDat[7:0];
        end
        4'b0011 : begin
          SccFreqChB[11:8] <= pSltDat[3:0];
        end
        4'b0100 : begin
          SccFreqChC[7:0] <= pSltDat[7:0];
        end
        4'b0101 : begin
          SccFreqChC[11:8] <= pSltDat[3:0];
        end
        4'b0110 : begin
          SccFreqChD[7:0] <= pSltDat[7:0];
        end
        4'b0111 : begin
          SccFreqChD[11:8] <= pSltDat[3:0];
        end
        4'b1000 : begin
          SccFreqChE[7:0] <= pSltDat[7:0];
        end
        4'b1001 : begin
          SccFreqChE[11:8] <= pSltDat[3:0];
        end
        4'b1010 : begin
          SccVolChA[3:0] <= pSltDat[3:0];
        end
        4'b1011 : begin
          SccVolChB[3:0] <= pSltDat[3:0];
        end
        4'b1100 : begin
          SccVolChC[3:0] <= pSltDat[3:0];
        end
        4'b1101 : begin
          SccVolChD[3:0] <= pSltDat[3:0];
        end
        4'b1110 : begin
          SccVolChE[3:0] <= pSltDat[3:0];
        end
        default : begin
          SccChanSel[4:0] <= pSltDat[4:0];
        end
        endcase
      end
    end
  end

  always @( posedge pSltClk_n, negedge pSltRst_n ) begin
    if ( pSltRst_n == 1'b0 ) begin
      SccModeSel <= 8'd0;
    end else begin
      // Mapped I/O port access on 98C0-98FFh / B8C0-B8DFh ... Resister write
      if ( SccModWe == 1'b1 ) begin
        SccModeSel <= pSltDat;
      end
    end
  end

  always @( posedge pSltClk_n, negedge pSltRst_n ) begin
    if ( pSltRst_n == 1'b0 ) begin
      SccRstChA <= 1'b0;
      SccRstChB <= 1'b0;
      SccRstChC <= 1'b0;
      SccRstChD <= 1'b0;
      SccRstChE <= 1'b0;
    end else begin
      // Mapped I/O port access on 9880-988Fh / B8A0-B8AF ... Resister write
      if ( SccRegWe & SccModeSel[5] == 1'b1 ) begin
        case(pSltAdr[3:1])
        3'b000 : begin
          SccRstChA <= 1'b1;
        end
        3'b001 : begin
          SccRstChB <= 1'b1;
        end
        3'b010 : begin
          SccRstChC <= 1'b1;
        end
        3'b011 : begin
          SccRstChD <= 1'b1;
        end
        3'b100 : begin
          SccRstChE <= 1'b1;
        end
        endcase
      end
      else begin
        SccRstChA <= 1'b0;
        SccRstChB <= 1'b0;
        SccRstChC <= 1'b0;
        SccRstChD <= 1'b0;
        SccRstChE <= 1'b0;
      end
    end
  end

  //--------------------------------------------------------------
  // Tone generator
  //--------------------------------------------------------------
  scc_phasegenerator pgChA( pSltClk_n, pSltRst_n, SccRstChA, SccFreqChA, SccPtrChA );
  scc_phasegenerator pgChB( pSltClk_n, pSltRst_n, SccRstChB, SccFreqChB, SccPtrChB );
  scc_phasegenerator pgChC( pSltClk_n, pSltRst_n, SccRstChC, SccFreqChC, SccPtrChC );
  scc_phasegenerator pgChD( pSltClk_n, pSltRst_n, SccRstChD, SccFreqChD, SccPtrChD );
  scc_phasegenerator pgChE( pSltClk_n, pSltRst_n, SccRstChE, SccFreqChE, SccPtrChE );

  //--------------------------------------------------------------
  // Mixer control
  //--------------------------------------------------------------
  assign SccMixSel = SccChNum == 3'b001 ? SccChanSel[0]
                   : SccChNum == 3'b010 ? SccChanSel[1]
                   : SccChNum == 3'b011 ? SccChanSel[2]
                   : SccChNum == 3'b100 ? SccChanSel[3]
                   : SccChNum == 3'b101 ? SccChanSel[4]
                   : 1'b0;

  assign SccMixVol = SccChNum == 3'b001 ? SccVolChA
                   : SccChNum == 3'b010 ? SccVolChB
                   : SccChNum == 3'b011 ? SccVolChC
                   : SccChNum == 3'b100 ? SccVolChD
                   : SccChNum == 3'b101 ? SccVolChE
                   : 4'b0000;

  // Signed multiplier is used on real chip, but unsigned multiplier is required by mcscc module.It may causes bias with zero-point.
  assign SccMixDat = { (SccMixSel & oWaveDat[7]) ^ 1'b1, { 7{ SccMixSel } } & oWaveDat[6:0] };

  assign SccMixMul = $signed( { 1'b0, SccMixDat } ) * $signed( { 1'b0, SccMixVol } );
  assign SccMixOut = SccMix + SccMixMul;

  always @( posedge pSltClk_n, negedge pSltRst_n ) begin

    if(pSltRst_n == 1'b0) begin

      SccMix <= 15'd0;
      SccAmp <= 11'd0;

    end else begin

      if ( SccClkEna == 3'b111 ) begin
        SccAmp <= SccMix[14:4];
      end

      if ( SccChNum == 3'b000 ) begin 
        SccMix <= 15'd0;
      end else if ( SccChEna == 1'b1 ) begin
        SccMix <= SccMixOut;
      end

    end
  end

endmodule

//--------------------------------------------------------------
// Phase generator module
//--------------------------------------------------------------
module scc_phasegenerator(
  input wire pSltClk_n,
  input wire pSltRst_n,
  input wire SccRst,
  input wire [11:0] SccFreq,
  output wire [4:0] SccPtr
);

  wire SccCntReload;
  wire SccPtrInc;

  reg [11:0] SccCntCh;
  reg [4:0] SccPtrCh;

  assign SccPtr = SccPtrCh;

  assign SccCntReload = (SccFreq[11:3] == 9'b000000000) || (SccRst == 1'b1);
  assign SccPtrInc = (SccCntCh == 12'b000000000000);

  always @( posedge pSltClk_n, negedge pSltRst_n ) begin

    if ( pSltRst_n == 1'b0 ) begin
      SccPtrCh <= 5'd0;
      SccCntCh <= 12'd0;
    end else begin

      if ( SccCntReload == 1'b1 ) begin
        SccPtrCh <= 5'd0;
        SccCntCh <= SccFreq;
      end

      else if ( SccPtrInc == 1'b1 ) begin
        SccPtrCh <= SccPtrCh + 5'd1;
        SccCntCh <= SccFreq;
      end

      else begin
        SccCntCh <= SccCntCh - 12'd1;
      end
    end
  end

endmodule
