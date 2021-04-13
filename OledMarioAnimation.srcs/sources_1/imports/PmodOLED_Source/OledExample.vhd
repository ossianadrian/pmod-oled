----------------------------------------------------------------------------------
-- Company: 
-- Student: Ossian Adrian
-- 
-- Create Date:    14/12/2019
-- Module Name:    
-- Project Name: 	 PmodOLED
-- Tool versions:  Vivado 2018.3
-- Description: Demo for the PmodOLED.  First displays the Mario Characters for ~4 seconds and then
--				Clears the display, waits for a ~1 second and then displays an animation with Mario
--
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity OledMarioAnimation is
    Port ( CLK 	: in  STD_LOGIC; --System CLK
			  RST 	: in	STD_LOGIC; --Synchronous Reset
			  AllChars: in STD_LOGIC; --Button to show all Characters
			  Animation: in STD_LOGIC; --Button to show the animation
			  EN		: in  STD_LOGIC; --Example block enable pin
			  CS  	: out STD_LOGIC; --SPI Chip Select
			  SDO		: out STD_LOGIC; --SPI Data out
			  SCLK	: out STD_LOGIC; --SPI Clock
			  DC		: out STD_LOGIC; --Data/Command Controller
			  FIN  	: out STD_LOGIC);--Finish flag for example block
end OledMarioAnimation;

architecture Behavioral of OledMarioAnimation is

--SPI Controller Component
COMPONENT SpiMarioLib
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         SPI_EN : IN  std_logic;
         SPI_DATA : IN  std_logic_vector(7 downto 0);
         CS : OUT  std_logic;
         SDO : OUT  std_logic;
         SCLK : OUT  std_logic;
         SPI_FIN : OUT  std_logic
        );
    END COMPONENT;

--Delay Controller Component
COMPONENT DelayMilliseconds
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         DELAY_MS : IN  std_logic_vector(11 downto 0);
         DELAY_EN : IN  std_logic;
         DELAY_FIN : OUT  std_logic
        );
    END COMPONENT;
	 
--Character Library, Latency = 1 --this is property of Digilent
COMPONENT charLib
  PORT (
    clka : IN STD_LOGIC; --Attach System Clock to it
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0); --First 8 bits is the ASCII value of the character the last 3 bits are the parts of the char
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) --Data byte out
  );
END COMPONENT;

COMPONENT MarioLib
  PORT (
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0); --First 8 bits is the ASCII value of the character the last 3 bits are the parts of the char
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) --Data byte out
  );
END COMPONENT;

--States for state machine
type states is (Idle,
				ClearDC,
				SetPage,
				PageNum,
				LeftColumn1,
				LeftColumn2,
				SetDC,
				Wait1,
				ClearScreen,
				Wait2,
				MarioScreen0,
				MarioScreen1,
				MarioScreen2,
				MarioScreen3,
				MarioScreen4,
				MarioScreen5,
				MarioScreen6,
				MarioScreen7,
				MarioScreen8,
				MarioScreen9,
				MarioScreen10,
				MarioScreen11,
				MarioScreen12,
				MarioScreen13,
				MarioScreenAllChars,
				MarioScreenSmall,
				MarioScreenBig,
				MarioScreenSmall0,MarioScreenSmall1,MarioScreenSmall2,MarioScreenSmall3,MarioScreenSmall4,MarioScreenSmall5,MarioScreenSmall6,MarioScreenSmall7,MarioScreenSmall8,
				WaitMore0,WaitMore1,WaitMore2,WaitMore3,WaitMore4,WaitMore5,WaitMore6,WaitMore7,WaitMore8,WaitMore9,WaitMore10,WaitMore11,WaitMore12,WaitMore13,
				WaitLess0,WaitLess1,WaitLess2,WaitLess3,WaitLess4,WaitLess5,WaitLess6,WaitLess7,WaitLess8,
				IdleAllChars,
				UpdateScreen,
				SendChar1,
				SendChar2,
				SendChar3,
				SendChar4,
				SendChar5,
				SendChar6,
				SendChar7,
				SendChar8,
				ReadMem,
				ReadMem2,
				Done,
				Transition1,
				Transition2,
				Transition3,
				Transition4,
				Transition5
					);
type OledMem is array(0 to 3, 0 to 15) of STD_LOGIC_VECTOR(7 downto 0);

--Variable that contains what the screen will be after the next UpdateScreen state
signal current_screen : OledMem; 
--Constant that fills the screen with blank (spaces) entries
constant clear_screen : OledMem :=   ((X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20"),	
												(X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20"),
												(X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20"),
												(X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20"));
--Constant that holds "This is Digilent's PmodOLED"
constant digilent_screen : OledMem:= ((X"00",X"01",X"02",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"03",X"04",X"05",X"FF",X"FF",X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"06",X"07",X"08",X"FF",X"FF",X"0E",X"0F",X"FF",X"FF",X"12",X"13",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"09",X"0A",X"0B",X"FF",X"FF",X"10",X"11",X"FF",X"FF",X"14",X"15",X"FF",X"FF",X"FF",X"FF",X"FF"));
--Constant with all Characters from my library																	
constant mario_screen_all_characters : OledMem:= ((X"00",X"01",X"02",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"03",X"04",X"05",X"FF",X"FF",X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"06",X"07",X"08",X"FF",X"FF",X"0E",X"0F",X"FF",X"FF",X"12",X"13",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"09",X"0A",X"0B",X"FF",X"FF",X"10",X"11",X"FF",X"FF",X"14",X"15",X"FF",X"FF",X"FF",X"FF",X"FF"));
--A bunch of constants that show how the mushroom is going to the small mario									 									  
constant mario_screen1 : OledMem:= ((X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0E",X"0F",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"12",X"13",X"FF"),
									  (X"10",X"11",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"14",X"15",X"FF"));									  
constant mario_screen2 : OledMem:= ((X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0E",X"0F",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"12",X"13",X"FF",X"FF"),
									  (X"10",X"11",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"14",X"15",X"FF",X"FF"));		
constant mario_screen3 : OledMem:= ((X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0E",X"0F",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"12",X"13",X"FF",X"FF",X"FF"),
									  (X"10",X"11",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"14",X"15",X"FF",X"FF",X"FF"));
constant mario_screen4 : OledMem:= ((X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0E",X"0F",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"12",X"13",X"FF",X"FF",X"FF",X"FF"),
									  (X"10",X"11",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"14",X"15",X"FF",X"FF",X"FF",X"FF"));									  
constant mario_screen5 : OledMem:= ((X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0E",X"0F",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"12",X"13",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"10",X"11",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"14",X"15",X"FF",X"FF",X"FF",X"FF",X"FF"));									  									  
constant mario_screen6 : OledMem:= ((X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0E",X"0F",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"12",X"13",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"10",X"11",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"14",X"15",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"));									  						  
constant mario_screen7 : OledMem:= ((X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0E",X"0F",X"FF",X"FF",X"FF",X"FF",X"FF",X"12",X"13",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"10",X"11",X"FF",X"FF",X"FF",X"FF",X"FF",X"14",X"15",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"));
constant mario_screen8 : OledMem:= ((X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0E",X"0F",X"FF",X"FF",X"FF",X"FF",X"12",X"13",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"10",X"11",X"FF",X"FF",X"FF",X"FF",X"14",X"15",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"));
constant mario_screen9 : OledMem:= ((X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0E",X"0F",X"FF",X"FF",X"FF",X"12",X"13",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"10",X"11",X"FF",X"FF",X"FF",X"14",X"15",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"));
constant mario_screen10 : OledMem:= ((X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0E",X"0F",X"FF",X"FF",X"12",X"13",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"10",X"11",X"FF",X"FF",X"14",X"15",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"));
constant mario_screen11 : OledMem:= ((X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0E",X"0F",X"FF",X"12",X"13",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"10",X"11",X"FF",X"14",X"15",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"));
constant mario_screen12 : OledMem:= ((X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0E",X"0F",X"12",X"13",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"10",X"11",X"14",X"15",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"));
constant mario_screen13 : OledMem:= ((X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0E",X"0F",X"13",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"10",X"11",X"15",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"));											  
--screen with smaller mario
constant mario_screen_small : OledMem:= ((X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0C",X"0D",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"0E",X"0F",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"10",X"11",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"));		
--screen with bigger mario
constant mario_screen_big : OledMem:= ((X"00",X"01",X"02",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"03",X"04",X"05",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"06",X"07",X"08",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"),
									  (X"09",X"0A",X"0B",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF",X"FF"));	   
--Current overall state of the state machine
signal current_state : states := Idle;
--State to go to after the SPI transmission is finished
signal after_state : states;
--State to go to after the set page sequence
signal after_page_state : states;
--State to go to after sending the character sequence
signal after_char_state : states;
--State to go to after the UpdateScreen is finished
signal after_update_state : states;

--Contains the value to be outputted to DC
signal temp_dc : STD_LOGIC := '0';

--Variables used in the Delay Controller Block
signal temp_delay_ms : STD_LOGIC_VECTOR (11 downto 0); --amount of ms to delay
signal temp_delay_en : STD_LOGIC := '0'; --Enable signal for the delay block
signal temp_delay_fin : STD_LOGIC; --Finish signal for the delay block

--Variables used in the SPI controller block
signal temp_spi_en : STD_LOGIC := '0'; --Enable signal for the SPI block
signal temp_spi_data : STD_LOGIC_VECTOR (7 downto 0) := (others => '0'); --Data to be sent out on SPI
signal temp_spi_fin : STD_LOGIC; --Finish signal for the SPI block

signal temp_char : STD_LOGIC_VECTOR (7 downto 0) := (others => '0'); --Contains ASCII value for character
signal temp_addr : STD_LOGIC_VECTOR (10 downto 0) := (others => '0'); --Contains address to BYTE needed in memory
signal temp_dout : STD_LOGIC_VECTOR (7 downto 0); --Contains byte outputted from memory
signal temp_dout2 : STD_LOGIC_VECTOR (7 downto 0); --Contains byte outputted from memory of the MarioLib
signal temp_page : STD_LOGIC_VECTOR (1 downto 0) := (others => '0'); --Current page
signal temp_index : integer range 0 to 15 := 0; --Current character on page

begin
DC <= temp_dc;
--Example finish flag only high when in done state
FIN <= '1' when (current_state = Done) else
					'0';
--Instantiate SPI Block
 SPI_COMP: SpiMarioLib PORT MAP (
          CLK => CLK,
          RST => RST,
          SPI_EN => temp_spi_en,
          SPI_DATA => temp_spi_data,
          CS => CS,
          SDO => SDO,
          SCLK => SCLK,
          SPI_FIN => temp_spi_fin
        );
--Instantiate DelayMilliseconds
   DELAY_COMP: DelayMilliseconds PORT MAP (
          CLK => CLK,
          RST => RST,
          DELAY_MS => temp_delay_ms,
          DELAY_EN => temp_delay_en,
          DELAY_FIN => temp_delay_fin
        );
--Instantiate Memory Block
	CHAR_LIB_COMP : charLib
  PORT MAP (
    clka => CLK,
    addra => temp_addr,
    douta => temp_dout
  );
  
  --Instantiate Memory Block
	Drawing: MarioLib
  PORT MAP (
    addra => temp_addr,
    douta => temp_dout2
  );
  
	process (CLK)
	begin
		if(rising_edge(CLK)) then
		    
		    --test the buttons to see what state should we start with
            if (AllChars = '1') then
                current_state<= IdleAllChars;
                
            elsif Animation = '1' then
                current_state<= MarioScreen0;
                
            elsif RST = '1' then
                current_state<=MarioScreenAllChars;
		    
		    else 
		       
			case(current_state) is
				--Idle until EN pulled high than intialize Page to 0 and go to state MarioScreenAllChars afterwards
				when Idle => 
					if(EN = '1') then
						current_state <= ClearDC;
						after_page_state <= MarioScreenAllChars;
						temp_page <= "00";
					end if;
				--Set current_screen to constant mario_screen_all_characters and update the screen.  Go to state Wait1 afterwards
				when MarioScreenAllChars => 
					current_screen <= mario_screen_all_characters;
					current_state <= UpdateScreen;
					after_update_state <= Wait1;
				--Wait 4ms and go to ClearScreen
				when Wait1 => 
					temp_delay_ms <= "111110100000"; --4000
					after_state <= ClearScreen;
					current_state <= Transition3; --Transition3 = The delay transition states
				--set current_screen to constant clear_screen and update the screen. Go to state Wait2 afterwards
				when ClearScreen => 
					current_screen <= clear_screen;
					after_update_state <= Wait2;
					current_state <= UpdateScreen;
				--Wait 1ms and go to MarioScreen0
				when Wait2 =>
					temp_delay_ms <= "001111101000"; --1000
					after_state <= MarioScreen0;
					current_state <= Transition3; --Transition3 = The delay transition states
				--Set currentScreen to constant mario_screen1 and update the screen. Go to the next part of the animation afterwards
				--Wait ~0.2 seconds for each screen and update it afterwards
				when MarioScreen0 =>
					current_screen <= mario_screen1;
					after_update_state <= WaitMore0;
					current_state <= UpdateScreen;
				when WaitMore0 =>
					temp_delay_ms <= "001111101000"; --1000
					after_state <= MarioScreen1;
					current_state <= Transition3;
			    when MarioScreen1 =>
					current_screen <= mario_screen1;
					after_update_state <= WaitMore1;
					current_state <= UpdateScreen;
				when WaitMore1 =>
					temp_delay_ms <= "000011001000"; --200
					after_state <= MarioScreen2;
					current_state <= Transition3;
				when MarioScreen2 =>
					current_screen <= mario_screen2;
					after_update_state <= WaitMore2;
					current_state <= UpdateScreen;
				when WaitMore2 =>
					temp_delay_ms <= "000011001000"; --200
					after_state <= MarioScreen3;
					current_state <= Transition3;	
				when MarioScreen3 =>
					current_screen <= mario_screen3;
					after_update_state <= WaitMore3;
					current_state <= UpdateScreen;
				when WaitMore3 =>
					temp_delay_ms <= "000011001000"; --200
					after_state <= MarioScreen4;
					current_state <= Transition3;		
				when MarioScreen4 =>
					current_screen <= mario_screen4;
					after_update_state <= WaitMore4;
					current_state <= UpdateScreen;
				when WaitMore4 =>
					temp_delay_ms <= "000011001000"; --200
					after_state <= MarioScreen5;
					current_state <= Transition3;		
				when MarioScreen5 =>
					current_screen <= mario_screen5;
					after_update_state <= WaitMore5;
					current_state <= UpdateScreen;
				when WaitMore5 =>
					temp_delay_ms <= "000011001000"; --200
					after_state <= MarioScreen6;
					current_state <= Transition3;		
				when MarioScreen6 =>
					current_screen <= mario_screen6;
					after_update_state <= WaitMore6;
					current_state <= UpdateScreen;
				when WaitMore6 =>
					temp_delay_ms <= "000011001000"; --200
					after_state <= MarioScreen7;
					current_state <= Transition3;		
				when MarioScreen7 =>
					current_screen <= mario_screen7;
					after_update_state <= WaitMore7;
					current_state <= UpdateScreen;
				when WaitMore7 =>
					temp_delay_ms <= "000011001000"; --200
					after_state <= MarioScreen8;
					current_state <= Transition3;		
				when MarioScreen8 =>
					current_screen <= mario_screen8;
					after_update_state <= WaitMore8;
					current_state <= UpdateScreen;
				when WaitMore8 =>
					temp_delay_ms <= "000011001000"; --200
					after_state <= MarioScreen9;
					current_state <= Transition3;	
				when MarioScreen9 =>
					current_screen <= mario_screen9;
					after_update_state <= WaitMore9;
					current_state <= UpdateScreen;
				when WaitMore9 =>
					temp_delay_ms <= "000011001000"; --200
					after_state <= MarioScreen10;
					current_state <= Transition3;		
				when MarioScreen10=>
					current_screen <= mario_screen10;
					after_update_state <= WaitMore10;
					current_state <= UpdateScreen;
				when WaitMore10 =>
					temp_delay_ms <= "000011001000"; --200
					after_state <= MarioScreen11;
					current_state <= Transition3;		
				when MarioScreen11 =>
					current_screen <= mario_screen11;
					after_update_state <= WaitMore11;
					current_state <= UpdateScreen;
				when WaitMore11 =>
					temp_delay_ms <= "000011001000"; --200
					after_state <= MarioScreen12;
					current_state <= Transition3;		
				when MarioScreen12 =>
					current_screen <= mario_screen12;
					after_update_state <= WaitMore12;
					current_state <= UpdateScreen;
				when WaitMore12 =>
					temp_delay_ms <= "000011001000"; --200
					after_state <= MarioScreen13;
					current_state <= Transition3;	
				when MarioScreen13 =>
					current_screen <= mario_screen13;
					after_update_state <= WaitMore13;
					current_state <= UpdateScreen;
				when WaitMore13 =>
					temp_delay_ms <= "000011001000"; --200
					after_state <= MarioScreenSmall0;
					current_state <= Transition3;		
				--At this point, the mushroom dissapears and we show the Mario char "growing"
				--First we show the small Mario, then the bigger Mario. Then repeat this 4 times
				--Mario small
				when MarioScreenSmall0 =>
					current_screen <= mario_screen_small;
					after_update_state <= WaitLess0;
					current_state <= UpdateScreen;
				when WaitLess0 =>
					temp_delay_ms <= "000001100100"; --100
					after_state <= MarioScreenSmall1;
					current_state <= Transition3;
				--Mario bigger
				when MarioScreenSmall1 =>
					current_screen <= mario_screen_big;
					after_update_state <= WaitLess1;
					current_state <= UpdateScreen;
				when WaitLess1 =>
					temp_delay_ms <= "000001100100"; --100
					after_state <= MarioScreenSmall2;
					current_state <= Transition3;	
				--Mario small	
				when MarioScreenSmall2 =>
					current_screen <= mario_screen_small;
					after_update_state <= WaitLess2;
					current_state <= UpdateScreen;
				when WaitLess2 =>
					temp_delay_ms <= "000001100100"; --100
					after_state <= MarioScreenSmall3;
					current_state <= Transition3;
				--Mario bigger
				when MarioScreenSmall3 =>
					current_screen <= mario_screen_big;
					after_update_state <= WaitLess3;
					current_state <= UpdateScreen;
				when WaitLess3 =>
					temp_delay_ms <= "000001100100"; --100
					after_state <= MarioScreenSmall4;
					current_state <= Transition3;
				--MarioSmall
				when MarioScreenSmall4 =>
					current_screen <= mario_screen_small;
					after_update_state <= WaitLess4;
					current_state <= UpdateScreen;
				when WaitLess4 =>
					temp_delay_ms <= "000001100100"; --100
					after_state <= MarioScreenSmall5;
					current_state <= Transition3;
				--Mario bigger
				when MarioScreenSmall5 =>
					current_screen <= mario_screen_big;
					after_update_state <= WaitLess5;
					current_state <= UpdateScreen;
				when WaitLess5 =>
					temp_delay_ms <= "000001100100"; --100
					after_state <= MarioScreenSmall6;
					current_state <= Transition3;
				--Mario small
				when MarioScreenSmall6 =>
					current_screen <= mario_screen_small;
					after_update_state <= WaitLess6;
					current_state <= UpdateScreen;
				when WaitLess6 =>
					temp_delay_ms <= "000001100100"; --100
					after_state <= MarioScreenSmall7;
					current_state <= Transition3;
				--Mario bigger
				when MarioScreenSmall7 =>
					current_screen <= mario_screen_big;
					after_update_state <= Done;
					current_state <= UpdateScreen;
				--We go to this state if the up button is pressed. It only displays all the characters
				when IdleAllChars =>
				    current_screen <= mario_screen_all_characters;
				    after_update_state <= Done;
					current_state <= UpdateScreen;		
				--Do nothing until EN is deassertted and then current_state is Idle
				when Done			=>
					if(EN = '0') then
						current_state <= Idle;
					end if;
					
				--UpdateScreen State
				--1. Gets ASCII value from current_screen at the current page and the current spot of the page
				--2. If on the last character of the page transition update the page number, if on the last page(3)
				--			then the updateScreen go to "after_update_state" after 
				when UpdateScreen =>
					temp_char <= current_screen(CONV_INTEGER(temp_page),temp_index);
					if(temp_index = 15) then	
						temp_index <= 0;
						temp_page <= temp_page + 1;
						after_char_state <= ClearDC;
						if(temp_page = "11") then
							after_page_state <= after_update_state;
						else	
							after_page_state <= UpdateScreen;
						end if;
					else
						temp_index <= temp_index + 1;
						after_char_state <= UpdateScreen;
					end if;
					current_state <= SendChar1;
				
				--Update Page states
				--1. Sets DC to command mode
				--2. Sends the SetPage Command
				--3. Sends the Page to be set to
				--4. Sets the start pixel to the left column
				--5. Sets DC to data mode
				when ClearDC =>
					temp_dc <= '0';
					current_state <= SetPage;
				when SetPage =>
					temp_spi_data <= "00100010";
					after_state <= PageNum;
					current_state <= Transition1;
				when PageNum =>
					temp_spi_data <= "000000" & temp_page;
					after_state <= LeftColumn1;
					current_state <= Transition1;
				when LeftColumn1 =>
					temp_spi_data <= "00000000";
					after_state <= LeftColumn2;
					current_state <= Transition1;
				when LeftColumn2 =>
					temp_spi_data <= "00010000";
					after_state <= SetDC;
					current_state <= Transition1;
				when SetDC =>
					temp_dc <= '1';
					current_state <= after_page_state;
				--End Update Page States

				--Send Character States
				--1. Sets the Address to ASCII value of char with the counter appended to the end
				--2. Waits a clock for the data to get ready by going to ReadMem and ReadMem2 states
				--3. Send the byte of data given by the block Ram
				--4. Repeat 7 more times for the rest of the character bytes
				when SendChar1 =>
					temp_addr <= temp_char & "000";
					after_state <= SendChar2;
					current_state <= ReadMem;
				when SendChar2 =>
					temp_addr <= temp_char & "001";
					after_state <= SendChar3;
					current_state <= ReadMem;
				when SendChar3 =>
					temp_addr <= temp_char & "010";
					after_state <= SendChar4;
					current_state <= ReadMem;
				when SendChar4 =>
					temp_addr <= temp_char & "011";
					after_state <= SendChar5;
					current_state <= ReadMem;
				when SendChar5 =>
					temp_addr <= temp_char & "100";
					after_state <= SendChar6;
					current_state <= ReadMem;
				when SendChar6 =>
					temp_addr <= temp_char & "101";
					after_state <= SendChar7;
					current_state <= ReadMem;
				when SendChar7 =>
					temp_addr <= temp_char & "110";
					after_state <= SendChar8;
					current_state <= ReadMem;
				when SendChar8 =>
					temp_addr <= temp_char & "111";
					after_state <= after_char_state;
					current_state <= ReadMem;
				when ReadMem =>
					current_state <= ReadMem2;
				when ReadMem2 =>
					temp_spi_data <= temp_dout2; --this is the output from my MarioLib
					current_state <= Transition1;
				--End Send Character States
					
				--SPI transitions
				--1. Set SPI_EN to 1
				--2. Waits for SpiCtrl to finish
				--3. Goes to clear state (Transition5)
				when Transition1 =>
					temp_spi_en <= '1';
					current_state <= Transition2;
				when Transition2 =>
					if(temp_spi_fin = '1') then
						current_state <= Transition5;
					end if;
					
				--Delay Transitions
				--1. Set DELAY_EN to 1
				--2. Waits for Delay to finish
				--3. Goes to Clear state (Transition5)
				when Transition3 =>
					temp_delay_en <= '1';
					current_state <= Transition4;
			    --If the delay timer has passed, go to transition5
				when Transition4 =>
					if(temp_delay_fin = '1') then
						current_state <= Transition5;
					end if;
				
				--Clear transition
				--1. Sets both DELAY_EN and SPI_EN to 0
				--2. Go to after state
				when Transition5 =>
					temp_spi_en <= '0';
					temp_delay_en <= '0';
					current_state <= after_state;
				--END SPI transitions
				--END Delay Transitions
				--END Clear transition
			
				when others 		=>
					current_state <= Idle;
			end case;
		end if;
	  end if;
	end process;
	
end Behavioral;