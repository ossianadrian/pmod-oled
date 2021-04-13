----------------------------------------------------------------------------------
-- Company: 
-- Student: Ossian Adrian
-- 
-- Create Date:    15:14:14 10/10/2011 
-- Module Name:    SpiCtrlMarioLib
-- Project Name:   PmodOled Demo
-- Tool versions:  ISE 13.2
-- Description:    Spi block that sends SPI data formatted SCLK active low with
--					SDO changing on the falling edge
--
-- Revision: 1.0 - SPI completed
-- Revision 0.01 - File Created 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SpiMarioLib is
    Port ( CLK 		: in  STD_LOGIC; --System CLK
		   RST 		: in  STD_LOGIC; --RST
		   SPI_EN 	: in  STD_LOGIC; --SPI enable
		   SPI_DATA : in  STD_LOGIC_VECTOR (7 downto 0); --Byte to be sent
		   CS		: out STD_LOGIC; --Chip Select
           SDO 		: out STD_LOGIC; --SPI data out
           SCLK 	: out STD_LOGIC; --SPI clock
		   SPI_FIN	: out STD_LOGIC);--SPI finish signal
end SpiMarioLib;

architecture Behavioral of SpiMarioLib is

type states is (Idle,
				Send,
				HoldCS1,
				HoldCS2,
				HoldCS3,
				HoldCS4,
				Done);
					
signal curr_state : states := Idle; --current state for the state machine

signal shift_register	: STD_LOGIC_VECTOR(7 downto 0); --Shift register to shift out SPI_DATA saved when SPI_EN was set
signal shift_counter 	: STD_LOGIC_VECTOR(3 downto 0); --Keeps track how many bits of data were sent
signal clk_spi 		: STD_LOGIC := '1'; --Used as SCLK
signal counter 			: STD_LOGIC_VECTOR(4 downto 0) := "00000"; --Count clocks to be used to divide CLK
signal temp_sdo			: STD_LOGIC := '1'; --signal to assign to SDO

signal falling : STD_LOGIC := '0'; --signal indicating that the clk fell
begin
	clk_spi <= not counter(4); --SCLK = CLK / 32
	SCLK <= clk_spi;
	SDO <= temp_sdo; --Assigns the data to SDO output
	CS <= '1' when (curr_state = Idle and SPI_EN = '0') else
		'0';
	SPI_FIN <= '1' when (curr_state = Done) else
			'0';
			
	-- Divides the system clock by 32
	CLK_DIVIDER : process (CLK)
	begin
		if(rising_edge(CLK)) then
			if (curr_state = Send) then --start clock counter when in send state
				counter <= counter + 1;
			else --reset clock counter when not in send state
				counter <= (others => '0');
			end if;
		end if;
	end process;
	
	STATE_MACHINE : process (CLK)
	begin
		if(rising_edge(CLK)) then
			if(rst = '1') then 
				curr_state <= Idle;
			else
				case (curr_state) is
					when Idle => --Wait for spi_en
						if(spi_en = '1') then
							curr_state <= Send;
						end if;
					when Send => --Start sending bits, transition out when all bits are sent and SCLK is high
						if(shift_counter = "1000" and falling = '0') then
							curr_state <= HoldCS1;
						end if;
					when HoldCS1 => --Hold CS low
						curr_state <= HoldCS2;
					when HoldCS2 => --Hold CS low
						curr_state <= HoldCS3;
					when HoldCS3 => --Hold CS low
						curr_state <= HoldCS4;
					when HoldCS4 => --Hold CS low
						curr_state <= Done;
					when Done => --Finish SPI transimission wait for SPI_EN to go low
						if(SPI_EN = '0') then
							curr_state <= Idle;
						end if;
					when others =>
						curr_state <= Idle;
				end case;
			end if;
		end if;
	end process;
	

	
	SPI_SEND_BYTE : process (CLK) --sends SPI data formatted SCLK active low with SDO changing on the falling edge
	begin
		if(rising_edge(CLK)) then
			if(curr_state = Idle) then
				shift_counter <= "0000";
				shift_register <= SPI_DATA; --keeps placing SPI_DATA into shift_register so that when state goes to send it has the latest SPI_DATA
				temp_sdo <= '1';
			elsif(curr_state = Send) then
				if( clk_spi = '0' and falling = '0') then --if on the falling edge of Clk_divided
					falling <= '1'; --Indicate that it is passed the falling edge
					temp_sdo <= shift_register(7); --send the most significant bit
					shift_register <= shift_register(6 downto 0) & '0'; --Shift through SPI_DATA
					shift_counter <= shift_counter + 1; --Keep track of what bit it is on
				elsif(clk_spi = '1') then --on SCLK high reset the falling flag
					falling <= '0';
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;

