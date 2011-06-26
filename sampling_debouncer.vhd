library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;

-- Simple sampling debouncer. Takes samples of input at intervals of defined clock cycles.
-- On default value with 50MHz clock, sample interval is 21ms. Debounced output is set to
-- input value when the input is the same as previously sampled value.
-- With default values, debouncer occupies 18 slices in xc3s700an FPGA.
entity sampling_debounce is
	generic(
		-- Sample interval (2^N cycles).
		N: integer := 20	-- On 50MHz clock about 21ms.
	);
	port( 
		clk,sw: in std_logic;
		db_level: out std_logic
	);
end entity sampling_debounce;

architecture RTL of sampling_debounce is
	signal counter: unsigned(N-1 downto 0) := (others => '1');
	signal zero: std_logic := '0';
	signal sw_sampled, sw_latched: std_logic := '0';
begin
	-- Counter
	process(clk) is
	begin
		if rising_edge(clk) then
			if (counter = 0) then
				zero <= '1';
				counter <= (others => '1');
			else
				counter <= counter - 1;
				zero <= '0';
			end if;
		end if;
	end process;
	
	-- Debouncing
	process(clk) is
	begin
		if rising_edge(clk) then
			if (zero = '1') then
				if (sw_latched = sw_sampled) then
					db_level <= sw_latched;
				end if;
				sw_sampled <= sw_latched;
				sw_latched <= sw;
			end if;
		end if;
	end process;
end architecture RTL;