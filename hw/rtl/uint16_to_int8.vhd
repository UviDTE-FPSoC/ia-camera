------------------------------------------------------------------------
-- uint16_to_int8 component
------------------------------------------------------------------------
-- This component converts a uint16 data type to an int8
-- using the AXI Stream interface
--=============================================================================
--=========================================== libraries =======================
--=============================================================================
library IEEE;
		use IEEE.STD_LOGIC_1164.ALL;
		use IEEE.math_real.all;
		use IEEE.numeric_std.all;
		use ieee.std_logic_unsigned.all;
--=============================================================================
--=========================================== entity ==========================
--=============================================================================
entity uint16_to_int8 is
	port (
		-- Main Clock and Reset.
		clk             : in std_logic;
		reset_n         : in std_logic;

		-- AXI STREAM SLAVE INTERFACE (Stream of image pixels)
		-- Clock for the AXI STREAM interface
		-- S_AXI_ST_ACLK	: in std_logic;
		-- AXI Stream Reset Signal. This Signal is Active LOW
		-- S_AXI_ST_ARESETN	: in std_logic;
		-- Data. It should contain all components of one pixel.
		S_AXI_ST_TDATA	: in std_logic_vector(15 downto 0);
		-- Valid flags when there is a valid pixel in TDATA.
		S_AXI_ST_TVALID: in std_logic;
		-- Flags when the device is ready to read data.
		S_AXI_ST_TREADY: out std_logic;
		-- Signals the last byte of the stream (image).
		S_AXI_ST_TLAST	: in std_logic;

		-- AXI STREAM MASTER INTERFACE (Stream of image pixels)
		-- Clock for the AXI STREAM interface
		-- S_AXI_ST_ACLK	: in std_logic;
		-- AXI Stream Reset Signal. This Signal is Active LOW
		-- S_AXI_ST_ARESETN	: in std_logic;
		-- Data. It should contain all components of one pixel.
		M_AXI_ST_TDATA	: out std_logic_vector(7 downto 0);
		-- Valid flags when there is a valid pixel in TDATA.
		M_AXI_ST_TVALID: out std_logic;
		-- Flags when the device connected to this is is ready to accept data.
		M_AXI_ST_TREADY: in std_logic;
		-- Signals the last byte of the stream (image).
		M_AXI_ST_TLAST	: out std_logic

		);
	end uint16_to_int8;
--=============================================================================
--=========================================== architecture ====================
--=============================================================================
	architecture arch of uint16_to_int8 is
		signal DATA_AUX : std_logic_vector (8 downto 0);
		begin
			process (clk)
			begin
				M_AXI_ST_TVALID <= '0';
				if reset_n <= '1' then
					if S_AXI_ST_TVALID<='1' then
						DATA_AUX <= ('0' & S_AXI_ST_TDATA (15 downto 8))-128;
						M_AXI_ST_TDATA <= DATA_AUX (7 downto 0);
						M_AXI_ST_TVALID <= '1';
					end if;
				end if;
			end process;
		end arch;
