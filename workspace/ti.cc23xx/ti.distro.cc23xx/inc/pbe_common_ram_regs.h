// ===========================================================================
// This file is autogenerated, please DO NOT modify!
//
// Generated on  2024-04-04 15:06:12
// by user:      developer
// on machine:   swtools
// CWD:          /home/developer/.conan/data/loki-lrf/8.10.00.20/library-lprf/ga/build/0c46501566d33cb4afdce9818f8c3e61ffe04c9a/build/lrfbledig/iar/pbe/common
// Commandline:  /home/developer/.conan/data/loki-lrf/8.10.00.20/library-lprf/ga/build/0c46501566d33cb4afdce9818f8c3e61ffe04c9a/lrfbledig/../tools/topsm/regtxtconv.pl -x /home/developer/.conan/data/f65lokilrfbledig/1.3.19-1/library-lprf/eng/package/5ab84d6acfe1f23c4fae0ab88f26e3a396351ac9/source/ti.com_LOKI_LRFBLEDIG_1.0.xml -f acr --devices CC2340R5:B (2.0) /home/developer/.conan/data/loki-lrf/8.10.00.20/library-lprf/ga/build/0c46501566d33cb4afdce9818f8c3e61ffe04c9a/lrfbledig/pbe/common/doc/pbe_common_ram_regs.txt
// C&P friendly: /home/developer/.conan/data/loki-lrf/8.10.00.20/library-lprf/ga/build/0c46501566d33cb4afdce9818f8c3e61ffe04c9a/lrfbledig/../tools/topsm/regtxtconv.pl -x /home/developer/.conan/data/f65lokilrfbledig/1.3.19-1/library-lprf/eng/package/5ab84d6acfe1f23c4fae0ab88f26e3a396351ac9/source/ti.com_LOKI_LRFBLEDIG_1.0.xml -f acr --devices CC2340R5:B (2.0) /home/developer/.conan/data/loki-lrf/8.10.00.20/library-lprf/ga/build/0c46501566d33cb4afdce9818f8c3e61ffe04c9a/lrfbledig/pbe/common/doc/pbe_common_ram_regs.txt
//
// Relevant file version(s):
//
// /home/developer/.conan/data/loki-lrf/8.10.00.20/library-lprf/ga/build/0c46501566d33cb4afdce9818f8c3e61ffe04c9a/lrfbledig/../tools/topsm/regtxtconv.pl
//   rcs-info: (file not managed or unknown revision control system)
//   git-hash: 68a752a8737845355f7bdb320d25a59eac685840
//
// /home/developer/.conan/data/loki-lrf/8.10.00.20/library-lprf/ga/build/0c46501566d33cb4afdce9818f8c3e61ffe04c9a/lrfbledig/pbe/common/doc/pbe_common_ram_regs.txt
//   rcs-info: (file not managed or unknown revision control system)
//   git-hash: cef3659936323c87a91f6983db5e9f40a1f01b57
//
// ===========================================================================


#ifndef __PBE_COMMON_RAM_REGS_H
#define __PBE_COMMON_RAM_REGS_H

//******************************************************************************
// REGISTER OFFSETS
//******************************************************************************
// 
#define PBE_COMMON_RAM_O_CMDPAR0                                     0x00000000U

// 
#define PBE_COMMON_RAM_O_CMDPAR1                                     0x00000002U

// 
#define PBE_COMMON_RAM_O_MSGBOX                                      0x00000004U

// Reason why PBE ended operation.
#define PBE_COMMON_RAM_O_ENDCAUSE                                    0x00000006U

// 
#define PBE_COMMON_RAM_O_FIFOCMDADD                                  0x00000008U

//******************************************************************************
// Register: CMDPAR0
//******************************************************************************
// Field: [15:0] val
//
// 
#define PBE_COMMON_RAM_CMDPAR0_VAL_W                                         16U
#define PBE_COMMON_RAM_CMDPAR0_VAL_M                                     0xFFFFU
#define PBE_COMMON_RAM_CMDPAR0_VAL_S                                          0U

//******************************************************************************
// Register: CMDPAR1
//******************************************************************************
// Field: [15:0] val
//
// 
#define PBE_COMMON_RAM_CMDPAR1_VAL_W                                         16U
#define PBE_COMMON_RAM_CMDPAR1_VAL_M                                     0xFFFFU
#define PBE_COMMON_RAM_CMDPAR1_VAL_S                                          0U

//******************************************************************************
// Register: MSGBOX
//******************************************************************************
// Field: [15:0] val
//
// 
#define PBE_COMMON_RAM_MSGBOX_VAL_W                                          16U
#define PBE_COMMON_RAM_MSGBOX_VAL_M                                      0xFFFFU
#define PBE_COMMON_RAM_MSGBOX_VAL_S                                           0U

//******************************************************************************
// Register: ENDCAUSE
//******************************************************************************
// Field: [7:0] stat
//
// 
#define PBE_COMMON_RAM_ENDCAUSE_STAT_W                                        8U
#define PBE_COMMON_RAM_ENDCAUSE_STAT_M                                   0x00FFU
#define PBE_COMMON_RAM_ENDCAUSE_STAT_S                                        0U
#define PBE_COMMON_RAM_ENDCAUSE_STAT_ENDOK                               0x0000U
#define PBE_COMMON_RAM_ENDCAUSE_STAT_RXTIMEOUT                           0x0001U
#define PBE_COMMON_RAM_ENDCAUSE_STAT_NOSYNC                              0x0002U
#define PBE_COMMON_RAM_ENDCAUSE_STAT_RXERR                               0x0003U
#define PBE_COMMON_RAM_ENDCAUSE_STAT_CONNECT                             0x0004U
#define PBE_COMMON_RAM_ENDCAUSE_STAT_SCANRSP                             0x0006U
#define PBE_COMMON_RAM_ENDCAUSE_STAT_MAXNAK                              0x0006U
#define PBE_COMMON_RAM_ENDCAUSE_STAT_EOPSTOP                             0x0007U
#define PBE_COMMON_RAM_ENDCAUSE_STAT_ERR_RXF                             0x00F9U
#define PBE_COMMON_RAM_ENDCAUSE_STAT_ERR_TXF                             0x00FAU
#define PBE_COMMON_RAM_ENDCAUSE_STAT_ERR_SYNTH                           0x00FBU
#define PBE_COMMON_RAM_ENDCAUSE_STAT_ERR_STOP                            0x00FCU
#define PBE_COMMON_RAM_ENDCAUSE_STAT_ERR_PAR                             0x00FDU
#define PBE_COMMON_RAM_ENDCAUSE_STAT_ERR_BADOP                           0x00FEU
#define PBE_COMMON_RAM_ENDCAUSE_STAT_ERR_INTERNAL                        0x00FFU

//******************************************************************************
// Register: FIFOCMDADD
//******************************************************************************
// Field: [15:0] val
//
// 
#define PBE_COMMON_RAM_FIFOCMDADD_VAL_W                                      16U
#define PBE_COMMON_RAM_FIFOCMDADD_VAL_M                                  0xFFFFU
#define PBE_COMMON_RAM_FIFOCMDADD_VAL_S                                       0U


#endif // __PBE_COMMON_RAM_REGS_H
