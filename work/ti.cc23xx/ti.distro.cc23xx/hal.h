#define __GNUC__ 10

#include <stdint.h>

typedef int __copy_table_t;

#include "inc/cc23x0r5.h"
#include "../../em.arch/em.arch.arm/cmsis/cmsis_gcc.h"

#define __COMPILER_BARRIER()  // suppress
#define __DSB()  // suppress
#define __ISB()  // suppress

#include "../../em.arch/em.arch.arm/cmsis/core_cm0plus.h"

#include "inc/hw_ckmd.h"
#include "inc/hw_clkctl.h"
#include "inc/hw_evtull.h"
#include "inc/hw_gpio.h"
#include "inc/hw_ioc.h"
#include "inc/hw_lgpt.h"
#include "inc/hw_lgpt3.h"
#include "inc/hw_memmap.h"
#include "inc/hw_pmctl.h"
#include "inc/hw_types.h"
#include "inc/hw_uart.h"
