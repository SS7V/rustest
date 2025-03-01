/datum/mission/research/electric
	name = "Electrical storm research mission"
	desc = "We require data on the behavior of electrical storms in the system for an ongoing study. \
			Please anchor the attached sensor array to your ship and fly it through the storms.\
			It must be powered to collect the data. "
	value = 5000 // base value, before adding bonus for number of things to fly through
	duration = 30 MINUTES
	weight = 4

	var/datum/overmap/objective_type = /datum/overmap/event/electric
	var/obj/machinery/mission_scanner/scanner
	var/num_current = 0
	var/num_wanted = 5

/datum/mission/research/electric/New(...)
	num_wanted = rand(num_wanted - 1, num_wanted + 1)
	value += num_wanted * 2500
	return ..()

/datum/mission/research/electric/accept(datum/overmap/ship/controlled/acceptor, turf/accept_loc)
	. = ..()
	scanner = spawn_bound(/obj/machinery/mission_scanner, accept_loc, VARSET_CALLBACK(src, scanner, null))
	RegisterSignal(servant, COMSIG_OVERMAP_MOVED, .proc/ship_moved)

/datum/mission/research/electric/Destroy()
	scanner = null
	return ..()

/datum/mission/research/electric/turn_in()
	recall_bound(scanner)
	return ..()

/datum/mission/research/electric/give_up()
	recall_bound(scanner)
	return ..()

/datum/mission/research/electric/get_progress_string()
	return "[num_current]/[num_wanted]"

/datum/mission/research/electric/can_complete()
	. = ..()
	if(!.)
		return
	var/obj/docking_port/mobile/scanner_port = SSshuttle.get_containing_shuttle(scanner)
	return . && (num_current >= num_wanted) && (scanner_port?.current_ship == servant)

/datum/mission/research/electric/proc/ship_moved(datum/overmap/ship/controlled/ship, old_x, old_y)
	SIGNAL_HANDLER

	var/datum/overmap/over_obj
	var/obj/docking_port/mobile/scanner_port
	if(failed || (num_current >= num_wanted))
		return
	over_obj = locate(objective_type) in SSovermap.overmap_container[ship.x][ship.y]
	scanner_port = SSshuttle.get_containing_shuttle(scanner)
	if(!over_obj || !scanner.is_operational || scanner_port?.current_ship != servant)
		return
	num_current++

/datum/mission/research/ion
	name = "Ion storm research mission"
	desc = "We require data on the behavior of ion storms in the system for an ongoing study. \
			Please anchor the attached sensor array to your ship and fly it through the storms. \
			It must be powered to collect the data."
	value = 5000 // base value, before adding bonus for number of things to fly through
	duration = 30 MINUTES
	weight = 4

	var/datum/overmap/objective_type = /datum/overmap/event/emp
	var/obj/machinery/mission_scanner/scanner
	var/num_current = 0
	var/num_wanted = 5

/datum/mission/research/ion/New(...)
	num_wanted = rand(num_wanted - 1, num_wanted + 1)
	value += num_wanted * 2000
	return ..()

/datum/mission/research/ion/accept(datum/overmap/ship/controlled/acceptor, turf/accept_loc)
	. = ..()
	scanner = spawn_bound(/obj/machinery/mission_scanner, accept_loc, VARSET_CALLBACK(src, scanner, null))
	RegisterSignal(servant, COMSIG_OVERMAP_MOVED, .proc/ship_moved)

/datum/mission/research/ion/Destroy()
	scanner = null
	return ..()

/datum/mission/research/ion/turn_in()
	recall_bound(scanner)
	return ..()

/datum/mission/research/ion/give_up()
	recall_bound(scanner)
	return ..()

/datum/mission/research/ion/get_progress_string()
	return "[num_current]/[num_wanted]"

/datum/mission/research/ion/can_complete()
	. = ..()
	if(!.)
		return
	var/obj/docking_port/mobile/scanner_port = SSshuttle.get_containing_shuttle(scanner)
	return . && (num_current >= num_wanted) && (scanner_port?.current_ship == servant)

/datum/mission/research/ion/proc/ship_moved(datum/overmap/ship/controlled/ship, old_x, old_y)
	SIGNAL_HANDLER

	var/datum/overmap/over_obj
	var/obj/docking_port/mobile/scanner_port
	if(failed || (num_current >= num_wanted))
		return
	over_obj = locate(objective_type) in SSovermap.overmap_container[ship.x][ship.y]
	scanner_port = SSshuttle.get_containing_shuttle(scanner)
	if(!over_obj || !scanner.is_operational || scanner_port?.current_ship != servant)
		return
	num_current++

/datum/mission/research/meteor
	name = "Asteroid field research mission"
	desc = "We require data on the behavior of asteroid fields in the system for an ongoing study. \
			Please anchor the attached sensor array to your ship and fly it through the fields. \
			It must be powered to collect the data."
	value = 5000 // base value, before adding bonus for number of things to fly through
	duration = 30 MINUTES
	weight = 4

	var/datum/overmap/objective_type = /datum/overmap/event/meteor
	var/obj/machinery/mission_scanner/scanner
	var/num_current = 0
	var/num_wanted = 5

/datum/mission/research/meteor/New(...)
	num_wanted = rand(num_wanted - 1, num_wanted + 1)
	value += num_wanted * 3000
	return ..()

/datum/mission/research/meteor/accept(datum/overmap/ship/controlled/acceptor, turf/accept_loc)
	. = ..()
	scanner = spawn_bound(/obj/machinery/mission_scanner, accept_loc, VARSET_CALLBACK(src, scanner, null))
	RegisterSignal(servant, COMSIG_OVERMAP_MOVED, .proc/ship_moved)

/datum/mission/research/meteor/Destroy()
	scanner = null
	return ..()

/datum/mission/research/meteor/turn_in()
	recall_bound(scanner)
	return ..()

/datum/mission/research/meteor/give_up()
	recall_bound(scanner)
	return ..()

/datum/mission/research/meteor/get_progress_string()
	return "[num_current]/[num_wanted]"

/datum/mission/research/meteor/can_complete()
	. = ..()
	if(!.)
		return
	var/obj/docking_port/mobile/scanner_port = SSshuttle.get_containing_shuttle(scanner)
	return . && (num_current >= num_wanted) && (scanner_port?.current_ship == servant)

/datum/mission/research/meteor/proc/ship_moved(datum/overmap/ship/controlled/ship, old_x, old_y)
	SIGNAL_HANDLER

	var/datum/overmap/over_obj
	var/obj/docking_port/mobile/scanner_port
	if(failed || (num_current >= num_wanted))
		return
	over_obj = locate(objective_type) in SSovermap.overmap_container[ship.x][ship.y]
	scanner_port = SSshuttle.get_containing_shuttle(scanner)
	if(!over_obj || !scanner.is_operational || scanner_port?.current_ship != servant)
		return
	num_current++

/datum/mission/research/nebula
	name = "Nebula research mission"
	desc = "We require data on the behavior of asteroid fields in the system for an ongoing study. \
			Please anchor the attached sensor array to your ship and fly it through the fields. \
			It must be powered to collect the data."
	value = 2500 // base value, before adding bonus for number of things to fly through
	duration = 30 MINUTES
	weight = 8

	var/datum/overmap/objective_type = /datum/overmap/event/nebula
	var/obj/machinery/mission_scanner/scanner
	var/num_current = 0
	var/num_wanted = 8

/datum/mission/research/nebula/New(...)
	num_wanted = rand(num_wanted - 2, num_wanted + 2)
	value += num_wanted * 1000
	return ..()

/datum/mission/research/nebula/accept(datum/overmap/ship/controlled/acceptor, turf/accept_loc)
	. = ..()
	scanner = spawn_bound(/obj/machinery/mission_scanner, accept_loc, VARSET_CALLBACK(src, scanner, null))
	RegisterSignal(servant, COMSIG_OVERMAP_MOVED, .proc/ship_moved)

/datum/mission/research/nebula/Destroy()
	scanner = null
	return ..()

/datum/mission/research/nebula/turn_in()
	recall_bound(scanner)
	return ..()

/datum/mission/research/nebula/give_up()
	recall_bound(scanner)
	return ..()

/datum/mission/research/nebula/get_progress_string()
	return "[num_current]/[num_wanted]"

/datum/mission/research/nebula/can_complete()
	. = ..()
	if(!.)
		return
	var/obj/docking_port/mobile/scanner_port = SSshuttle.get_containing_shuttle(scanner)
	return . && (num_current >= num_wanted) && (scanner_port?.current_ship == servant)

/datum/mission/research/nebula/proc/ship_moved(datum/overmap/ship/controlled/ship, old_x, old_y)
	SIGNAL_HANDLER

	var/datum/overmap/over_obj
	var/obj/docking_port/mobile/scanner_port
	if(failed || (num_current >= num_wanted))
		return
	over_obj = locate(objective_type) in SSovermap.overmap_container[ship.x][ship.y]
	scanner_port = SSshuttle.get_containing_shuttle(scanner)
	if(!over_obj || !scanner.is_operational || scanner_port?.current_ship != servant)
		return
	num_current++

/datum/mission/research/wormhole
	name = "Wormhole research mission"
	desc = "We require data on the behavior of wormholes in the system for an ongoing study. \
			Please anchor the attached sensor array to your ship and fly it through the fields. \
			It must be powered to collect the data."
	value = 10000 // base value, before adding bonus for number of things to fly through
	duration = 30 MINUTES
	weight = 2

	var/datum/overmap/objective_type = /datum/overmap/event/wormhole
	var/obj/machinery/mission_scanner/scanner
	var/num_current = 0
	var/num_wanted = 1

/datum/mission/research/wormhole/New(...)
	num_wanted = rand(num_wanted - 0, num_wanted + 0)
	value += num_wanted * 30000
	return ..()

/datum/mission/research/wormhole/accept(datum/overmap/ship/controlled/acceptor, turf/accept_loc)
	. = ..()
	scanner = spawn_bound(/obj/machinery/mission_scanner, accept_loc, VARSET_CALLBACK(src, scanner, null))
	RegisterSignal(servant, COMSIG_OVERMAP_MOVED, .proc/ship_moved)

/datum/mission/research/wormhole/Destroy()
	scanner = null
	return ..()

/datum/mission/research/wormhole/turn_in()
	recall_bound(scanner)
	return ..()

/datum/mission/research/wormhole/give_up()
	recall_bound(scanner)
	return ..()

/datum/mission/research/wormhole/get_progress_string()
	return "[num_current]/[num_wanted]"

/datum/mission/research/wormhole/can_complete()
	. = ..()
	if(!.)
		return
	var/obj/docking_port/mobile/scanner_port = SSshuttle.get_containing_shuttle(scanner)
	return . && (num_current >= num_wanted) && (scanner_port?.current_ship == servant)

/datum/mission/research/wormhole/proc/ship_moved(datum/overmap/ship/controlled/ship, old_x, old_y)
	SIGNAL_HANDLER

	var/datum/overmap/over_obj
	var/obj/docking_port/mobile/scanner_port
	if(failed || (num_current >= num_wanted))
		return
	over_obj = locate(objective_type) in SSovermap.overmap_container[ship.x][ship.y]
	scanner_port = SSshuttle.get_containing_shuttle(scanner)
	if(!over_obj || !scanner.is_operational || scanner_port?.current_ship != servant)
		return
	num_current++

/*
		Research mission scanning machine
*/

/obj/machinery/mission_scanner
	name = "polymodal sensor array"
	desc = "A complicated scanning device that integrates numerous sensors, commonly used \
			to detect and measure a wide variety of astrophysical phenomena."
	icon_state = "scanner_unanchor"
	max_integrity = 500
	density = FALSE
	anchored = FALSE
	use_power = NO_POWER_USE
	idle_power_usage = 400
	processing_flags = START_PROCESSING_MANUALLY

/obj/machinery/mission_scanner/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(!. && default_unfasten_wrench(user, I))
		return TRUE

/obj/machinery/mission_scanner/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return
	density = anchorvalue
	if(anchorvalue)
		set_is_operational(TRUE)
		START_PROCESSING(SSmachines, src)
		use_power = IDLE_POWER_USE
	else
		set_is_operational(FALSE)
		STOP_PROCESSING(SSmachines, src)
		use_power = NO_POWER_USE
	power_change() // calls update_icon(), makes sure we're powered

/obj/machinery/mission_scanner/update_icon_state()
	. = ..()
	if(is_operational)
		icon_state = "scanner_power"
	else if(anchored)
		icon_state = "scanner_depower"
	else
		icon_state = "scanner_unanchor"
