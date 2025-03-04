/obj/projectile/hivebotbullet
	damage = 10
	damage_type = BRUTE

/mob/living/simple_animal/hostile/hivebot
	name = "хайвбот"
	desc = "Маленький робот."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC
	health = 15
	maxHealth = 15
	healable = 0
	melee_damage_lower = 2
	melee_damage_upper = 3
	attack_verb_continuous = "клацает"
	attack_verb_simple = "клацает"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	projectilesound = 'sound/weapons/gun/pistol/shot.ogg'
	projectiletype = /obj/projectile/hivebotbullet
	faction = list("hivebot")
	check_friendly_fire = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	possible_a_intents = list(INTENT_HELP, INTENT_GRAB, INTENT_DISARM, INTENT_HARM)
	minbodytemp = 0
	verb_say = "озвучивает"
	verb_ask = "задаётся"
	verb_exclaim = "декларирует"
	verb_yell = "вопит"
	bubble_icon = "machine"
	speech_span = SPAN_ROBOT
	del_on_death = 1
	minbodytemp = 0
	maxbodytemp = 600
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	var/alert_light

	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/hostile/hivebot/Initialize(mapload)
	. = ..()
	deathmessage = "[src] взрывается!"

/mob/living/simple_animal/hostile/hivebot/Aggro()
	. = ..()
	a_intent_change(INTENT_HARM)
	update_icons()
	if(prob(5))
		say(pick("ОБНАРУЖЕН НАРУШИТЕЛЬ!", "КОД 7-34.", "101010!!"), forced = type)

/mob/living/simple_animal/hostile/hivebot/LoseAggro()
	. = ..()
	a_intent_change(INTENT_HELP)

/mob/living/simple_animal/hostile/hivebot/a_intent_change(input as text)
	. = ..()
	update_icons()

/mob/living/simple_animal/hostile/hivebot/update_icons()
	QDEL_NULL(alert_light)
	if(a_intent != INTENT_HELP)
		icon_state = "[initial(icon_state)]_attack"
		alert_light = mob_light(6, 0.4, COLOR_RED_LIGHT)
	else
		icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/hivebot/death(gibbed)
	do_sparks(3, TRUE, src)
	new /obj/effect/spawner/lootdrop/waste/hivebot(loc)
	..(TRUE)

/mob/living/simple_animal/hostile/hivebot/range
	name = "хайвбот"
	desc = "Маленький робот с маленьким пистолетиком!"
	icon_state = "ranged"
	icon_living = "ranged"
	icon_dead = "ranged"
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/range/rockplanet
	faction = list("mining", "hivebot")

/mob/living/simple_animal/hostile/hivebot/rapid
	icon_state = "ranged"
	icon_living = "ranged"
	icon_dead = "ranged"
	ranged = TRUE
	rapid = 3
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/rapid/rockplanet
	faction = list("mining", "hivebot")

/mob/living/simple_animal/hostile/hivebot/strong
	name = "крепкий хайвбот"
	icon_state = "strong"
	icon_living = "strong"
	icon_dead = "strong"
	desc = "Маленький толстенький робот!"
	health = 80
	maxHealth = 80
	ranged = TRUE

/mob/living/simple_animal/hostile/hivebot/strong/rockplanet
	faction = list("mining", "hivebot")

/mob/living/simple_animal/hostile/hivebot/mechanic
	name = "хайвбот - механик"
	icon_state = "strong"
	icon_living = "strong"
	icon_dead = "strong"
	desc = "Маленький робот созданный для обслуживания улья ботов."
	health = 60
	maxHealth = 60
	ranged = TRUE
	rapid = 3
	gold_core_spawnable = HOSTILE_SPAWN
	var/datum/action/innate/hivebot/foamwall/foam

/mob/living/simple_animal/hostile/hivebot/mechanic/Initialize(mapload)
	. = ..()
	foam = new
	foam.Grant(src)

/mob/living/simple_animal/hostile/hivebot/mechanic/AttackingTarget()
	if(istype(target, /obj/machinery))
		var/obj/machinery/fixable = target
		if(fixable.obj_integrity >= fixable.max_integrity)
			to_chat(src, "<span class='warning'>Диагностика показывает, что эта машина находится на пике целостности.</span>")
			return
		to_chat(src, "<span class='warning'>Чиню...</span>")
		if(do_after(src, 50, target = fixable))
			fixable.obj_integrity = fixable.max_integrity
			do_sparks(3, TRUE, fixable)
			to_chat(src, "<span class='warning'>Успешно починил.</span>")
		return
	if(istype(target, /mob/living/simple_animal/hostile/hivebot))
		var/mob/living/simple_animal/hostile/hivebot/fixable = target
		if(fixable.health >= fixable.maxHealth)
			to_chat(src, "<span class='warning'>Диагностика показывает, что эта машина находится на пике целостности.</span>")
			return
		to_chat(src, "<span class='warning'>Чиню...</span>")
		if(do_after(src, 50, target = fixable))
			fixable.revive(full_heal = TRUE, admin_revive = TRUE)
			do_sparks(3, TRUE, fixable)
			to_chat(src, "<span class='warning'>Успешно починил.</span>")
		return
	return ..()

/datum/action/innate/hivebot
	background_icon_state = "bg_default"

/datum/action/innate/hivebot/foamwall
	name = "Foam Wall"
	desc = "Creates a foam wall that resists against the vacuum of space."

/datum/action/innate/hivebot/foamwall/Activate()
	var/mob/living/simple_animal/hostile/hivebot/H = owner
	var/turf/T = get_turf(H)
	if(T.density)
		to_chat(H, "<span class='warning'>There's already something on this tile!</span>")
		return
	to_chat(H, "<span class='warning'>You begin to create a foam wall at your position...</span>")
	if(do_after(H, 50, target = H))
		for(var/obj/structure/foamedmetal/FM in T.contents)
			to_chat(H, "<span class='warning'>There's already a foam wall on this tile!</span>")
			return
		new /obj/structure/foamedmetal(H.loc)
		playsound(get_turf(H), 'sound/effects/extinguish.ogg', 50, TRUE, -1)


/mob/living/simple_animal/hostile/hivebot/wasteplanet
	name = "хайвбот"
	desc = "Маленький робот. Он выглядит ржавым."
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	ranged = FALSE
	faction = list("mining", "hivebot")
	health = 30
	maxHealth = 30
	healable = 0
	melee_damage_lower = 5
	melee_damage_upper = 15


/mob/living/simple_animal/hostile/hivebot/wasteplanet/ranged
	ranged = TRUE
	icon_state = "ranged"
	icon_living = "ranged"
	icon_dead = "ranged"
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/wasteplanet/ranged/rapid
	rapid = 3

/mob/living/simple_animal/hostile/hivebot/wasteplanet/strong
	name = "крепкий хайвбот"
	icon_state = "strong"
	icon_living = "strong"
	icon_dead = "strong"
	desc = "Маленький робот. Он выглядит старым."
	health = 80
	maxHealth = 80
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
