current_dir = $(shell pwd)

run:
	processing-java --force --sketch=$(current_dir) --output=$(current_dir)/out --run
