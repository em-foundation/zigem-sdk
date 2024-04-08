pub fn REG(adr: u32) *volatile u32 {
    const reg: *volatile u32 = @ptrFromInt(adr);
    return reg;
}

pub fn halt() void {
    var dummy: u32 = 0xCAFE;
    const vp: *volatile u32 = &dummy;
    while (vp.* != 0) {}
}
