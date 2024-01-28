if (Opcode(10)='1' and Opcode(7 downto 4)="0101" and Opcode(2 downto 0)="000") then
    Reg2Loc   <= '0';
    ALUSrc    <= '0';
    MemtoReg  <= '0';
    RegWrite  <= '1';
    MemRead   <= '0';
    MemWrite  <= '0';
    CBranch   <= '0';
    ALUOp(1)  <= '1';
    ALUOP(0)  <= '0';
    UBranch   <= '0';