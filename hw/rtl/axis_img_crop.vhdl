------------------------------------------------------------------------
-- axis_img_crop component
------------------------------------------------------------------------
-- This component performs a crop to an image using AXI Stream interface.
-- An offset to start cropping the input image can be applied with offset_x
-- and offset_y outputs.
--
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
		output_img_width			: in std_logic_vector(15 downto 0);
		output_img_height		: in std_logic_vector(15 downto 0);

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
--=============================================================================
--=========================================== architecture ====================
--=============================================================================
architecture arch of axis_img_crop is
	shared variable pixels_passed_width : integer :=0;
	shared variable pixels_passed_height : integer :=0;
	shared variable skip_pixels_passed_width : integer := 0;
	shared variable skip_pixels_passed_height : integer := 0;
	shared variable end_proc : bit :='0';
	shared variable evaluate_pixel : bit :='0';
	shared variable evaluate_line : bit :='0';
begin
-----------------------------------    S_AXI_ST_TLAST process    ----------
	process (S_AXI_ST_TLAST)
	begin
		if S_AXI_ST_TLAST<='1' then
			pixels_passed_width :=0;
			pixels_passed_height :=0;
			skip_pixels_passed_width :=0;
			skip_pixels_passed_height :=0;
			end_proc :='0';
			evaluate_line :='0';
			evaluate_pixel :='0';
		end if;
	end process;
-----------------------------------    clk process    ---------------------
	process (clk)
	variable offsetX : integer;
	variable offsetY : integer;
	variable input_imgWidth : integer;
	variable input_imgHeight : integer;
	variable output_imgWidth : integer;
	variable output_imgHeight : integer;
	variable skp : integer;
	begin
		offsetX := to_integer(unsigned(offset_x));
		offsetY := to_integer(unsigned(offset_y));
		input_imgWidth := to_integer(unsigned(input_img_width));
		input_imgHeight := to_integer(unsigned(input_img_height));
		skp := to_integer(unsigned(skip));
		output_imgWidth := to_integer(unsigned(output_img_width));
		output_imgHeight := to_integer(unsigned(output_img_height));
		output_imgWidth := output_imgWidth + (output_imgWidth-1)*skp;
		output_imgHeight := output_imgHeight + (output_imgHeight-1)*skp;
		if rising_edge(clk) then
			M_AXI_ST_TVALID<='0';
			M_AXI_ST_TLAST<='0';
			M_AXI_ST_TDATA<=S_AXI_ST_TDATA;
			if reset_n<='0' then
				pixels_passed_width :=0;
				pixels_passed_height :=0;
				skip_pixels_passed_width :=0;
				skip_pixels_passed_height :=0;
				end_proc :='0';
				evaluate_line :='0';
				evaluate_pixel :='0';
			else
				if end_proc='0' then
					if pixels_passed_height<offsetY then
						if pixels_passed_width=input_imgWidth -1 then
							pixels_passed_width:=0;
							pixels_passed_height:= pixels_passed_height + 1;
						else
							pixels_passed_width:=pixels_passed_width+1;
						end if;
					else
						if pixels_passed_width<offsetX then
							pixels_passed_width:=pixels_passed_width+1;
						else
							if pixels_passed_height=offsetY then
								evaluate_line:='1';
							else
								if skip_pixels_passed_height=skp then
									evaluate_line:='1';
								else
									if pixels_passed_width=input_imgWidth-1 then
										pixels_passed_width:=0;
										pixels_passed_height:=pixels_passed_height+1;
										skip_pixels_passed_height:=skip_pixels_passed_height+1;
									else
										pixels_passed_width:=pixels_passed_width+1;
									end if;
								end if;
							end if;
						end if;
					end if;
				end if;
--*********************************    evaluate line    ****************************************
				if evaluate_line='1' then
					evaluate_line:='0';
					if pixels_passed_height=output_imgHeight+offsetY-1 then
						if pixels_passed_width=output_imgWidth+offsetX-1 then
							M_AXI_ST_TLAST<='1';
							end_proc:='1';
							M_AXI_ST_TVALID<='1';
						else
							evaluate_pixel:='1';
						end if;
					else
						if pixels_passed_width>offsetX + output_imgWidth-1 then
							if pixels_passed_width=input_imgWidth-1 then
								pixels_passed_width:=0;
								pixels_passed_height:=pixels_passed_height+1;
								skip_pixels_passed_height:=0;
							else
								pixels_passed_width:=pixels_passed_width+1;
							end if;
						else
							evaluate_pixel:='1';
						end if;
					end if;
				end if;
--*********************************    evaluate pixel    ****************************************
				if evaluate_pixel='1' then
					evaluate_pixel:='0';
					if pixels_passed_width=offsetX then
					    M_AXI_ST_TVALID<='1';
						pixels_passed_width:=pixels_passed_width+1;
						skip_pixels_passed_width:=0;
					else
						if skip_pixels_passed_width=skp then
						    M_AXI_ST_TVALID<='1';
							pixels_passed_width:=pixels_passed_width+1;
							skip_pixels_passed_width:=0;
							if pixels_passed_width=input_imgWidth then
							  pixels_passed_width:=0;
							  pixels_passed_height:=pixels_passed_height+1;
							  skip_pixels_passed_height:=0;
							end if;
						else
							pixels_passed_width:=pixels_passed_width+1;
							skip_pixels_passed_width:=skip_pixels_passed_width+1;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
end arch;
