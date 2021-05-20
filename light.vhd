library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
USE ieee.math_real.ALL;
 use ieee.std_logic_arith.all;
 
entity light is
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
end light;

architecture RTL of light is
	
  constant clk_frequency : integer := 50_000_000;   --The clock frequency of the board used
  constant i2c_frequency : integer := 400_000;       --The I2C clock frequency.

  --constant DATA_WITH	: integer := 8;
	
									
	
	  --Signals for data exchange with the I2C controller.
  signal data_to_write : std_logic_vector(7 downto 0):= (others=> '0'); --data to wright to slave
  signal data_rd : std_logic_vector(7 downto 0):= (others=> '0');       --data to read from slave
  
  signal read_or_write : std_logic;                                     
  constant write : std_logic := '0';
  constant read  : std_logic := '1';
  
  signal transaction_active : std_logic; 
  signal controller_in_use  : std_logic;
  
  									
  signal i2c_m_addr_wr		: std_logic_vector(7 downto 0); --address of target slave
  		
		
  signal i2c_m_reg_rdy : std_logic :='0';     --ready send the register
  signal i2c_m_val_rdy : std_logic :='0';     --ready send value of the register	
  
  signal enable    : std_logic:= '0';   --latch in command
  signal busy      : std_logic:= '0';   --indicates transaction in progress

  
  	--flag if improper acknowledge from slave	
	signal ack_error			: std_logic:= '0'; 

  
   
  	constant DEVICE	: std_logic_vector(6 downto 0):= "0100011";		--device address
	-- reset command "0000 0111" when reset value=0
	
	constant opecode : std_logic_vector(7 downto 0):= "00100000";	--one time H resolution mode   
	
  


	-- Build an enumerated type for the state machine
	type state_type is (s0, s1, s2, s3, s4);
	signal state : state_type;
	
	component I2C_M is
		generic (	
			 input_clk				: integer := clk_frequency; 
			 bus_clk					: integer := i2c_frequency		   
		);
		port(
		 clk       : in     std_logic;                    --system clock
		 reset_n   : in     std_logic;                    --active low reset
		 ena       : in     std_logic;                    --latch-in command
		 addr      : in     std_logic_vector(7 downto 0); --address of target slave
		 rw        : in     std_logic;                    --'0' is write, '1' is read
		 data_wr   : in     std_logic_vector(7 downto 0); --data to write to slave
		 reg_rdy	  : out	  std_logic :='0';				  --ready send the register
		 val_rdy	  : out	  std_logic :='0';				  --ready send value of the register
		 busy      : out    std_logic :='0';              --indicates transaction in progress
		 data_rd   : out    std_logic_vector(7 downto 0); --data read from slave
		 ack_error : out std_logic;                       --flag if improper acknowledge from slave
		 sda       : inout  std_logic;                    --serial data output of I2C_M bus
		 scl       : inout  std_logic                   --serial clock output of I2C_M bus
		);                   
  end component;
  
  Begin
  
  UUT : I2C_M 
  port map(
		clk       => FPGA_CLK1_50,
		reset_n   => reset,
		ena       => enable,
		addr      => i2c_m_addr_wr,
		rw        => read_or_write,
		data_wr   => data_to_write,
		busy      => busy,
		val_rdy 	 => i2c_m_val_rdy,
		reg_rdy 	 => i2c_m_reg_rdy,
		data_rd   => data_rd,
		ack_error => ack_error,
		sda       => sda,
		scl       => scl
	);
	
	process(reset,FPGA_CLK1_50)
	begin
		--enable <= '1';
		if reset = '0' then
			--read_or_write := 0; --?
			i2c_m_addr_wr	<= (others => '1');
			data_to_write <= (others => '1'); 
			enable <= '0';   
			read_or_write <= '0'; 
			reg1 <=  ( others => '0' );
			reg2 <=  ( others => '0' );
			
		elsif rising_edge(FPGA_CLK1_50)then
			case state is
				
				when s0 => 
					if busy = '0' then  
						state <= s1;           			
						i2c_m_addr_wr <= DEVICE & '0';  --add 0 to write
						read_or_write <= '0';  
						--data to be written
						data_to_write <= opecode; --resolution
					end if;
				
				when s1 =>   
					enable <= '1';   
					if i2c_m_reg_rdy = '1' then  --mettre 0 au lieu de 1
						i2c_m_addr_wr <= DEVICE & '1';
						state <= s2; 
						read_or_write <= '1';
						
					end if;
				
				when s2 => 
					if i2c_m_val_rdy = '1' then    
					   enable <= '0';   
						state <= s3;
						--i2c_m_addr_wr <= DEVICE & '1'; --passe en mode lecture
						--read_or_write <= '1';
					end if;
				
				when s3 =>   
					enable <= '1';   
					if i2c_m_val_rdy = '1' then 
						state <= s4; 
						reg1 <= data_rd;
					end if;
				
				when s4 => 
					if i2c_m_val_rdy = '1' then    
						enable <= '0';  
						reg2 <=data_rd;						
						state <= s0;      --s2 ou s3 ? 
					end if; 
				
				
				
				when OTHERS =>  
					state <= s0; 
			end case; 
		end if;
	end process;
 END ARCHITECTURE RTL;
