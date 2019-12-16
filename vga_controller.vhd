----------------------------------------------------------------------------------
-- Authors: Juan Carlos Ruiz Sicilia
-- 					Lorena Perez Aguilar
-- Module Name: VGA controller
-- Version: 1
-- 
-- Dependencies: 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity vga_controller is
    port ( 
        clk		        : in STD_LOGIC;     -- Clock
        rst			: in STD_LOGIC;     -- Reset
        h_sync	                : out STD_LOGIC;    -- Sincronizacion horizontal
  	v_sync			: out STD_LOGIC;	  -- Sincronizacion vertical
      	video_on		: out STD_LOGIC;
      	pixel_x			: out STD_LOGIC_VECTOR(9 downto 0);	-- Coordenada X del pixel
      	pixel_y			: out STD_LOGIC_VECTOR(9 downto 0));	-- Coordenada Y del pixel
end vga_controller;

architecture Behavioral of vga_controller is
      -- Parametros de la pantalla
	constant HD: INTEGER:=640; -- Area horizontal de la pantalla 
      constant HF: INTEGER:=16 ; -- Front porch horizontal
      constant HB: INTEGER:=48 ; --	Back porch horizontal
      constant HR: INTEGER:=96 ; -- Duracion del pulso horizontal
      constant VD: INTEGER:=480; -- Area vertical de la pantalla  
      constant VF: INTEGER:=10;  -- Front porch vertical
      constant VB: INTEGER:=33;  -- Back porch vertical
      constant VR: INTEGER:=2;   -- Duracion del pulso vertical
      constant uno: INTEGER:=1;  

      signal v_count_reg , v_count_next : unsigned(9 downto 0) ;
      signal h_count_reg , h_count_next : unsigned (9 downto 0) ;
      -- status signal
      signal h_end , v_end: std_logic; 
begin
      -- Contador de sincronizacion horizontal
      process
      begin
      	wait until rising_edge(clk);
      		if ((rst = '1') or (h_end = '1')) then
      			h_count_next <= (others => '0');
      		else
      			h_count_next <= h_count_next + 1;
		end if;
      end process;
      h_count_reg <= h_count_next;
      
      -- Contador de sincronizacion vertical
      process
      begin
      	wait until rising_edge(clk);
      		if rst = '1' then
      			v_count_next <= (others => '0');
      		elsif h_end = '1' then
      				if v_end = '1' then
      					v_count_next <= (others => '0');
      				else
      					v_count_next <= v_count_next + 1;
      				end if;
      		end if;
      end process;
      v_count_reg <= v_count_next;
      
      
      h_sync <= '1' when (h_count_reg >=(HD+HF)) and (h_count_reg<=(HD+HF+HR-uno)) else '0'; 
      v_sync <= '1' when (v_count_reg >=(VD+VF)) and (v_count_reg<=(VD+VF+VR-uno)) else '0'; 

      -- status
			h_end <= '1' when h_count_reg=(HD+HF+HB+HR-uno) else '0';
      v_end <= '1' when v_count_reg=(VD+VF+VB+VR-uno) else '0'; 
      -- video on/off 
      video_on <='1' when (h_count_reg<HD) and (v_count_reg<VD) else  '0'; 
      pixel_x <= STD_LOGIC_VECTOR(h_count_reg);
      pixel_y <= STD_LOGIC_VECTOR(v_count_reg);



end Behavioral;