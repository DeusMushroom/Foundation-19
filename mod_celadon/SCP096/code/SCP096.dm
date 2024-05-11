/mob/living/scp096/get_status_tab_items()
	. = ..()
	for(var/mob/living/carbon/human/Ptarget in targets)
		if(Ptarget != null)
			. += "Real Name: [Ptarget.real_name]"
			. += "Job: [Ptarget.job]"
			. += "Locate X: [Ptarget.x]"
			. += "Locate Y: [Ptarget.y]"
			. += "Locate Z: [Ptarget.z]"
//
/mob/living/scp096/proc/handle_AI()
	switch(current_state)
		if(STATE_096_IDLE)
			if(prob(45) && ((world.time - emote_cooldown_track) > emote_cooldown))
				audible_message(pick("[src] cries.", "[src] sobs.", "[src] wails."))
				playsound(src, 'sounds/scp/096/096-idle.ogg', 80, ignore_walls = TRUE)
				emote_cooldown_track = world.time
		if(STATE_096_CHASING)
			//Find path to target
			for(var/mob/living/carbon/human/Ptarget in targets)
				if(LAZYLEN(current_path))
					break
				target = Ptarget
				lastTargetTurf = get_turf(target)
				current_path = get_path_to(src, target, maxJPSdistance)
			//If we have no more targets, we go back to idle
			if(!LAZYLEN(targets))
				current_state = STATE_096_IDLE
				icon_state = "scp"
				target = null
				current_path = null
				//This resets the screaming noise for everyone.
				for(var/mob/living/carbon/human/hearer in hearers(world.view, src))
					sound_to(hearer, sound(null))
				update_icon()
				return
			//If we havent found a path for any of our targets, we notify admins and switch ourselves to the first target in our list. Path code will also use byond's inherent pathfinding for this life call.
			if(!LAZYLEN(current_path))
				log_and_message_staff("Instance of SCP-[SCP.designation] failed to find paths for targets. Switching to byond pathfinding for current life iteration.", src, loc)
				target = targets[1]
				lastTargetTurf = get_turf(target)
			//If the target moved, we must regenerate the path list
			if(get_turf(target) != lastTargetTurf)
				current_path = get_path_to(src, target, maxJPSdistance)
				//if we cant path to target we reset the target
				if(!LAZYLEN(current_path))
					target = null
					return
				lastTargetTurf = get_turf(target)
		if(STATE_096_STAGGERED)
			if(world.time > stagger_counter)
				current_state = STATE_096_CHASING
