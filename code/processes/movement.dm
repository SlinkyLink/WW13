/process/movement

/process/movement/setup()
	name = "mob movement"
	schedule_interval = 0.3
	start_delay = 10
	fires_at_gamestates = list(GAME_STATE_PREGAME, GAME_STATE_SETTING_UP, GAME_STATE_PLAYING, GAME_STATE_FINISHED)
	priority = PROCESS_PRIORITY_VERY_HIGH
	processes.movement = src

/process/movement/fire()

	for (current in current_list)

		if (!current)
			catchBadType(current)
			clients -= current
			continue

		var/mob/M = current:mob

		if (!isDeleted(M))
			try
				if (M.client && (M.movement_eastwest || M.movement_northsouth))
					var/diag = FALSE
					var/list/movement_process_dirs = list()
					if (M.movement_eastwest)
						movement_process_dirs += M.movement_eastwest
					if (M.movement_northsouth)
						movement_process_dirs += M.movement_northsouth
					var/movedir = movement_process_dirs[movement_process_dirs.len]
					if (movement_process_dirs.len > 1 && !istank(M.loc))
						if (movement_process_dirs.Find(NORTH) && movement_process_dirs.Find(WEST))
							movedir = NORTHWEST
							diag = TRUE
						else if (movement_process_dirs.Find(NORTH) && movement_process_dirs.Find(EAST))
							movedir = NORTHEAST
							diag = TRUE
						else if (movement_process_dirs.Find(SOUTH) && movement_process_dirs.Find(WEST))
							movedir = SOUTHWEST
							diag = TRUE
						else if (movement_process_dirs.Find(SOUTH) && movement_process_dirs.Find(EAST))
							movedir = SOUTHEAST
							diag = TRUE
					M.client.Move(get_step(M, movedir), movedir, diag)
			catch(var/exception/e)
				catchException(e, M)
		else
			catchBadType(M)
			mob_list -= M

		current_list -= current
		PROCESS_TICK_CHECK

/process/movement/reset_current_list()
	if (current_list)
		current_list = null
	current_list = clients.Copy()

/process/movement/statProcess()
	..()
	stat(null, "[mob_list.len] mobs")

/process/movement/htmlProcess()
	return ..() + "[mob_list.len] mobs"