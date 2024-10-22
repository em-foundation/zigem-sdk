#define __GNUC__ 10

#include <stdint.h>

typedef int __copy_table_t;

#include "inc/cc23x0r5.h"
#include "../../em.core/em.arch.arm/cmsis/cmsis_gcc.h"

#define __COMPILER_BARRIER()  // suppress
#define __DSB()  // suppress
#define __ISB()  // suppress

#include "../../em.core/em.arch.arm/cmsis/core_cm0plus.h"

#include "inc/hw_ckmd.h"
#include "inc/hw_clkctl.h"
#include "inc/hw_evtsvt.h"
#include "inc/hw_evtull.h"
#include "inc/hw_gpio.h"
#include "inc/hw_ioc.h"
#include "inc/hw_lgpt.h"
#include "inc/hw_lgpt3.h"
#include "inc/hw_lrfddbell.h"
#include "inc/hw_lrfdmdm.h"
#include "inc/hw_lrfdmdm32.h"
#include "inc/hw_lrfdpbe.h"
#include "inc/hw_lrfdpbe32.h"
#include "inc/hw_lrfdrfe.h"
#include "inc/hw_lrfdrfe32.h"
#include "inc/hw_memmap.h"
#include "inc/hw_pmctl.h"
#include "inc/hw_pmud.h"
#include "inc/hw_rtc.h"
#include "inc/hw_systick.h"
#include "inc/hw_systim.h"
#include "inc/hw_types.h"
#include "inc/hw_uart.h"
#include "inc/hw_vims.h"

#include "inc/pbe_ble5_ram_regs.h"
#include "inc/pbe_ble5_regdef_regs.h"
#include "inc/pbe_common_ram_regs.h"
#include "inc/pbe_generic_ram_regs.h"
#include "inc/pbe_generic_regdef_regs.h"
#include "inc/rfe_common_ram_regs.h"

#define LRF_EventNone                  (0U << 0U)   /*!< No events */
#define LRF_EventOpDone                (1U << 0U)   /*!< The PBE operation has finished */
#define LRF_EventPingRsp               (1U << 1U)   /*!< When receiving a CMD_PING, PBE responds with a PINGRSP. */
#define LRF_EventRxCtrl                (1U << 2U)   /*!< LL control packet received correctly */
#define LRF_EventRxCtrlAck             (1U << 3U)   /*!< LL control packet received with CRC OK, not to be ignored, then acknowledgement sent */
#define LRF_EventRxNok                 (1U << 4U)   /*!< Packet received with CRC error */
#define LRF_EventRxIgnored             (1U << 5U)   /*!< Packet received, but may be ignored by MCU */
#define LRF_EventRxEmpty               (1U << 6U)   /*!< Empty packet received */
#define LRF_EventRxBufFull             (1U << 7U)   /*!< Packet received which did not fit in the RX FIFO and was not to be discarded.  */
#define LRF_EventRxOk                  (1U << 8U)   /*!< Packet received with CRC OK and not to be ignored by the MCU */
#define LRF_EventTxCtrl                (1U << 9U)   /*!< Transmitted LL control packet */
#define LRF_EventTxCtrlAckAck          (1U << 10U)  /*!< Acknowledgement received on a transmitted LL control packet, and acknowledgement transmitted for that packet */
#define LRF_EventTxRetrans             (1U << 11U)  /*!< Packet retransmitted with same SN */
#define LRF_EventTxAck                 (1U << 12U)  /*!< Acknowledgement transmitted, or acknowledgement received on a transmitted packet. */
#define LRF_EventTxDone                (1U << 13U)  /*!< Packet transmitted */
#define LRF_EventTxCtrlAck             (1U << 14U)  /*!< Acknowledgement received on a transmitted LL control packet */
#define LRF_EventOpError               (1U << 15U)  /*!< Something went awfully wrong, the reason is indicated in RAM-based register BLE_ENDCAUSE. */
#define LRF_EventRxfifo                (1U << 16U)  /*!< Event from fifo, triggered when crossing threshold. Normal use for rxfifo is to generate IRQ when crossing threshold upwards (filling fifo). But downwards is also possible to configure, could be use case for using both fifos for TX or both for RX */
#define LRF_EventTxfifo                (1U << 17U)  /*!< Event from fifo, triggered when crossing threshold. Normal use for txfifo is to generate IRQ when crossing threshold downwards (emptying fifo). But upwards is also possible to configure, could be use case for using both fifos for TX or both for RX */
#define LRF_EventLossOfLock            (1U << 18U)  /*!< LOSS_OF_LOCK event */
#define LRF_EventLock                  (1U << 19U)  /*!< LOCK event */
#define LRF_EventRfesoft0              (1U << 20U)  /*!< RFESOFT0 event */
#define LRF_EventRfesoft1              (1U << 21U)  /*!< RFESOFT1 event */
#define LRF_EventRfedone               (1U << 22U)  /*!< RFEDONE event */
#define LRF_EventMdmsoft0              (1U << 23U)  /*!< MDMSOFT event */
#define LRF_EventMdmsoft1              (1U << 24U)  /*!< MDMSOFT1 event */
#define LRF_EventMdmsoft2              (1U << 25U)  /*!< MDMSOFT event */
#define LRF_EventMdmout                (1U << 26U)  /*!< MDMOUT event */
#define LRF_EventMdmin                 (1U << 27U)  /*!< MDMIN event */
#define LRF_EventMdmdone               (1U << 28U)  /*!< MDMDONE event */
#define LRF_EventSystim0               (1U << 29U)  /*!< SYSTIM0 event */
#define LRF_EventSystim1               (1U << 30U)  /*!< SYSTIM1 event */
#define LRF_EventSystim2               (1U << 31U)  /*!< SYSTIM2 event */
