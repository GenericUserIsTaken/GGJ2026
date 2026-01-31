extends Dialogue


const NO_MONEY_YET = -1
const THEY_HATE_ME = -2


static var money_give: int = NO_MONEY_YET


func dialogue() -> Array[DialogueOption]:
	if money_give > 0:
		await show("Thank you for the $%s" % money_give)
		return []
	elif money_give == THEY_HATE_ME:
		await show("I still hate you, by the way")
		await show("Just thought I'd throw that in")
		return [
			DialogueOption.new("Continue hating me", _option_still_hate_me),
			DialogueOption.new("Fine, I'll give you $300", _option_money.bind(300)),
		]
	else:
		await show("I am in a bit of a pickle")
		await show("Would you be able to help me?")
		return [
			DialogueOption.new("Yes", _option_yes),
			DialogueOption.new("No", _option_no),
		]


func _option_yes() -> Array[DialogueOption]:
	await show("Thank you so much!")
	await show("How much money do you want to give me?")
	var options: Array[DialogueOption]
	for i in 3:
		var money = (i + 1) * 100
		options.append(DialogueOption.new("$%s" % money, _option_money.bind(money)))
	return options


func _option_no() -> Array[DialogueOption]:
	money_give = THEY_HATE_ME
	await show("I HATE YOU AND I HOPE YOU [b][color=red]DIE[/color][/b]")
	return []


func _option_money(money_value: int) -> Array[DialogueOption]:
	money_give = money_value
	await show("Thanks for the $%s" % money_value)
	return []


func _option_still_hate_me() -> Array[DialogueOption]:
	await show("And I hate you too.")
	return []
