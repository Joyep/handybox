

.PHONY:swift
swift:.checksum2

.checksum2: .build Sources/*/*.swift *.swift
	swift build -c release
	cp .build/*/release/checksum .checksum2

.build:
	swift package resolve


.PHONY:c
c:.checksum

.checksum: gtp_checksum.c
	gcc -o .checksum gtp_checksum.c


.PHONY:clean
clean:
	rm .checksum *.o -rf
	rm .checksum2 -rf
	swift package clean
