	component hex is
		port (
			probe : in std_logic_vector(30 downto 0) := (others => 'X')  -- probe
		);
	end component hex;

	u0 : component hex
		port map (
			probe => CONNECTED_TO_probe  -- probes.probe
		);

