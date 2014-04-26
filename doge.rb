require "selenium-webdriver"
require "ruby-prof"

class Driver

	# load selenium and target webpage
	def initialize(address)
		@selenium = Selenium::WebDriver.for :firefox
		@selenium.navigate.to(address)

		# get outer div to send keys to
		@container = @selenium.find_element(:class, "game-container")
	end

	# get list of elements of given class
	def get_elements_by_class(class_name)
		@selenium.find_elements(:class, class_name)
	end

	# load board state from DOM
	def read_tiles

		# initialize 4x4 array
		board_matrix = Array.new([[0, 0, 0, 0],
						[0, 0, 0, 0],
						[0, 0, 0, 0],
						[0, 0, 0, 0]])

		# tile classes are of the form "tile tile-{value} tile-{x}-{y} {tile-modifier}"
		tiles = get_elements_by_class("tile")
		tiles.map do |tile|
			
			# read position data from class labels
			class_split = tile.attribute("class").split(" ")
			value = class_split[1].split("-")[1].to_i
			position = [class_split[2].split("-")[2].to_i - 1, class_split[2].split("-")[3].to_i - 1]
			
			# load into 2-d array
			board_matrix[position[0]][position[1]] = value

		end

		board_matrix
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

RubyProf.start

# loop an artibrary number of times
# will eventually go until it loses (or wins)
150.times do
	# store board state
	tile_list = driver.get_elements_by_class "tile"
	
	# move
	driver.send_keys(find_optimal_move(driver.read_tiles))

	# only proceed once the DOM updates
	# prevents crashes from accessing unavailable elements
	i = 0
	while (tile_list == driver.get_elements_by_class("tile") && i < 3)
		i += 1
	end
	print i.to_s + " "
end

profile = RubyProf.stop
printer = RubyProf::FlatPrinter.new(profile)
printer.print(STDOUT)

#driver.send_keys(:arrow_left)
