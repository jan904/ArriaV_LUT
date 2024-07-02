--
-- This module takes the input signal and generates timing information for it. 
-- The timing information is then encoded into a binary signal and sent to the
-- UART module for serial output.
--
-- Inputs:
--   clk: The clock signal
--   signal_in: Trigger signal we want to get timing information on
--
-- Outputs:
--   signal_out: Binary timing information 
--   serial_out: Serial output of the binary timing information     

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY channel IS
    GENERIC (
        carry4_count : INTEGER := 32;
        n_output_bits : INTEGER := 8
    );
    PORT (
        clk : IN STD_LOGIC;
        signal_in : IN STD_LOGIC;
        signal_out : OUT STD_LOGIC_VECTOR(n_output_bits - 1 DOWNTO 0);
        out_s : OUT STD_LOGIC
    );
END ENTITY channel;
ARCHITECTURE rtl OF channel IS

    SIGNAL reset_after_start : STD_LOGIC;
    SIGNAL reset_after_signal : STD_LOGIC;
    SIGNAL busy : STD_LOGIC;
    SIGNAL wr_en : STD_LOGIC;

    SIGNAL therm_code1 : STD_LOGIC_VECTOR(carry4_count * 4 - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL therm_code2 : STD_LOGIC_VECTOR(carry4_count * 4 - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL therm_code3 : STD_LOGIC_VECTOR(carry4_count * 4 - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL therm_code4 : STD_LOGIC_VECTOR(carry4_count * 4 - 1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL lock1 : STD_LOGIC;
    SIGNAL lock2 : STD_LOGIC;
    SIGNAL lock3 : STD_LOGIC;
    SIGNAL lock4 : STD_LOGIC;

    SIGNAL bin_output : STD_LOGIC_VECTOR(n_output_bits - 1 DOWNTO 0);

    SIGNAL address : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

    SIGNAL pll_locked : STD_LOGIC;

    SIGNAL pll_clock1 : STD_LOGIC;
    SIGNAL pll_clock2 : STD_LOGIC;
    SIGNAL pll_clock3 : STD_LOGIC;
    SIGNAL pll_clock4 : STD_LOGIC;

    COMPONENT delay_line IS
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
    END COMPONENT delay_line;

    COMPONENT encoder IS
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
            count_bin : OUT STD_LOGIC_VECTOR(n_bits_bin - 1 DOWNTO 0)
        );
    END COMPONENT encoder;

    COMPONENT detect_signal IS
        GENERIC (
            stages : POSITIVE;
            n_output_bits : POSITIVE
        );
        PORT (
            clock : IN STD_LOGIC;
            start : IN STD_LOGIC;
            signal_in : IN STD_LOGIC;
            signal_running : OUT STD_LOGIC;
            address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            reset : OUT STD_LOGIC;
            wrt : OUT STD_LOGIC
        );
    END COMPONENT detect_signal;

    COMPONENT handle_start IS
        PORT (
            clk : IN STD_LOGIC;
            pll_locked : IN STD_LOGIC;
            starting : OUT STD_LOGIC
        );
    END COMPONENT handle_start;

    component pll is
		port (
			refclk   : in  std_logic; -- clk
			rst      : in  std_logic := 'X'; -- reset
            locked   : out std_logic := 'X'; -- locked
			outclk_0 : out std_logic;         -- clk
            outclk_1 : out std_logic;
            outclk_2 : out std_logic;
            outclk_3 : out std_logic
		);
	end component pll;

    component memory
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            clock		: IN STD_LOGIC  := '1';
            data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            wren		: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
    end component;

    COMPONENT lock_ff IS
        PORT(
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            start : IN STD_LOGIC;
            signal_in : IN STD_LOGIC;
            lock : OUT STD_LOGIC
        );
    END COMPONENT lock_ff;

BEGIN

    signal_out <= bin_output;
    out_s <= signal_in;

    memory_inst : memory
    PORT MAP(
        address => address,
        clock => clk,
        data => bin_output,
        wren => wr_en,
        q => open
    );

    pll_inst : pll
    port map (
        refclk => clk,
        rst => reset_after_start,
        locked => pll_locked,
        outclk_0 => pll_clock1,
        outclk_1 => pll_clock2,
        outclk_2 => pll_clock3,
        outclk_3 => pll_clock4
    );

    -- send reset signal after start to all components
    handle_start_inst : handle_start
    PORT MAP(
        clk => clk,
        pll_locked => pll_locked,
        starting => reset_after_start
    );

    -- delay line itself
    delay_line_inst1 : delay_line
    GENERIC MAP(
        stages => carry4_count * 4
    )
    PORT MAP(
        reset => reset_after_signal,
        lock_interm => lock1,
        signal_running => busy,
        trigger => signal_in,
        clock => pll_clock1,
        therm_code => therm_code1
    );

    -- delay line itself
    delay_line_inst2 : delay_line
    GENERIC MAP(
        stages => carry4_count * 4
    )
    PORT MAP(
        reset => reset_after_signal,
        lock_interm => lock2,
        signal_running => busy,
        trigger => signal_in,
        clock => pll_clock2,
        therm_code => therm_code2
    );

    delay_line_inst3 : delay_line
    GENERIC MAP(
        stages => carry4_count * 4
    )
    PORT MAP(
        reset => reset_after_signal,
        lock_interm => lock3,
        signal_running => busy,
        trigger => signal_in,
        clock => pll_clock3,
        therm_code => therm_code3
    );

    delay_line_inst4 : delay_line
    GENERIC MAP(
        stages => carry4_count * 4
    )
    PORT MAP(
        reset => reset_after_signal,
        lock_interm => lock4,
        signal_running => busy,
        trigger => signal_in,
        clock => pll_clock4,
        therm_code => therm_code4
    );

    lock_ff_inst1 : lock_ff
    PORT MAP(
        clk => pll_clock1,
        rst => reset_after_signal,
        start => reset_after_start,
        signal_in => signal_in,
        lock => lock1
    );

    lock_ff_inst2 : lock_ff
    PORT MAP(
        clk => pll_clock2,
        rst => reset_after_signal,
        start => reset_after_start,
        signal_in => signal_in,
        lock => lock2
    );

    lock_ff_inst3 : lock_ff
    PORT MAP(
        clk => pll_clock3,
        rst => reset_after_signal,
        start => reset_after_start,
        signal_in => signal_in,
        lock => lock3
    );

    lock_ff_inst4 : lock_ff
    PORT MAP(
        clk => pll_clock4,
        rst => reset_after_signal,
        start => reset_after_start,
        signal_in => signal_in,
        lock => lock4
    );
	 
    -- logic to detect signal and handle current state of TDC
    detect_signal_inst : detect_signal
    GENERIC MAP(
        stages => carry4_count * 4,
        n_output_bits => n_output_bits
    )
    PORT MAP(
        clock => clk,
        start => reset_after_start,
        signal_in => signal_in,
        signal_running => busy,
        reset => reset_after_signal,
        address => address,
        wrt => wr_en
    );
	 
    -- convert thermometer code to binary
    encoder_inst : encoder
    GENERIC MAP(
        n_bits_bin => n_output_bits,
        n_bits_therm => 4 * carry4_count
    )
    PORT MAP(
        clk => clk,
        therm1 => therm_code1,
        therm2 => therm_code2,
        therm3 => therm_code3,
        therm4 => therm_code4,
        count_bin => bin_output
    );

    signal_out <= bin_output;
        
END ARCHITECTURE rtl;