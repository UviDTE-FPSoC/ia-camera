--=============================================================================
--===================================================   libraries   ===========
--=============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;
--=============================================================================
--============================================   entity test_bench  ===========
--=============================================================================
entity test_bench is
end;
--=============================================================================
--===============================   architecture of the test_bench  ===========
--=============================================================================
architecture arch_tb of test_bench is
---------------------------------------   component axis_img_crop   -----------
    component axis_img_crop
      generic (
        AXI_ST_SIZE : integer := 16
      );
      port(
        clk : in std_logic;
        reset_n : in std_logic;
        input_img_width : in std_logic_vector(15 downto 0);
        input_img_height : in std_logic_vector(15 downto 0);
        output_img_width : in std_logic_vector(15 downto 0);
        output_img_height : in std_logic_vector(15 downto 0);
        offset_x		: in std_logic_vector(15 downto 0);
        offset_y		: in std_logic_vector(15 downto 0);
        skip		: in std_logic_vector(15 downto 0);
        S_AXI_ST_TDATA : in std_logic_vector((AXI_ST_SIZE - 1) downto 0);
        S_AXI_ST_TVALID : in std_logic;
        S_AXI_ST_TREADY : out std_logic;
        S_AXI_ST_TLAST : in std_logic;
        M_AXI_ST_TDATA : out std_logic_vector((AXI_ST_SIZE - 1) downto 0);
        M_AXI_ST_TVALID : out std_logic;
        M_AXI_ST_TREADY : in std_logic;
        M_AXI_ST_TLAST : out std_logic
      );
    end component;
---------------------------------------   variables and signals    -------------
    constant AXI_ST_SIZE : integer := 16;
    shared variable edge_rise : integer    	:= -1;
    signal clk : std_logic :='0';
    signal reset_n : std_logic;
    signal input_img_width : std_logic_vector(15 downto 0);
    signal input_img_height : std_logic_vector(15 downto 0);
    signal output_img_width : std_logic_vector(15 downto 0);
    signal output_img_height : std_logic_vector(15 downto 0);
    signal offset_x		: std_logic_vector(15 downto 0);
    signal offset_y		: std_logic_vector(15 downto 0);
    signal skip		: std_logic_vector(15 downto 0);
    signal S_AXI_ST_TDATA : std_logic_vector((AXI_ST_SIZE - 1) downto 0);
    signal S_AXI_ST_TVALID : std_logic;
    signal S_AXI_ST_TREADY : std_logic;
    signal S_AXI_ST_TLAST : std_logic;
    signal M_AXI_ST_TDATA : std_logic_vector((AXI_ST_SIZE - 1) downto 0);
    signal M_AXI_ST_TVALID : std_logic;
    signal M_AXI_ST_TREADY : std_logic;
    signal M_AXI_ST_TLAST : std_logic;
---------------------------------------   simulation   ------------------------
    begin
--instance 'my_axis_img_crop'
      my_axis_img_crop : axis_img_crop port map(
        clk=>clk,
        reset_n=>reset_n,
        input_img_width=>input_img_width,
        input_img_height=>input_img_height,
        output_img_width=>output_img_width,
        output_img_height=>output_img_height,
        offset_x=>offset_x,
        offset_y=>offset_y,
        skip=>skip,
        S_AXI_ST_TDATA=>S_AXI_ST_TDATA,
        S_AXI_ST_TVALID=>S_AXI_ST_TVALID,
        S_AXI_ST_TREADY=>S_AXI_ST_TREADY,
        S_AXI_ST_TLAST=>S_AXI_ST_TLAST,
        M_AXI_ST_TDATA=>M_AXI_ST_TDATA,
        M_AXI_ST_TVALID=>M_AXI_ST_TVALID,
        M_AXI_ST_TREADY=>M_AXI_ST_TREADY,
        M_AXI_ST_TLAST=>M_AXI_ST_TLAST
      );
--simulation clock process
    simulation_clk : process
    constant max_cycles:integer:= 1000;
    begin
      clk <= not(clk);
      if (clk = '0') then
        edge_rise := edge_rise + 1;
      end if;
      wait for 20 ns;
    end process simulation_clk;
--stimuli process
    stimuli : process (clk)
    begin
        if(edge_rise = -1) then
            reset_n<='0';
            S_AXI_ST_TVALID<='1';
            input_img_width<="0000000000001011";
            input_img_height<="0000000000001110";
            output_img_width<="0000000000000011";
            output_img_height<="0000000000000011";
            offset_x<="0000000000000011";
            offset_y<="0000000000000010";
            skip<="0000000000000010";
        else
            S_AXI_ST_TDATA<=std_logic_vector(to_unsigned(edge_rise,16));
            if (edge_rise = 158 or edge_rise = 312 or edge_rise = 467) then
                S_AXI_ST_TLAST<='1';
            else
                S_AXI_ST_TLAST<='0';
            end if;
        end if;
        if(edge_rise = 5) then
            reset_n<='1';
        end if;
    end process stimuli;
end arch_tb;
