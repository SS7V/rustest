/obj/item/grenade
	name = "grenade"
	desc = "It has an adjustable timer."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	item_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FLAMMABLE
	max_integrity = 40
	var/active = 0
	var/det_time = 50
	var/display_timer = 1
	var/clumsy_check = GRENADE_CLUMSY_FUMBLE
	var/sticky = FALSE
	// I moved the explosion vars and behavior to base grenades because we want all grenades to call [/obj/item/grenade/proc/prime] so we can send COMSIG_GRENADE_PRIME
	///how big of a devastation explosion radius on prime
	var/ex_dev = 0
	///how big of a heavy explosion radius on prime
	var/ex_heavy = 0
	///how big of a light explosion radius on prime
	var/ex_light = 0
	///how big of a flame explosion radius on prime
	var/ex_flame = 0

	// dealing with creating a [/datum/component/pellet_cloud] on prime
	/// if set, will spew out projectiles of this type
	var/shrapnel_type
	/// the higher this number, the more projectiles are created as shrapnel
	var/shrapnel_radius
	var/shrapnel_initialized

/obj/item/grenade/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] primes [src], then eats it! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	preprime(user, det_time)
	user.transferItemToLoc(src, user, TRUE)//>eat a grenade set to 5 seconds >rush captain
	sleep(det_time)//so you dont die instantly
	return BRUTELOSS

/obj/item/grenade/deconstruct(disassembled = TRUE)
	if(!disassembled)
		prime()
	if(!QDELETED(src))
		qdel(src)

/obj/item/grenade/proc/botch_check(mob/living/carbon/human/user)
	var/clumsy = HAS_TRAIT(user, TRAIT_CLUMSY)
	if(clumsy && (clumsy_check == GRENADE_CLUMSY_FUMBLE))
		if(prob(50))
			to_chat(user, "<span class='warning'>Huh? How does this thing work?</span>")
			preprime(user, 5, FALSE)
			return TRUE
	else if(!clumsy && (clumsy_check == GRENADE_NONCLUMSY_FUMBLE))
		to_chat(user, "<span class='warning'>You pull the pin on [src]. Attached to it is a pink ribbon that says, \"<span class='clown'>HONK</span>\"</span>")
		preprime(user, 5, FALSE)
		return TRUE
	else if(sticky && prob(50)) // to add risk to sticky tape grenade cheese, no return cause we still prime as normal after
		to_chat(user, "<span class='warning'>What the... [src] прилип к рукеr hand!</span>")
		ADD_TRAIT(src, TRAIT_NODROP, STICKY_NODROP)

/obj/item/grenade/examine(mob/user)
	. = ..()
	if(display_timer)
		if(det_time > 0)
			. += "The timer is set to [DisplayTimeText(det_time)]."
		else
			. += "[src] is set for instant detonation."


/obj/item/grenade/attack_self(mob/user)
	if(HAS_TRAIT(src, TRAIT_NODROP))
		to_chat(user, "<span class='notice'>You try prying [src] off your hand...</span>")
		if(do_after(user, 70, target=src))
			to_chat(user, "<span class='notice'>You manage to remove [src] from your hand.</span>")
			REMOVE_TRAIT(src, TRAIT_NODROP, STICKY_NODROP)

		return

	if(!active)
		if(!botch_check(user)) // if they botch the prime, it'll be handled in botch_check
			preprime(user)

/obj/item/grenade/proc/log_grenade(mob/user, turf/T)
	log_bomber(user, "has primed a", src, "for detonation")

/obj/item/grenade/proc/preprime(mob/user, delayoverride, msg = TRUE, volume = 60)
	var/turf/T = get_turf(src)
	var/area/B = get_area(user.loc)
	if(B.area_flags & SAFEZONE)
		to_chat(user, "<span class='warning'>Я не могу!</span>")
		return 0
	log_grenade(user, T) //Inbuilt admin procs already handle null users
	if(user)
		add_fingerprint(user)
		if(msg)
			to_chat(user, "<span class='warning'>Активирую [src]! [capitalize(DisplayTimeText(det_time))]!</span>")
	if(shrapnel_type && shrapnel_radius)
		shrapnel_initialized = TRUE
		AddComponent(/datum/component/pellet_cloud, projectile_type=shrapnel_type, magnitude=shrapnel_radius)
	playsound(src, 'sound/weapons/armbomb.ogg', volume, TRUE)
	active = TRUE
	icon_state = initial(icon_state) + "_active"
	SEND_SIGNAL(src, COMSIG_GRENADE_ARMED, det_time, delayoverride)
	addtimer(CALLBACK(src, .proc/prime), isnull(delayoverride)? det_time : delayoverride)

/obj/item/grenade/proc/prime()
	var/area/B = get_area(src.loc)
	if(B.area_flags & SAFEZONE)
		to_chat(loc, "<span class='warning'>[src] испаряется!</span>")
		qdel(src)
		return
	if(shrapnel_type && shrapnel_radius && !shrapnel_initialized) // add a second check for adding the component in case whatever triggered the grenade went straight to prime (badminnery for example)
		shrapnel_initialized = TRUE
		AddComponent(/datum/component/pellet_cloud, projectile_type=shrapnel_type, magnitude=shrapnel_radius)

	SEND_SIGNAL(src, COMSIG_GRENADE_PRIME)
	if(ex_dev || ex_heavy || ex_light || ex_flame)
		explosion(loc, ex_dev, ex_heavy, ex_light, flame_range = ex_flame)

/obj/item/grenade/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.dropItemToGround(src)

/obj/item/grenade/attackby(obj/item/W, mob/user, params)
	if(!active)
		if(W.tool_behaviour == TOOL_MULTITOOL)
			var/newtime = text2num(stripped_input(user, "Please enter a new detonation time", name))
			if (newtime != null && user.canUseTopic(src, BE_CLOSE))
				if(change_det_time(newtime))
					to_chat(user, "<span class='notice'>You modify the time delay. It's set for [DisplayTimeText(det_time)].</span>")
					if (round(newtime * 10) != det_time)
						to_chat(user, "<span class='warning'>The new value is out of bounds. The lowest possible time is 3 seconds and highest is 5 seconds. Instant detonations are also possible.</span>")
			return
		else if(W.tool_behaviour == TOOL_SCREWDRIVER)
			if(change_det_time())
				to_chat(user, "<span class='notice'>You modify the time delay. It's set for [DisplayTimeText(det_time)].</span>")
	else
		return ..()

/obj/item/grenade/proc/change_det_time(time) //Time uses real time.
	. = TRUE
	if(time != null)
		if(time < 3)
			time = 3
		det_time = round(clamp(time * 10, 0, 50))
	else
		var/previous_time = det_time
		switch(det_time)
			if (0)
				det_time = 30
			if (30)
				det_time = 50
			if (50)
				det_time = 0
		if(det_time == previous_time)
			det_time = 50

/obj/item/grenade/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/grenade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "атаку", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/obj/projectile/P = hitby
	if(damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(15))
		owner.visible_message("<span class='danger'>[attack_text] hits [owner]'s [src], setting it off! What a shot!</span>")
		var/turf/T = get_turf(src)
		log_game("A projectile ([hitby]) detonated a grenade held by [key_name(owner)] at [COORD(T)]")
		message_admins("A projectile ([hitby]) detonated a grenade held by [key_name_admin(owner)] at [ADMIN_COORDJMP(T)]")
		prime()
		return TRUE //It hit the grenade, not them

/obj/item/grenade/afterattack(atom/target, mob/user)
	. = ..()
	if(active)
		user.throw_item(target)

/// Don't call qdel() directly on the grenade after it booms, call this instead so it can still resolve its pellet_cloud component if it has shrapnel, then the component will qdel it
/obj/item/grenade/proc/resolve()
	if(shrapnel_type)
		moveToNullspace()
	else
		qdel(src)
