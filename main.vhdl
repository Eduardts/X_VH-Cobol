-- VHDL Hardware IAM Module
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SecurityModule is
    Port ( 
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        user_id     : in  STD_LOGIC_VECTOR(31 downto 0);
        credential  : in  STD_LOGIC_VECTOR(255 downto 0);
        request     : in  STD_LOGIC;
        resource_id : in  STD_LOGIC_VECTOR(15 downto 0);
        grant       : out STD_LOGIC;
        error       : out STD_LOGIC_VECTOR(7 downto 0)
    );
end SecurityModule;

architecture Behavioral of SecurityModule is
    -- Internal signals
    signal hash_result    : STD_LOGIC_VECTOR(255 downto 0);
    signal access_valid   : STD_LOGIC;
    signal role_level     : STD_LOGIC_VECTOR(3 downto 0);
    
    -- State machine
    type state_type is (IDLE, HASH, CHECK_CRED, CHECK_ROLE, GRANT_ACCESS, DENY_ACCESS);
    signal current_state, next_state : state_type;

begin
    -- State machine process
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- Next state logic
    process(current_state, request, hash_result, access_valid)
    begin
        case current_state is
            when IDLE =>
                if request = '1' then
                    next_state <= HASH;
                else
                    next_state <= IDLE;
                end if;
                
            when HASH =>
                next_state <= CHECK_CRED;
                
            when CHECK_CRED =>
                if hash_result = credential then
                    next_state <= CHECK_ROLE;
                else
                    next_state <= DENY_ACCESS;
                end if;
                
            when CHECK_ROLE =>
                if access_valid = '1' then
                    next_state <= GRANT_ACCESS;
                else
                    next_state <= DENY_ACCESS;
                end if;
                
            when others =>
                next_state <= IDLE;
        end case;
    end process;
end Behavioral;

