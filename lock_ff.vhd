LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY lock_ff IS
    PORT(
        clk : IN STD_LOGIC;
        start : IN STD_LOGIC;
        signal_in : IN STD_LOGIC;
        lock : OUT STD_LOGIC
    );
END ENTITY lock_ff;

ARCHITECTURE rtl of lock_ff IS

    SIGNAL count : INTEGER RANGE 0 TO 20;

BEGIN
    PROCESS(clk)

        VARIABLE running : BOOLEAN;

    BEGIN
        IF rising_edge(clk) THEN
            IF signal_in = '1' and (not running) THEN
                lock <= '1';
                count <= 0;
                running := TRUE;

            ELSIF running THEN
                IF count = 20 THEN
                    count <= 0;
                    lock <= '0';
                    running := FALSE;
                ELSE
                    count <= count + 1;
                    lock <= '1';
                END IF;

            ELSE
                lock <= '0';
                count <= 0;
                running := FALSE;
            END IF;
        END IF;
    END PROCESS;
END rtl;