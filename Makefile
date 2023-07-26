pxe:
	packer build packer.json
	rsync -rv --delete live/binary/live/ files/
	chown --reference=. files/ live/
