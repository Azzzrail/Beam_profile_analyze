----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 15.03.2018 15:46:54
-- Design Name:
-- Module Name: Main - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Main is
    Port (   clk             : in STD_LOGIC;
            spill_reset     : in STD_LOGIC;
            enable            : in STD_LOGIC;
            Out_test        : out STD_LOGIC;
            Beam_counter1   : in STD_LOGIC
            --Beam_counter2   : in STD_LOGIC
            );
end Main;

architecture Behavioral of Main is
  -- Creates a simple array of bytes, 128 bytes total:
  type Bin_array is array (0 to 100) of std_logic_vector(11 downto 0);

  signal Out_Data           : Bin_array;
  -- signal out_bit_vector     : bit_vector      (3999 downto 0) ;
  -- signal out_data_vector    : std_logic_vector (3999 downto 0) := (others=>'0');
  signal prescaler          : std_logic_vector(3  downto 0) ;
  signal reset_bin_flag         : std_logic := '0';
  signal out_vector         : std_logic_vector(11 downto 0) := (others=>'0');
  signal Count_flag         : std_logic;
  signal prescaler_wait_flag: std_logic;
  signal One_bin_data       : std_logic_vector(11 downto 0) := (others=>'0');
  signal Bin_number         : integer := 0; --std_logic_vector(11 downto 0) := (others=>'0');
  signal One_bin_time       : std_logic_vector(22 downto 0) := (others=>'0'); --при клоке в 500МГц получается 625к счётчиков на 1 бин
  signal Amount_of_bins     : integer := 100; -- std_logic_vector(7 downto 0) := x"A0"; --x"FA0"
  signal One_bin_time_limit : std_logic_vector(7 downto 0) := x"A0"; --А вообще здесь должно быть x"98968"
begin
--Amount_of_bins <= x"FA0";
--process switch on Count_flag if time of work of one bin is lesser than One_bin_time_limit
  One_bin_time_counter : process( clk, One_bin_time, Bin_number, One_bin_time_limit, Out_Data)
  begin

  if (One_bin_time >= One_bin_time_limit) then
      Bin_number <= Bin_number + 1;
      if Bin_number >= Amount_of_bins then
      Bin_number <= 0;
    end if;
      --change_bin_flag <= not change_bin_flag;
      One_bin_time <= (others=>'0');
      Count_flag <= '0';
  elsif rising_edge(clk) and One_bin_time <= One_bin_time_limit then
      One_bin_time <= One_bin_time + "1";
      Count_flag <= '1';
  end if;
  end process One_bin_time_counter; 

-- --
-- Prescaler_count: process( Beam_counter1, clk, prescaler_wait_flag)
--   begin
--
--     if  Beam_counter1='0' and rising_edge(clk) then
--       prescaler_wait_flag <= '1';
--       if Beam_counter1='1' then
--       --  prescaler <= (others=>'0');
--         prescaler_wait_flag <= '0';
--       end if;
--     end if;
--
--     if clk'event and clk='1' and prescaler_wait_flag = '0' then
--       prescaler <= prescaler + '1';
--     end if;
--   end process Prescaler_count;

One_bin_counter:  process( Beam_counter1, clk, One_bin_data, Count_flag, prescaler)
begin
  if Count_flag  = '0' then
  One_bin_data <= (others=>'0');
  elsif Beam_counter1 = '1' and rising_edge(clk)  then
        One_bin_data <= One_bin_data + "1";
    prescaler <= (others=>'0');
end if;
end process One_bin_counter;


  write_to_array: process( clk, One_bin_data, Count_flag, Amount_of_bins, Bin_number)

  --variable I : natural := 0;
begin

  if rising_edge(clk) then
  end if;
    if  falling_edge(Count_flag)  then --and Count_flag ='0'
      Out_Data(Bin_number) <= One_bin_data;
  end if;
end process write_to_array;


end Behavioral;
