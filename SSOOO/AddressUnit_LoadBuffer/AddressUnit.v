





module AddressUnit
(
);

// TODO: see about the RAW(load after store(store then load)) dependency between the lw, sw:
// how to not read when you are at the head of the load buffer and there is a store should write first on the memory
// so in this case we should know the addresses of the stores to wait for them to commit(write on memory) and then let the lw read, 
// or simply forward the value (that the store wants to store in the memory) to the load instruction if addresses is same same which it is in this case

/*
consider the following:
    - solve the address calculation forwarding for both lw, sw (forward from ALU instructions or lw)
    - support sw -> lw forwarding, but this brings the possibility of redirecting the lw to a ROBEN that produces the needed value to be read from the memory 
    which is the same value to be written to the memory
    - make one buffer for both of them and read/write in order
*/

// WAW is handled by committing the store instructions in order using the ROB (store after store(store then store))
// WAR is handled by not committing the result of the load until it is ready and then after it comes the store that can commit with no problems (store after load(load then store))

endmodule