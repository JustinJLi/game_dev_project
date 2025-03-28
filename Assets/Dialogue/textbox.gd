extends MarginContainer

#Instances for the label and timer for the textbox
@onready var label = $MarginContainer/Label
@onready var timer = $LetterDisplayTimer

const MAX_WIDTH = 256 #maximum width of the textbox

#variables to hold the text and the index of each letter
var text = ""
var letter_index = 0

#Variables for timing between letter, space, and punctuation as letters appear for the text
var letter_time = 0.03
var space_time = 0.06
var punctuation_time = 0.2

signal finished_displaying() #Signal that actiates when the text is done being added to the textbox

#Function to display the text
func display_text(text_to_display: String):
	#Set the label text
	text = text_to_display
	label.text = text_to_display
	
	#Create a minimum textbox size so it stays in the screen
	await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	#Once max width is reached, wrap the text onto a new line
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized #wait for x
		await resized #wait for y
		custom_minimum_size.y = size.y
	
	#Calculate position of text box to display above interacted object
	global_position.x -= size.x / 2
	global_position.y -= size.y + 24
	
	#Rest label text if there was any, and display the letters one at a time
	label.text = ""
	_display_letter()
	
#Function that displays each letter of the text
func _display_letter():
	#Set the text to each letter of the line of dialog
	label.text += text[letter_index]
	
	#Move to the next letter until it reaches the end of the line of dialog
	letter_index += 1
	if letter_index >= text.length():
		finished_displaying.emit() #Emit signal indicating the text is done displaying
		return
	
	#Add timing delays between each character so that text doesn't appear all at once
	match text[letter_index]:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)

#Display letter once the previous letter is done displaying into the textbox
func _on_letter_display_timer_timeout() -> void:
	_display_letter()
