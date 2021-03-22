
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
---------------------------------------   component uint16_to_int8   -----------
  component uint16_to_int8
  port(
     clk : in std_logic;
     reset_n : in std_logic;
     S_AXI_ST_TDATA : in std_logic_vector(15 downto 0);
     S_AXI_ST_TVALID : in std_logic;
     S_AXI_ST_TREADY : out std_logic;
     S_AXI_ST_TLAST : in std_logic;
     M_AXI_ST_TDATA : out std_logic_vector(7 downto 0);
     M_AXI_ST_TVALID : out std_logic;
     M_AXI_ST_TREADY : in std_logic;
     M_AXI_ST_TLAST : out std_logic
  );
  end component;
---------------------------------------   variables and signals    -------------
    shared variable edge_rise : integer    	:= -1;
    signal clk : std_logic :='0';
    signal reset_n : std_logic;
    signal S_AXI_ST_TDATA : std_logic_vector(15 downto 0);
    signal S_AXI_ST_TVALID : std_logic;
    signal S_AXI_ST_TREADY : std_logic;
    signal S_AXI_ST_TLAST : std_logic;
    signal M_AXI_ST_TDATA : std_logic_vector(7 downto 0);
    signal M_AXI_ST_TVALID : std_logic;
    signal M_AXI_ST_TREADY : std_logic;
    signal M_AXI_ST_TLAST : std_logic;
---------------------------------------   simulation   ------------------------
    begin
--instance 'uint16_to_int8'
    my_uint16_to_int8 : uint16_to_int8 port map(
        clk=>clk,
        reset_n=>reset_n,
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
            S_AXI_ST_TDATA <= "0000000000000000";
            S_AXI_ST_TVALID <= '0';
            reset_n <= '0';
          else
             S_AXI_ST_TDATA<=std_logic_vector(to_unsigned(edge_rise,16));
          end if;
          if(edge_rise = 5) then
            reset_n <= '1';
          end if;
          if(edge_rise = 8) then
            S_AXI_ST_TVALID <= '1';
          end if;
        end process stimuli;
end arch_tb;
