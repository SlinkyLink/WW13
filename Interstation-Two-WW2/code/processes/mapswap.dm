var/process/mapswap/mapswap_process = null

/process/mapswap
	// map = required players
	var/list/maps = list(
		MAP_CITY = 0,
		MAP_FOREST = 0,
		MAP_PILLAR = 0)
	var/ready = TRUE
	var/admin_triggered = FALSE

/process/mapswap/setup()
	name = "mapswap"
	schedule_interval = 50 // every 5 seconds
	start_delay = 50
	fires_at_gamestates = list(GAME_STATE_PLAYING, GAME_STATE_FINISHED)
	mapswap_process = src

/process/mapswap/fire()
	// no SCHECK here
	if (is_ready())
		ready = FALSE
		vote.initiate_vote("map", "MapSwap Process", TRUE, list(src, "swap"))
		ticker.delay_end = TRUE
		if (ticker.finished)
			world << "<font color='purple'><b>The game will automatically restart in a couple of minutes.</b></font>"
		spawn (1500)
			// we weren't undelayed by an admin, so end automatically after giving the other server time to update
			if (ticker.delay_end && ticker.finished)
				ticker.delay_end = FALSE
				world.Reboot()

/process/mapswap/proc/is_ready()
	. = FALSE

	if (ready)
		if (admin_triggered)
			. = TRUE
		// 60 minutes have passed
		else if (ticks >= 720 || (map && istype(map, /obj/map_metadata/pillar) && ticks >= 240))
			. = TRUE
		// round will end in 5 minutes or less
		else if (map && map.next_win <= 3 && map.next_win != -1)
			. = TRUE
		else if (map && map.admins_triggered_roundend)
			. = TRUE
		else if (ticker.finished)
			. = TRUE
	return .

/process/mapswap/proc/swap(var/winner = "City")
	winner = uppertext(winner)
	if (!list(MAP_CITY, MAP_FOREST, MAP_PILLAR).Find(winner))
		winner = maps[1]
	if (shell())
		shell("cd && sudo python3 mapswap.py [winner]")
		log_debug("Ran mapswap.py with arg '[winner]' on the shell.")
	else
		log_debug("Failed to execute python shell command in mapswap process!")