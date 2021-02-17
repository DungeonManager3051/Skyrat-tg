
/datum/action/changeling/horror_form //Horror Form: turns the changeling into a terrifying abomination
	name = "Horror Form"
	desc = "We tear apart our human disguise, revealing our true form."
	helptext = "We will become an unstoppable force of destruction. We will be able to turn back into a human after some time. We require the absorption of at least one other human, and 15 extracts of DNA."
	icon_icon = 'modular_skyrat/modules/horrorform/icons/mob/actions/actions_changeling.dmi'
	button_icon = 'modular_skyrat/modules/horrorform/icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "horror_form"
	background_icon_state = "bg_changeling"
	chemical_cost = 50
	dna_cost = 4 //Tier 4
	req_dna = 15
	req_absorbs = 1
	req_human = 1
	req_stat = UNCONSCIOUS

/datum/action/changeling/horror_form/sting_action(mob/living/carbon/human/user)
	if(!user || user.notransform)
		return FALSE
	var/datum/antagonist/changeling/cdatum = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(world.time - cdatum.true_form_death < 1800)
		var/timeleft = (cdatum.true_form_death + 1800) - world.time
		to_chat(user,"<span class='warning'>We are still unable to change back at will! We need to wait [round(timeleft/600)+1] minutes.</span>")
		return FALSE
	user.visible_message("<span class='warning'>[user] grows into an abomination and lets out an awful scream!</span>", \
						"<span class='userdanger'>We cast off our petty shell and enter our true form!</span>")
	if(user.handcuffed)
		var/obj/O = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
		if(istype(O))
			qdel(O)
	if(user.legcuffed)
		var/obj/O = user.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
		if(istype(O))
			qdel(O)
	if(user.wear_suit && user.wear_suit.breakouttime)
		var/obj/item/clothing/suit/S = user.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		if(istype(S))
			qdel(S)
	if(istype(user.loc, /obj/structure/closet))
		var/obj/structure/closet/C = user.loc
		if(istype(C))
			if(C && user.loc == C)
				C.visible_message("<span class='warning'>[C]'s door breaks and opens!</span>")
				new /obj/effect/decal/cleanable/greenglow(C.drop_location())
				C.welded = FALSE
				C.locked = FALSE
				C.broken = TRUE
				C.open()

	var/mob/living/simple_animal/hostile/true_changeling/new_mob = new(get_turf(user))

	//Currently this is a thing as changeling ID's are not longer a thing
	//Feel free to re-add them whomever wants to -Azarak
	var/changeling_name
	if(user.gender == FEMALE)
		changeling_name = "Ms. "
	else if(user.gender == MALE)
		changeling_name = "Mr. "
	else
		changeling_name = "Mx. "
	changeling_name += pick(GLOB.possible_abductor_names) //Abductor suffixes are the same ones as changelings

	new_mob.real_name = changeling_name
	new_mob.name = new_mob.real_name
	new_mob.stored_changeling = user
	user.loc = new_mob
	user.status_flags |= GODMODE
	user.mind.transfer_to(new_mob)
	user.spawn_gibs()
	//feedback_add_details("changeling_powers","HF")
	return 1
