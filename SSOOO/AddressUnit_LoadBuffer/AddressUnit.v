





module AddressUnit
(
);

// TODO: see about the RAW(load after store(store then load)) dependency between the lw, sw:
// how to not read when you are at the head of the load buffer and there is a store should write first on the memory
// WAW is handled by committing the store instructions in order using the ROB (store after store(store then store))
// WAR is handled by not committing the result of the load until it is ready and then after it comes the store that can commit with no problems (store after load(load then store))

endmodule