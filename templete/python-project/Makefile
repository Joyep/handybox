default:dist

dist:
	poetry install
	mkdir dist

run:dist
	poetry run python hwcfg.py ${device} ${opt}

.PHONY: clean
clean:
	rm -rf dist
