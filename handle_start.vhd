-- Handle start after starting the fpga
--
-- This module is used to send a signal for one clock cycle after the FPGA has
-- been started. This signal is used to initialize several modules.
-- Implemented using a state machine with two states: reset_state and
-- running_state. 
--
-- Inputs:
--   clk: clock signal
--
-- Outputs:
--   starting: signal that is high for one clock cycle after the FPGA has been started
 
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY handle_start IS
    PORT (
        clk : IN STD_LOGIC;
        pll_locked : IN STD_LOGIC;
        starting : OUT STD_LOGIC
    );
END ENTITY handle_start;


ARCHITECTURE fsm_arch OF handle_start IS

    -- Define the states of the state machine
    TYPE state_type IS (reset_state, running_state);
    SIGNAL current_state, next_state : state_type;

    -- Output signal updated by the state machine
    SIGNAL starting_reg : STD_LOGIC;

BEGIN

    -- fsm core
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            current_state <= next_state;
            starting <= starting_reg;
        END IF;
    END PROCESS;

    -- fsm logic
    PROCESS (starting_reg, current_state, pll_locked)
    BEGIN

        next_state <= current_state;

        -- Go to reset_state after starting. Stay in reset_state for one cycle
        -- and send starting signal. Then go to running_state and stay there sending no signal.s
        CASE current_state IS
            WHEN reset_state =>
                IF pll_locked = '1' THEN
                    starting_reg <= '1';
                    next_state <= running_state;
                ELSE
                    starting_reg <= '0';
                    next_state <= reset_state;
                END IF;
                
            WHEN running_state =>
                starting_reg <= '0';
                next_state <= running_state;
                
            WHEN OTHERS =>
                next_state <= reset_state;
        END CASE;
    END PROCESS;
END ARCHITECTURE fsm_arch;