------------------------------------------------------------------------
-- axis_img_crop component
------------------------------------------------------------------------
-- This component performs a crop to an image using AXI Stream interface.
-- An offset to start cropping the input image can be applied with offset_x
-- and offset_y outputs.
--

library IEEE;
		use IEEE.STD_LOGIC_1164.ALL;
		use IEEE.math_real.all;
		use IEEE.numeric_std.all;
		use ieee.std_logic_unsigned.all;

entity axis_img_crop is
	generic (
		-- Size of the AXI stream data buses.
		AXI_ST_SIZE  : integer := 16
	);
	port (
		-- Main Clock and Reset.
		clk             : in std_logic;
		reset_n         : in std_logic;

		-- Input Image (Mantain stream_reset_n low while changing width or height)
		input_img_width			: in std_logic_vector(15 downto 0);
		input_img_height		: in std_logic_vector(15 downto 0);

		-- Output Image (Mantain stream_reset_n low while changing width or height)
		input_img_width			: in std_logic_vector(15 downto 0);
		input_img_height		: in std_logic_vector(15 downto 0);

		-- Offset X and Y to start copying the output image.
		offset_x		: in std_logic_vector(15 downto 0);
		offset_y		: in std_logic_vector(15 downto 0);

		-- Skip (skip lines and columns to increase field of view while maintaining
		-- same output resolution). Set to 0 to cut exactly a portion of input img.
		skip		: in std_logic_vector(15 downto 0);

		-- AXI STREAM SLAVE INTERFACE (Stream of image pixels)
		-- Clock for the AXI STREAM interface
		-- S_AXI_ST_ACLK	: in std_logic;
		-- AXI Stream Reset Signal. This Signal is Active LOW
		-- S_AXI_ST_ARESETN	: in std_logic;
		-- Data. It should contain all components of one pixel.
		S_AXI_ST_TDATA	: in std_logic_vector((AXI_ST_SIZE - 1) downto 0);
		-- Valid flags when there is a valid pixel in TDATA.
		S_AXI_ST_TVALID: in std_logic;
		-- Flags when the device is ready to read data.
		S_AXI_ST_TREADY: out std_logic;
		-- Signals the last byte of the stream (image).
		S_AXI_ST_TLAST	: in std_logic;

		-- AXI STREAM SLAVE INTERFACE (Stream of image pixels)
		-- Clock for the AXI STREAM interface
		-- S_AXI_ST_ACLK	: in std_logic;
		-- AXI Stream Reset Signal. This Signal is Active LOW
		-- S_AXI_ST_ARESETN	: in std_logic;
		-- Data. It should contain all components of one pixel.
		M_AXI_ST_TDATA	: out std_logic_vector((AXI_ST_SIZE - 1) downto 0);
		-- Valid flags when there is a valid pixel in TDATA.
		M_AXI_ST_TVALID: out std_logic;
		-- Flags when the device connected to this is is ready to accept data.
		M_AXI_ST_TREADY: in std_logic;
		-- Signals the last byte of the stream (image).
		M_AXI_ST_TLAST	: out std_logic

		);
end axis_img_crop;

architecture arch of axis_img_crop is

begin

end arch;
