pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    em__upath: []const u8,
    handler_info_tab: em.Table(HandlerInfo, .RO),
};

pub const GpioEdgeI = em.import.@"em.hal/GpioEdgeI";
pub const IntrVec = em.import.@"em.arch.arm/IntrVec";

pub const HandlerInfo = struct {
    mask: u32,
    handler: GpioEdgeI.HandlerFxn,
};

pub const EM__META = struct {
    //
    pub fn em__constructH() void {
        IntrVec.useIntrH("GPIO_COMB");
    }

    pub fn addHandlerInfoH(hi: HandlerInfo) void {
        em__C.handler_info_tab.add(hi);
    }
};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    const handler_info_tab = em__C.handler_info_tab.items();

    pub fn em__startup() void {
        hal.NVIC_EnableIRQ(hal.GPIO_COMB_IRQn);
    }

    export fn GPIO_COMB_isr() void {
        if (em.IS_META) return;
        const mis = reg(hal.GPIO_BASE + hal.GPIO_O_MIS).*;
        for (handler_info_tab) |hi| {
            if ((mis & hi.mask) != 0 and hi.handler != null) {
                hi.handler.?(.{});
            }
        }
        reg(hal.GPIO_BASE + hal.GPIO_O_ICLR).* = 0xffffffff; // TODO: use `mis`
    }
};

//package ti.mcu.cc23xx
//
//import InterruptT { name: "GPIO_COMB" } as Intr
//
//module EdgeDetectGpioAux
//
//    type Handler: function ()
//
//    type HandlerInfo: struct
//        link: HandlerInfo&
//        mask: uint32
//        handler: Handler
//    end
//
//    function addHandler(hi: HandlerInfo&)
//
// private:
//
//    var handlerList: HandlerInfo&
//    function edgeIsr: Intr.Handler
//
//end
//
//def em$construct()
//    Intr.setHandlerH(edgeIsr)
//end
//
//def em$startup()
//    Intr.enable()
//end
//
//def addHandler(hi)
//    hi.link = handlerList
//    handlerList = hi
//end
//
//def edgeIsr()
//    auto mis = <uint32>^^HWREG(GPIO_BASE + GPIO_O_MIS)^^
//    for hi: HandlerInfo& = handlerList; hi != null; hi = hi.link
//        hi.handler() if (mis & hi.mask) && hi.handler
//    end
//    ^^HWREG(GPIO_BASE + GPIO_O_ICLR)^^ = 0xffffffff
//end
//
