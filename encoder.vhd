
-- Thermometer to binary encoder
--
-- Inputs:
--   thermometer: Thermometer code to be encoded
--   clk : Clock signal
--
-- Outputs:
--   count_bin: Binary encoded thermometer code   

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY encoder IS
    GENERIC (
        n_bits_bin : POSITIVE;
        n_bits_therm : POSITIVE
    );
    PORT (
        clk : IN STD_LOGIC;
        therm1 : IN STD_LOGIC_VECTOR((n_bits_therm - 1) DOWNTO 0);
        therm2 : IN STD_LOGIC_VECTOR((n_bits_therm - 1) DOWNTO 0);
        therm3 : IN STD_LOGIC_VECTOR((n_bits_therm - 1) DOWNTO 0);
        therm4 : IN STD_LOGIC_VECTOR((n_bits_therm - 1) DOWNTO 0);
        count_bin : OUT STD_LOGIC_VECTOR((n_bits_bin - 1) DOWNTO 0)
    );
END ENTITY encoder;


ARCHITECTURE rtl OF encoder IS

    SIGNAL found : BOOLEAN := FALSE;
    SIGNAL bin : STD_LOGIC_VECTOR(n_bits_bin - 1 DOWNTO 0); --:= (OTHERS => '0');

    ATTRIBUTE keep : BOOLEAN;
    ATTRIBUTE keep OF bin : SIGNAL IS TRUE;

BEGIN

    PROCESS (clk)
    BEGIN

        IF rising_edge(clk) THEN   

            found <= FALSE; 
            bin <= (OTHERS => '0');

            IF (not found) THEN
                FOR i IN 0 TO n_bits_therm-1 LOOP
                    IF therm4(n_bits_therm-1-i) = '1' THEN
                        bin <= "00" & STD_LOGIC_VECTOR(to_unsigned(n_bits_therm - 1 - i, 6));
                        found <= TRUE;
                    END IF;
                END LOOP;
            END IF;

            IF (not found) THEN
                FOR i IN 0 TO n_bits_therm-1 LOOP
                    IF therm3(n_bits_therm-1-i) = '1' THEN
                        bin <= "01" & STD_LOGIC_VECTOR(to_unsigned(n_bits_therm - 1 - i, 6));
                        found <= TRUE;
                    END IF;
                END LOOP;
            END IF;
            
            IF (not found) THEN
                FOR i IN 0 TO n_bits_therm-1 LOOP
                    IF therm2(n_bits_therm-1-i) = '1' THEN
                        bin <= "10" & STD_LOGIC_VECTOR(to_unsigned(n_bits_therm - 1 - i, 6));
                        found <= TRUE;
                    END IF;
                END LOOP;
            END IF;

            IF (not found) THEN
                FOR i IN 0 TO n_bits_therm-1 LOOP
                    IF therm1(n_bits_therm-1-i) = '1' THEN
                        bin <= "11" & STD_LOGIC_VECTOR(to_unsigned(n_bits_therm - 1 - i, 6));
                        found <= TRUE;
                    END IF;
                END LOOP;
            END IF;

            count_bin <= bin;

        END IF;
    END PROCESS;

END ARCHITECTURE rtl;