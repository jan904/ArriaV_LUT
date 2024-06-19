-- Flip Flop with Reset and Lock
--
-- This is a simple flip flop with reset and lock. The output is updated on the
-- rising edge of the clock signal, unless the lock signal is set to 1. In that
-- case, the output is not updated.
--
-- Inputs:
--   rst: reset output to 0
--   lock: if set to 1, output is not updated
--   clk: clock
--   t: input signal
--
-- Outputs:
--   q: output signal


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fdr IS
    PORT (
        rst : IN STD_LOGIC;
        lock : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        t : IN STD_LOGIC;
        q : OUT STD_LOGIC
    );
END fdr;


ARCHITECTURE rtl OF fdr IS
BEGIN

    PROCESS (clk, rst)
    BEGIN
        -- Set output to 0 on reset
        IF rst = '1' THEN
            q <= '0';
        -- Update output on rising edge of clock if not locked
        ELSIF clk'event AND clk = '1' THEN
            IF lock = '0' THEN
                q <= t;
            END IF;
        END IF;
    END PROCESS;
    
END rtl;