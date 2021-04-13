----------------------------------------------------------------------------------
-- Company: 
-- Student: Ossian Adrian
-- 
-- Create Date: 12/10/2019 06:33:17 PM
-- Design Name: 
-- Module Name: MarioLib - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: library with characters for Mario Animation
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MarioLib is
Port ( 

    addra: in std_logic_vector (10 downto 0);
    douta: out std_logic_vector (7 downto 0)
  );
end MarioLib;

--first we select the byte we transmit aka the column of the byte (from buttom to top)
--then depending on the character selected, we choose the corect column for each character
-- From 00 to 0B there are 12 chars that define the Bigger Mario character
-- FF means character NULL
-- From 0C to 11 there are 6 chars that define Small mario
-- From 12 to 15 there are 4 chars that define the mushroom

architecture Behavioral of MarioLib is
signal douta_temp: std_logic_vector (7 downto 0):="00000000";
begin


process(addra)


begin
    case( addra(2 downto 0) ) is
        when "000" => case ( addra(10 downto 3) ) is
                            when X"00" => douta_temp <= "00000000";
                            when X"01" => douta_temp <= "00011000";
                            when X"02" => douta_temp <= "01111100";
                            when X"03" => douta_temp <= "00000000";
                            
                            when X"04" => douta_temp <= "01100111";
                            when X"05" => douta_temp <= "01100011";
                            when X"06" => douta_temp <= "00000000";
                            when X"07" => douta_temp <= "11100100";
                            
                            when X"08" => douta_temp <= "11100111";
                            when X"09" => douta_temp <= "00000000";
                            when X"0A" => douta_temp <= "01001111";
                            when X"0B" => douta_temp <= "01101111";
                            
                            when X"0C" => douta_temp <= "00000000";
                            when X"0D" => douta_temp <= "01010000";
                            when X"0E" => douta_temp <= "00000000";
                            when X"0F" => douta_temp <= "01101100";
                            
                            when X"10" => douta_temp <= "00000000";
                            when X"11" => douta_temp <= "00011100";
                            when X"12" => douta_temp <= "00000000";
                            when X"13" => douta_temp <= "11100100";
                            
                            when X"14" => douta_temp <= "00000000";
                            when X"15" => douta_temp <= "00101101";
                            
                            when X"FF" => douta_temp <= "00000000";
                            
                            when others => douta_temp <= "00000000";
                      end case;
       when "001" => case ( addra(10 downto 3) ) is
                            when X"00" => douta_temp <= "00000000";
                            when X"01" => douta_temp <= "10001100";
                            when X"02" => douta_temp <= "11110000";
                            when X"03" => douta_temp <= "00000000";
                                                        
                            when X"04" => douta_temp <= "11001111";
                            when X"05" => douta_temp <= "00100011";
                            when X"06" => douta_temp <= "00000000";
                            when X"07" => douta_temp <= "11100011";
                            
                            when X"08" => douta_temp <= "10011110";
                            when X"09" => douta_temp <= "00000000";
                            when X"0A" => douta_temp <= "01011111";
                            when X"0B" => douta_temp <= "01000111";
                            
                            when X"0C" => douta_temp <= "00000000";
                            when X"0D" => douta_temp <= "01010000";
                            when X"0E" => douta_temp <= "00000000";
                            when X"0F" => douta_temp <= "10101001";
                            
                            when X"10" => douta_temp <= "00000000";
                            when X"11" => douta_temp <= "00011100";
                            when X"12" => douta_temp <= "00000000";
                            when X"13" => douta_temp <= "11100100";
                            
                            when X"14" => douta_temp <= "00000000";
                            when X"15" => douta_temp <= "00100101";
                            
                            when X"FF" => douta_temp <= "00000000";
                            
                            when others => douta_temp <= "00000000";
                      end case;  
       when "010" => case ( addra(10 downto 3) ) is
                            when X"00" => douta_temp <= "00000000";
                            when X"01" => douta_temp <= "11000100";
                            when X"02" => douta_temp <= "11110000";
                            when X"03" => douta_temp <= "00000000";
                            
                            when X"04" => douta_temp <= "11001111";
                            when X"05" => douta_temp <= "00110011";
                            when X"06" => douta_temp <= "00000000";
                            when X"07" => douta_temp <= "11000011";
                            
                            when X"08" => douta_temp <= "11111010";
                            when X"09" => douta_temp <= "00000000";
                            when X"0A" => douta_temp <= "01011111";
                            when X"0B" => douta_temp <= "00100011";
                            
                            when X"0C" => douta_temp <= "00000000";
                            when X"0D" => douta_temp <= "01110000";
                            when X"0E" => douta_temp <= "10000000";
                            when X"0F" => douta_temp <= "01111000";
                            
                            when X"10" => douta_temp <= "00000001";
                            when X"11" => douta_temp <= "01111110";
                            when X"12" => douta_temp <= "00000000";
                            when X"13" => douta_temp <= "11011100";
                            
                            when X"14" => douta_temp <= "00000000";
                            when X"15" => douta_temp <= "00101100";
                            
                            when X"FF" => douta_temp <= "00000000";
                            
                            
                            when others => douta_temp <= "00000000";
                      end case;      
       when "011" => case ( addra(10 downto 3) ) is
                            when X"00" => douta_temp <= "00000000";
                            when X"01" => douta_temp <= "01100100";
                            when X"02" => douta_temp <= "01100000";
                            when X"03" => douta_temp <= "00000000";
                            
                            when X"04" => douta_temp <= "10000100";
                            when X"05" => douta_temp <= "00111110";
                            when X"06" => douta_temp <= "00000000";
                            when X"07" => douta_temp <= "11000011";
                            
                            when X"08" => douta_temp <= "11111110";
                            when X"09" => douta_temp <= "00000000";
                            when X"0A" => douta_temp <= "01111111";
                            when X"0B" => douta_temp <= "00010001";
                            
                            when X"0C" => douta_temp <= "00000000";
                            when X"0D" => douta_temp <= "11000000";
                            when X"0E" => douta_temp <= "01100111";
                            when X"0F" => douta_temp <= "11010001";
                            
                            when X"10" => douta_temp <= "00110111";
                            when X"11" => douta_temp <= "01011101";
                            when X"12" => douta_temp <= "11000000";
                            when X"13" => douta_temp <= "00111000";
                            
                            when X"14" => douta_temp <= "00000011";
                            when X"15" => douta_temp <= "00100101";       
                            
                            
                            when X"FF" => douta_temp <= "00000000";
                            
                            when others => douta_temp <= "00000000";
                      end case;          
       when "100" => case ( addra(10 downto 3) ) is
                            when X"00" => douta_temp <= "00000000";
                            when X"01" => douta_temp <= "01100010";
                            when X"02" => douta_temp <= "00000000";
                            when X"03" => douta_temp <= "00000000";
                            
                            when X"04" => douta_temp <= "10010000";
                            when X"05" => douta_temp <= "00011100";
                            when X"06" => douta_temp <= "00111110";
                            when X"07" => douta_temp <= "11000011";
                            
                            when X"08" => douta_temp <= "00000100";
                            when X"09" => douta_temp <= "00000000";
                            when X"0A" => douta_temp <= "01100111";
                            when X"0B" => douta_temp <= "00001011";
                            
                            when X"0C" => douta_temp <= "11000000";
                            when X"0D" => douta_temp <= "11000000";
                            when X"0E" => douta_temp <= "00011001";
                            when X"0F" => douta_temp <= "01001010";
                            
                            when X"10" => douta_temp <= "01001110";
                            when X"11" => douta_temp <= "01001111";
                            when X"12" => douta_temp <= "00110000";
                            when X"13" => douta_temp <= "10111000";
                            
                            when X"14" => douta_temp <= "00000111";
                            when X"15" => douta_temp <= "00010111";
                            
                            when X"FF" => douta_temp <= "00000000";
                            
                            when others => douta_temp <= "00000000";
                      end case;      
       when "101" => case ( addra(10 downto 3) ) is
                            when X"00" => douta_temp <= "00000000";
                            when X"01" => douta_temp <= "01110010";
                            when X"02" => douta_temp <= "00000000";
                            when X"03" => douta_temp <= "10001111";
                            
                            when X"04" => douta_temp <= "10011000";
                            when X"05" => douta_temp <= "00010000";
                            when X"06" => douta_temp <= "11100011";
                            when X"07" => douta_temp <= "10100110";
                            
                            when X"08" => douta_temp <= "00000000";
                            when X"09" => douta_temp <= "00011110";
                            when X"0A" => douta_temp <= "00000011";
                            when X"0B" => douta_temp <= "00000110";
                            
                            when X"0C" => douta_temp <= "00100000";
                            when X"0D" => douta_temp <= "00000000";
                            when X"0E" => douta_temp <= "10010011";
                            when X"0F" => douta_temp <= "00001100";
                            
                            when X"10" => douta_temp <= "01011111";
                            when X"11" => douta_temp <= "00111000";
                            when X"12" => douta_temp <= "00011000";
                            when X"13" => douta_temp <= "10110000";
                            
                            when X"14" => douta_temp <= "00011100";
                            when X"15" => douta_temp <= "00001101";
                            
                            when X"FF" => douta_temp <= "00000000";
                            
                            when others => douta_temp <= "00000000";
                      end case;   
       when "110" => case ( addra(10 downto 3) ) is
                            when X"00" => douta_temp <= "11100000";
                            when X"01" => douta_temp <= "01110010";
                            when X"02" => douta_temp <= "00000000";
                            when X"03" => douta_temp <= "01010001";
                            
                            when X"04" => douta_temp <= "10110011";
                            when X"05" => douta_temp <= "00000000";
                            when X"06" => douta_temp <= "11000000";
                            when X"07" => douta_temp <= "10011000";
                            
                            when X"08" => douta_temp <= "00000000";
                            when X"09" => douta_temp <= "00110001";
                            when X"0A" => douta_temp <= "00000111";
                            when X"0B" => douta_temp <= "00000000";
                            
                            when X"0C" => douta_temp <= "10010000";
                            when X"0D" => douta_temp <= "00000000";
                            when X"0E" => douta_temp <= "01110111";
                            when X"0F" => douta_temp <= "00000000";
                            
                            when X"10" => douta_temp <= "01001000";
                            when X"11" => douta_temp <= "00000000";
                            when X"12" => douta_temp <= "11001000";
                            when X"13" => douta_temp <= "11000000";
                            
                            when X"14" => douta_temp <= "00100100";
                            when X"15" => douta_temp <= "00000011";
                            
                            when X"FF" => douta_temp <= "00000000";
                            
                            when others => douta_temp <= "00000000";
                      end case;   
       when "111" => case ( addra(10 downto 3) ) is
                            when X"00" => douta_temp <= "10110000";
                            when X"01" => douta_temp <= "01110010";
                            when X"02" => douta_temp <= "00000000";
                            when X"03" => douta_temp <= "01100001";
                            
                            when X"04" => douta_temp <= "10110000";
                            when X"05" => douta_temp <= "00000000";
                            when X"06" => douta_temp <= "11011000";
                            when X"07" => douta_temp <= "11100011";
                            
                            when X"08" => douta_temp <= "00000000";
                            when X"09" => douta_temp <= "01100111";
                            when X"0A" => douta_temp <= "00111111";
                            when X"0B" => douta_temp <= "00000000";
                            
                            when X"0C" => douta_temp <= "10010000";
                            when X"0D" => douta_temp <= "00000000";
                            when X"0E" => douta_temp <= "01100000";
                            when X"0F" => douta_temp <= "00000000";
                            
                            when X"10" => douta_temp <= "01111110";
                            when X"11" => douta_temp <= "00000000";
                            when X"12" => douta_temp <= "11100100";
                            when X"13" => douta_temp <= "00000000";
                            
                            when X"14" => douta_temp <= "00100101";
                            when X"15" => douta_temp <= "00000000";
                            
                            when X"FF" => douta_temp <= "00000000";
                            
                            when others => douta_temp <= "00000000";
                      end case;   
                      
        when others => douta_temp <= X"00";     
    
    end case;
    
end process;
 
douta <= douta_temp;


end Behavioral;
