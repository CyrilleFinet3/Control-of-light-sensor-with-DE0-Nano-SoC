library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
USE ieee.math_real.ALL;
use ieee.std_logic_arith.all;
 
entity light_TB is
end light_TB; 


architecture behavior of light_TB is

	constant clk_period	: time := 10 ns;

	component light is
	  port(

		--System 
		FPGA_CLK1_50   : in std_logic;
		reset : in std_logic;
		
		--I2C signals.
		sda : inout std_logic;
		scl : inout std_logic;

		-- Two registers to read the sensor
		reg1 : out std_logic_vector(15 downto 8);
		 reg2 : out std_logic_vector(7 downto 0)
	  );
	end component;
	
	component I2C_S_RX is
		generic(
			WR		: std_logic:= '0';
					-- device address
			DADDR	: std_logic_vector(6 downto 0):= "0100011";		   
					-- sub address
			ADDR	: std_logic_vector(7 downto 0):= "00100000"		
		);
		port(
			RST		: in std_logic;
			SCL		: in std_logic;
			SDA		: inout std_logic;
						-- Recepted over i2c data byte
			DOUT		: out std_logic_vector(7 downto 0);			   
			DATA_RDY	: out std_logic 					
		);
	end component;
		
	signal	FPGA_CLK1_50   : std_logic;
	signal 	reset : std_logic;
	signal sda :  std_logic;
	signal scl :  std_logic;
	signal reg1 : std_logic_vector(15 downto 8);
	signal reg2 : std_logic_vector(7 downto 0);
		 
	signal i2c_s_rx_data			: std_logic_vector(7 downto 0);
	signal i2c_s_rx_data_rdy	: std_logic;								
	
	BEGIN
	
  UUT:light
  port map(
		FPGA_CLK1_50       => FPGA_CLK1_50,
		reset   => reset,
		sda       => sda,
		scl      => scl,
		reg1        => reg1,
		reg2   => reg2
	);

	I_I2C_S_RX: I2C_S_RX
	port map (
		SCL 		=> scl,
		RST 		=> reset,
		SDA 		=> sda,
		DOUT 		=> i2c_s_rx_data,
		DATA_RDY	=> i2c_s_rx_data_rdy 
	); 	
	
	P_CLK: process 
	begin
		FPGA_CLK1_50 <= '1';
		wait for clk_period/2;
		FPGA_CLK1_50 <= '0';
		wait for clk_period/2;
	end process;
	
	P_RST_N: process
	begin	
		reset <= '0';	
		wait for clk_period*100;
		reset <= '1';			
		wait;
	end process;



end behavior;