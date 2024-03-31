#include <stdbool.h>
#include <stdint.h>

typedef void( *intfunc )( void );
typedef union { intfunc fxn; void* ptr; } intvec_elem;

extern uint32_t __stack_top__;
extern void __em_program_start( void );
const intvec_elem  __attribute__((section(".intvec"))) __vector_table[] = {
    { .ptr = (void*)&__stack_top__ },
    { .fxn = __em_program_start },

     0,
     0,
     0,
     0,
     0,
     0,
     0,
     0,
     0,
     0,
     0,
     0,
     0,
     0,
 };
