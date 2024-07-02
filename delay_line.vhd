--
-- This module implements a tapped delay line with a configurable number of stages.
-- The delay line is implemented using a chain of carry4 cells. The 4-bit inputs to 
-- the carry4 cells are '0000' and '1111', such that the carry-in propagates through
-- the chain of cells. The carry-in of the first cell is driven by the trigger signal. If a '1' comes in
-- as a trigger, this one propagates through the chain of cells. Similarly, a '0' propagates though the chain of sums.
-- Each cell has 4 carry-out signals and 4 sum outputs, one for each full adder, respecitvely.
-- One the rising edge of the clock signal, the sums are latched using a FDR FlipFlop. 
-- The number of ones in the latched signal indicates the number of stages that the input signal has been 
-- propagated through and thus gives timing information. The output of the latches should be perfect thermometer code.
-- The signal is then latched twice for stability reasons.
--
-- Inputs:
--  reset: Asynchronous reset signal. Set to '1' when the TDC is ready for a new signal 
--  trigger: Signal that triggers the delay line
--  clock: Clock signal
--  signal_running: Signal that indicates that the delay chain is busy with a signal
--
-- Outputs:
--  intermediate_signal: signal after the first row of latches
--  therm_code: signal after the second row of latches



LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY delay_line IS
    GENERIC (
        stages : INTEGER := 8
    );
    PORT (
        reset : IN STD_LOGIC;
        lock_interm : IN STD_LOGIC;
        trigger : IN STD_LOGIC;
        clock : IN STD_LOGIC;
        signal_running : IN STD_LOGIC;
        therm_code : OUT STD_LOGIC_VECTOR(stages - 1 DOWNTO 0)
    );
END delay_line;


ARCHITECTURE rtl OF delay_line IS

    -- Raw output of TDL
    SIGNAL sum : STD_LOGIC_VECTOR(stages - 1 DOWNTO 0);

    COMPONENT carry4
        GENERIC (
            stages : INTEGER := 4
        );
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            lock_interm : IN STD_LOGIC;
            lock : IN STD_LOGIC;
            a, b : IN STD_LOGIC_VECTOR(stages-1 DOWNTO 0);
            Cin : IN STD_LOGIC;
            Sum_vector : OUT STD_LOGIC_VECTOR(stages-1 DOWNTO 0)
        );
    END COMPONENT;
	
BEGIN

    -- Instantiate the carry4 cells
    delayblock : carry4
    GENERIC MAP(
        stages => stages
    )
    PORT MAP(
        clk => clock,
        rst => reset,
        lock_interm => lock_interm,
        lock => signal_running,
        a => (OTHERS => '0'), 
        b => (OTHERS => '1'), 
        Cin => trigger,
        Sum_vector => therm_code(stages-1 DOWNTO 0)
    );

END ARCHITECTURE rtl;