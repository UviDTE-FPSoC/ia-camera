LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
LIBRARY std;
USE std.textio.all;

ENTITY bkg_analyzer_img_vhd_tst IS
END bkg_analyzer_img_vhd_tst;
ARCHITECTURE bkg_analyzer_arch OF bkg_analyzer_img_vhd_tst IS
-- constants
-- signals

shared variable edge_rise  	: integer    	:= -1;
shared variable edge_fall 	: integer    	:= -1;

SIGNAL bkg_mean : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL bkg_std : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL clk : STD_LOGIC := '0';
SIGNAL img_height : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000001000000";
SIGNAL img_width : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000001000000";
SIGNAL times_stddev_th : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000010";
SIGNAL pix : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
SIGNAL pix_bkg : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL pix_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL rst_n : STD_LOGIC := '0';
SIGNAL valid : STD_LOGIC := '0';
SIGNAL valid_out : STD_LOGIC;
COMPONENT bkg_analyzer
	PORT (
	bkg_mean : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	bkg_std : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	clk : IN STD_LOGIC;
	img_height : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	img_width : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	times_stddev_th : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	pix : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	pix_bkg : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	pix_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	rst_n : IN STD_LOGIC;
	valid : IN STD_LOGIC;
	valid_out : OUT STD_LOGIC
	);
END COMPONENT;
COMPONENT read_file
	GENERIC (
		sim_file			:   string := "/home/roberto/git/custodian-camera/hw/sim/meltpool_image_hex.txt";
		DATA_WIDTH 		:   integer := 16;
		n_rows				:   integer := 64;
		n_cols				:   integer := 64
	);
	PORT (
		clk     : inout    std_logic := '0';
        	pix_valid   : out   std_logic;
        	pix    : out   std_logic_vector(DATA_WIDTH-1 downto 0)
	);
END COMPONENT;

BEGIN
	i1 : bkg_analyzer
	PORT MAP (
-- list connections between master ports and signals
	bkg_mean => bkg_mean,
	bkg_std => bkg_std,
	clk => clk,
	img_height => img_height,
	img_width => img_width,
	times_stddev_th => times_stddev_th,
	pix => pix,
	pix_bkg => pix_bkg,
	pix_out => pix_out,
	rst_n => rst_n,
	valid => valid,
	valid_out => valid_out
	);

	i2 : read_file
	PORT MAP (
	clk => clk,
	pix_valid => valid,
	pix => pix
	);

init : PROCESS
-- variable declarations
BEGIN
        -- code that executes only once
	rst_n <= '1' after 30 ns;
WAIT;
END PROCESS init;
always : PROCESS
-- optional sensitivity list
-- (        )
-- variable declarations
BEGIN
        -- code executes for every event on sensitivity list
WAIT;
END PROCESS always;

write2file : PROCESS (clk)
file output_text	: text open write_mode is "/home/roberto/git/custodian-camera/hw/sim/out_file.txt";
file binary_text	: text open write_mode is "/home/roberto/git/custodian-camera/hw/sim/bkg_file.txt";
variable output_line	: line;
variable binary_line	: line;
variable cur_col 	: integer := 0;
BEGIN
if (rising_edge(clk) and valid_out = '1') then
	if (cur_col = 64) then
		writeline(output_text,output_line);
		writeline(binary_text,binary_line);
		cur_col := 0;
	end if;
	write(output_line,to_integer(unsigned(pix_out)),right,10);
	write(binary_line,to_integer(unsigned(pix_bkg)),right,10);
	cur_col := cur_col +1;
end if;
END PROCESS write2file;

END bkg_analyzer_arch;
