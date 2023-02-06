{ lib, ... }:

let
	host = {
		name = "theseus";
		addr = "10.255.1.5";
		port = 9091;

		username = "anna";
		password-b64 = "TnV4ZVB1d3EwIUNvY2E=";
		# TODO base64 password converter
	};

	input = {
		MainForm.FirstRun = 0;

		Hosts = rec {
			Count = 1;
			Host1 = host.name;
			CurHost = Host1;
		};

		"Connection.${host.name}" = with host; {
			Host = addr;
			Port = port;

			UserName = username;
			Password = password-b64;
		};
	};

	ini = lib.generators.toINI { } input;
in {
	xdg.configFile = {
		#"Transmission Remote GUI/.transgui-wrapped.ini".text = ini;
	};
}
