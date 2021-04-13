----------------------------------------------------------------------------------
-- Company: 
-- Sudent: Ossian Adrian
-- 
-- Create Date:    14/12/2019
-- Module Name:    
-- Project Name:   
-- Tool versions:  
-- Description:    
--
----------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use ieee.std_logic_arith.all;

entity PmodOLED is
	Port ( 
		CLK 	: in  STD_LOGIC;
		RST 	: in  STD_LOGIC;
		BTNALLCHARS: in STD_LOGIC;
		BTNANIMATION: in STD_LOGIC;
		CS  	: out STD_LOGIC;
		SDIN	: out STD_LOGIC;
		SCLK	: out STD_LOGIC;
		DC		: out STD_LOGIC;
		RES	: out STD_LOGIC;
		VBAT	: out STD_LOGIC;
		VDD	: out STD_LOGIC);
end PmodOLED;

architecture Behavioral of PmodOLED is

component OledInit is
Port ( CLK 	: in  STD_LOGIC;
		RST 	: in	STD_LOGIC;
		EN		: in  STD_LOGIC;
		CS  	: out STD_LOGIC;
		SDO	: out STD_LOGIC;
		SCLK	: out STD_LOGIC;
		DC		: out STD_LOGIC;
		RES	: out STD_LOGIC;
		VBAT	: out STD_LOGIC;
		VDD	: out STD_LOGIC;
		FIN  : out STD_LOGIC);
end component;

component OledMarioAnimation is
    Port ( CLK 	: in  STD_LOGIC; --System CLK
			  RST 	: in	STD_LOGIC; --Synchronous Reset
			  AllChars: in STD_LOGIC; --Btn for showing all chars
			  Animation: in STD_LOGIC; --Btn for showing the animation
			  EN		: in  STD_LOGIC; -- block enable pin
			  CS  	: out STD_LOGIC; --SPI Chip Select
			  SDO		: out STD_LOGIC; --SPI Data out
			  SCLK	: out STD_LOGIC; --SPI Clock
			  DC		: out STD_LOGIC; --Data/Command Controller
			  FIN  	: out STD_LOGIC);--Finish
end component;

type states is (Idle,
					OledInitialize,
					OledMario);

signal current_state 	: states := Idle;

signal init_en				: STD_LOGIC := '0';
signal init_done			: STD_LOGIC;
signal init_cs				: STD_LOGIC;
signal init_sdo			: STD_LOGIC;
signal init_sclk			: STD_LOGIC;
signal init_dc				: STD_LOGIC;

signal mario_en			: STD_LOGIC := '0';
signal mario_cs			: STD_LOGIC;
signal mario_sdo		: STD_LOGIC;
signal mario_sclk		: STD_LOGIC;
signal mario_dc			: STD_LOGIC;
signal mario_done		: STD_LOGIC;

begin

	Init: OledInit port map(CLK, RST, init_en, init_cs, init_sdo, init_sclk, init_dc, RES, VBAT, VDD, init_done);
	Mario: OledMarioAnimation Port map(CLK, RST, BTNALLCHARS, BTNANIMATION, mario_en, mario_cs, mario_sdo, mario_sclk, mario_dc, mario_done);
	
	--MUXes to indicate which outputs are routed out depending on which block is enabled
	CS <= init_cs when (current_state = OledInitialize) else
			mario_cs;
	SDIN <= init_sdo when (current_state = OledInitialize) else
			mario_sdo;
	SCLK <= init_sclk when (current_state = OledInitialize) else
			mario_sclk;
	DC <= init_dc when (current_state = OledInitialize) else
			mario_dc;
	--END output MUXes
	
	--MUXes that enable blocks when in the proper states
	init_en <= '1' when (current_state = OledInitialize) else
					'0';
	mario_en <= '1' when (current_state = OledMario) else
					'0';
	--END enable MUXes
	

	process(CLK)
	begin
		if(rising_edge(CLK)) then
			if(RST = '1') then
				current_state <= Idle;
			else
				case(current_state) is
					when Idle =>
						current_state <= OledInitialize;
					--Go through the initialization sequence
					when OledInitialize =>
						if(init_done = '1') then
							current_state <= OledMario;
						end if;
					--Do Mario Animation and keep this state
					when OledMario =>
						if(mario_done = '1') then
							current_state <= OledMario;
						end if;
				end case;
			end if;
		end if;
	end process;
	
	
end Behavioral;

