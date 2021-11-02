
if [ -z "${REPO}" ] ||
	[ -z "${BRANCH}" ] ||
	[ -z "${BUILD}" ] ||
	[ -z "${NODE_VER}" ] ||
	[ -z "${PORT}" ]; then
	echo "Missing a parameter."
	exit 1
fi

sed \
	-e "s;%REPO%;${REPO};g" \
	-e "s;%BRANCH%;${BRANCH};g" \
	-e "s;%BUILD%;${BUILD};g" \
	-e "s;%NODE_VER%;${NODE_VER};g" \
	-e "s;%PORT%;${PORT};g" \
	./template.service

