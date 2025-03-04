/mob/living/silicon/ai/examine(mob/user)
	. = list("<span class='info'>This is [icon2html(src, user)] <EM>[src]</EM>!")
	if (stat == DEAD)
		. += "<hr><span class='deadsay'>It appears to be powered-down.</span>"
	else
		if (getBruteLoss())
			if (getBruteLoss() < 30)
				. += "<hr><span class='warning'>It looks slightly dented.</span>"
			else
				. += "<hr><span class='warning'><B>It looks severely dented!</B></span>"
		if (getFireLoss())
			if (getFireLoss() < 30)
				. += "<hr><span class='warning'>It looks slightly charred.</span>"
			else
				. += "<hr><span class='warning'><B>Its casing is melted and heat-warped!</B></span>"
		if(deployed_shell)
			. += "The wireless networking light is blinking."
		else if (!shunted && !client)
			. += "[src]Core.exe has stopped responding! NTOS is searching for a solution to the problem..."
	. += "</span>"

	. += ..()

/mob/living/silicon/ai/get_examine_string(mob/user, thats = FALSE)
	return null
