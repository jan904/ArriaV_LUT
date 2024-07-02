-- Full adder fo two 1 Bit inputs
--
-- This is a full adder that takes two 1 Bit inputs and a carry in and outputs a carry out.
-- The sum is not calculated as we don't need it for the purpose of a delay chain.
--
--Inputs:
--  a, b : 1 Bit inputs
--  Cin : Carry in
--
--Outputs:
--  Cout : Carry out

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY full_add IS
  PORT (
    a : IN STD_LOGIC;
    b : IN STD_LOGIC;
    Cin : IN STD_LOGIC;
    Cout : OUT STD_LOGIC
    --Sum : OUT STD_LOGIC
  );
END ENTITY full_add;

ARCHITECTURE behavioral OF full_add IS

BEGIN
  --Sum <= not (Cin XOR ( a XOR b ));
  Cout <= (a AND b) OR (Cin AND (a XOR b));
  
END ARCHITECTURE behavioral;