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
    Port (  clk             : in STD_LOGIC;
            enable            : in STD_LOGIC;
            Beam_counter1   : in STD_LOGIC
          --  jc :out std_logic_vector(5 downto 0);
            --jb :out std_logic_vector(5 downto 0)
            );
end Main;

architecture Behavioral of Main is

  signal prescaler_pulse_limit           : integer := 5; -- количество импульсов клока, больше которого должен быть входной сигнал
  signal prescaler                : std_logic_vector(3  downto 0) ;
  --signal reset_bin_flag           : std_logic := '0';
  --signal out_vector               : std_logic_vector(11 downto 0) := (others=>'0');
  signal Count_flag               : std_logic; --флаг, разрешающий счёт, если время работы бина меньше лимита
  signal prescaler_pulse_limit_is_enough : std_logic; -- флаг, выставляется в 1, если входной импульс в 1 дольше, чем prescaler_pulse_limit клоков
  signal One_bin_data             : std_logic_vector(11 downto 0) := (others=>'0');
  signal Bin_number               : integer := 0; --std_logic_vector(11 downto 0) := (others=>'0');
  signal One_bin_time             : std_logic_vector(22 downto 0) := (others=>'0'); --при клоке в 500МГц получается 625к счётчиков на 1 бин
  signal Amount_of_bins           : integer := 30; -- std_logic_vector(7 downto 0) := x"A0"; --x"FA0"
  signal One_bin_time_limit       : std_logic_vector(11 downto 0) := x"FA0"; --А вообще здесь должно быть x"98968"
  type Bin_array is array (0 to 30) of std_logic_vector(11 downto 0);
  signal Out_Data           : Bin_array;
begin
--Amount_of_bins <= x"FA0";
--process switch on Count_flag if time of work of one bin is lesser than One_bin_time_limit
  One_bin_time_counter : process( clk, One_bin_time, Bin_number, One_bin_time_limit, Out_Data, Amount_of_bins)
  begin
-- Циклический перебор номеров бина
  if (One_bin_time >= One_bin_time_limit) then
      Bin_number <= Bin_number + 1;
      if Bin_number >= Amount_of_bins then
      Bin_number <= 0;
    end if;
      --change_bin_flag <= not change_bin_flag;
      --сброс зеачений посчитанного времени работы бина и установка разрешающего счёт флага в 0, если время работы бина больше заданного лимита
      One_bin_time <= (others=>'0');
      Count_flag <= '0';
      --�?нкрементация счётчика времени работы бина, если время работы одного бина меньше лимита  и флаг счёта в 1
    elsif rising_edge(clk) and One_bin_time <= One_bin_time_limit then
        One_bin_time <= One_bin_time + "1";
        Count_flag <= '1';
  end if;
  end process One_bin_time_counter;

-- --создание синхронного счётчика из несинхронного - завышаем частоту прескейлера, при достаточном количестве импульсов на входе, считаем, что произошло срабатывание входа синхронно с клоком
Prescaler_count: process( Beam_counter1, clk, prescaler_pulse_limit_is_enough)
  begin
if rising_edge(clk) then
    if Beam_counter1 = '0' then -- сброс прескейлера, если на входной ноге 0
    prescaler <= (others=>'0'); -- прескейлер не обнуляется, если импульс произошёл во время работы предыдущего бина. В этом случае импульс считается сработавшим в следующем бине. Надо обдумать.
        elsif Beam_counter1='1' then
        prescaler <= prescaler + '1';
    end if;
end if;
  end process Prescaler_count;
--Синхронная апись данных о входных срабатываниях в один 12битный счётчик выполняется при совпадении значения prescaler и prescaler_pulse_limit.
-- Синхронный сброс One_bin_data, если  Count_flag 0
One_bin_counter:  process( clk, Count_flag, prescaler, prescaler_pulse_limit)
begin
  if rising_edge(clk) then
    if Count_flag = '0' then
    One_bin_data <= (others=>'0');
      elsif prescaler = prescaler_pulse_limit then
           One_bin_data <= One_bin_data + "1";
    end if;
  end if;
end process One_bin_counter;

--запись данных одного синхронного счётчика в массив счётчиков размером в Amount_of_bins
write_to_array: process( clk, One_bin_data, Count_flag, Amount_of_bins, Bin_number)
begin
    if  falling_edge(Count_flag)  then --and Count_flag ='0'
      Out_Data(Bin_number) <= One_bin_data;
        --jc <= Out_Data(Bin_number)(11 downto 6);
        --jb <= Out_Data(Bin_number)(5 downto 0);
  end if;
end process write_to_array;


end Behavioral;
