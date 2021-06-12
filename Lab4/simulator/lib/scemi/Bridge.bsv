`ifdef SCEMI_PCIE_VIRTEX5
`ifdef BOARD_ML507
`include "Bridge_VIRTEX5_ML50X.bsv"
`endif
`ifdef BOARD_XUPV5
`include "Bridge_VIRTEX5_ML50X.bsv"
`endif
`endif

`ifdef SCEMI_PCIE_VIRTEX6
`ifdef BOARD_ML605
`include "Bridge_VIRTEX6_ML605.bsv"
`endif
`endif

`ifdef SCEMI_PCIE_DINI
`ifdef BOARD_7002
`include "Bridge_DINI_7002.bsv"
`endif
`ifdef BOARD_7006
`include "Bridge_DINI_7006.bsv"
`endif
`endif

`ifdef SCEMI_TCP
`include "Bridge_TCP.bsv"
`endif

