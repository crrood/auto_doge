require "selenium-webdriver"

# load driver
driver = Selenium::WebDriver.for :firefox
driver.navigate.to "http://doge2048.com"

# get outer div to send keys to
container = driver.find_element(:class, "game-container")

# load board state
tiles = driver.find_elements(:class, "tile")
tile_matrix = [[],[],[],[]]

tiles.map do |tile|
	
	# read position data from class labels
	class_split = tile.attribute("class").split(" ")
	value = class_split[1].split("-")[1]
	position = [class_split[2].split("-")[2].to_i - 1, class_split[2].split("-")[3].to_i - 1]
	
	# load into 2-d array
	tile_matrix[position[0]][position[1]] = value
	
end

puts tile_matrix.to_s

# miscellaneous jiberish that I don't want to forget
sleep(3)
container.send_keys :arrow_left
driver.quit