-- Carry4 module consisting of 4 full adders
--
-- The carry-in of the first full adder is connected to the Cin input of the module.
-- Each carry-out of the full adders is connected to the carry-in of the next full adder.
-- The carry-outs are stored asynchonously in the Cout_vector output of the module.
--
-- Inputs: 
--  a, b: 4-bit vectors
--  Cin: carry-in
--
-- Outputs:
--  Cout_vector: 4-bit vector containing the carry-outs of the full adders

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY carry4 IS
    GENERIC (
        stages : INTEGER := 4
    );
    PORT (
        clk : IN STD_LOGIC;
        clk_slow : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        lock_interm : IN STD_LOGIC;
        lock : IN STD_LOGIC;
        a, b : IN STD_LOGIC_VECTOR(stages-1 DOWNTO 0);
        Cin : IN STD_LOGIC;
        Sum_vector : OUT STD_LOGIC_VECTOR(stages-1 DOWNTO 0)
    );
END ENTITY carry4;

ARCHITECTURE rtl OF carry4 IS

    SIGNAL total : STD_LOGIC_VECTOR(stages DOWNTO 0);
    SIGNAL interm : STD_LOGIC_VECTOR(stages-1 DOWNTO 0);

BEGIN

    total <= std_logic_vector(resize(unsigned(a),stages+1) + resize(unsigned(b), stages+1) + unsigned'('0'&Cin));

    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            FOR i IN 0 TO stages-1 LOOP
                IF lock_interm = '0' THEN
                    interm(i) <= not total(i);
                END IF;
            END LOOP;
        END IF;
    END PROCESS;

    PROCESS(clk_slow, rst)
    BEGIN
        IF rst = '1' THEN
            Sum_vector <= (OTHERS => '0');
        ELSIF rising_edge(clk_slow) THEN
            FOR i IN 0 TO stages-1 LOOP
                IF lock = '0' THEN
                    Sum_vector(i) <= interm(i);
                END IF;
            END LOOP;
        END IF;
    END PROCESS;

END ARCHITECTURE rtl;