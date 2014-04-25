require "selenium-webdriver"

class Driver

	# load selenium and target webpage
	def initialize(address)
		@selenium = Selenium::WebDriver.for :firefox
		@selenium.navigate.to(address)

		# get outer div to send keys to
		@container = @selenium.find_element(:class, "game-container")
	end

	# load board state from DOM
	def read_tiles

		# initialize 4x4 array
		board_matrix = []
		(0..3).each do |x|
			board_matrix[x] = []
			(0..3).each do |y|
				board_matrix[x][y] = 0
			end
		end

		# tile classes are of the form "tile tile-{value} tile-{x}-{y} {tile-modifier}"
		tiles = @selenium.find_elements(:class, "tile")
		tiles.map do |tile|
			
			# read position data from class labels
			class_split = tile.attribute("class").split(" ")
			value = class_split[1].split("-")[1].to_i
			position = [class_split[2].split("-")[2].to_i - 1, class_split[2].split("-")[3].to_i - 1]
			
			# load into 2-d array
			board_matrix[position[0]][position[1]] = value

		end

		return board_matrix
	end

	def send_keys(keys)
		@container.send_keys(keys)
	end

end

# returns symbol of proper keypress
def find_optimal_move(board_state)

	# check if match can be made down
	width = board_state.length

	# runs from bottom to top of columns to see if there's a match
	(0..(width-1)).each do |x|
		i = 1
		point = nil
		while i <= width
			if point && board_state[x][width-i] == point
				return :arrow_down
			elsif board_state[x][width-i] != 0
				point = board_state[x][width-i]
			end
			i += 1
		end
	end

	# keep it from getting stuck
	return (if Random.rand > 0.5 then :arrow_right else :arrow_left end)

end

# initialize selenium
driver = Driver.new "http://gabrielecirulli.github.io/2048/"
#driver = Driver.new "http://doge2048.com"

# 4x4 matrix to hold board state
tile_matrix = driver.read_tiles

# loop an artibrary number of times
# will eventually go until it loses (or wins)
150.times do
	driver.send_keys(find_optimal_move(driver.read_tiles))
	sleep(0.1)
end

#driver.send_keys(:arrow_left)
