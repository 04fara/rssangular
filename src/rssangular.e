class
	RSSANGULAR

inherit

	WSF_LAUNCHABLE_SERVICE
		redefine
			initialize
		end

	APPLICATION_LAUNCHER [RSSANGULAR_EXECUTION]

create
	make_and_launch

feature {NONE}

	initialize
		do
			Precursor
			set_service_option ("port", 1010)
			set_service_option ("verbose", "yes")
		end

end
