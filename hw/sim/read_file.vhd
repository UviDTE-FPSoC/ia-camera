  ----------------------------------------------------------------------------------
-- Reads bytes from a file located at the path specified in the "input_file"
-- declaration. At the end of the file EOF is set high.
--
-- Expects ASCII hex data as the input. Reads one element per clock. For example,
-- if the desired output is: 01,23,45,67,89,AB,CD,EF the input text file should
-- contain:
-- 01 23
-- 45 67
-- ..
-- CD EF
--
----------------------------------------------------------------------------------


--include this library for file handling in VHDL.
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;  --include package textio.vhd

--entity declaration
entity read_file is
    generic
    (
        sim_file            :   string := "/home/roberto/git/custodian-camera/hw/sim/meltpool_image_hex.txt";
        DATA_WIDTH          :   integer := 16;
        n_rows		    :   integer := 64;
        n_cols		    :   integer := 64
    );
    port
    (
        clk     : inout    std_logic := '0';
        pix_valid   : out   std_logic := '0';
        pix    : out   std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0')
    );
end read_file;

--architecture definition
architecture Behavioral of read_file is
	shared variable edge_rise  	: integer    	:= -5;
	shared variable edge_fall 	: integer    	:= -5;
	SIGNAL eof : std_logic;
	SIGNAL counter 	 : integer := 0;
  -- file declaration
  -- type "text" is already declared in textio library
  FILE input_file  : text OPEN read_mode IS sim_file;

BEGIN
----------------    CLOCK PROCESS    ------------------------
	simulation_clock : process
		-- repeat the counters edge_rise & edge_fall
		constant max_cycles    	: integer   := n_cols;
	begin
		-- set sim_clk signal
		clk <= not(clk);
		-- adjust
		if (clk = '0') then
			edge_rise := edge_rise + 1;
		else
			edge_fall := edge_fall + 1;
		end if;
		if( edge_fall = max_cycles ) then
			edge_rise := 0;
			edge_fall := 0;
		end if;
		wait for 20 ns;
	end process simulation_clock;
-- Read process
PROCESS(clk)
    -- file variables
    VARIABLE vDatainline : line;
    VARIABLE vDatain     : std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

BEGIN
if (rising_edge(clk)) then
pix_valid <= '0';
if (edge_rise > -1) then
	if (counter = n_rows) and (edge_rise = n_cols) then
		edge_rise := -5;
		edge_fall := -6;
		counter <= 0;
    	elsif (( edge_rise = 0)or( edge_rise = n_cols)) then
		counter <= counter +1;
		if not endfile(input_file) then
               		readline (input_file, vDatainline);         -- Get line from input file
                	hread (vDatainline, vDatain);               -- Read as hex
                	pix_valid <= '1';                               -- Data is valid
                	pix <= ((vDatain(DATA_WIDTH-1 downto 0))); -- Convert variable to signal
            		eof <= '0';
		else
       			eof <= '1';
		end if;
  	else
		if (eof = '0') then
              	 	hread (vDatainline, vDatain);               -- Read as hex
              	 	pix_valid <= '1';                               -- Data is valid
              	 	pix <= ((vDatain(DATA_WIDTH-1 downto 0))); -- Convert variable to signal
		end if;
    	end if;
end if;
end if;

  END PROCESS;

end Behavioral;
