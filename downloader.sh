#!/usr/bin/env bash

: "${HEIGHT:=2160}"
: "${WIDTH:=3840}"

gallery_url="https://vlad.studio/wallpapers/?filter=all&page=%page%"
image_url="https://vlad.studio/wallpaper-image/?filename=%filename%&screen_width=${WIDTH}&screen_height=${HEIGHT}&screen_ratio=1"
pages="$(curl --silent 'https://vlad.studio/wallpapers/?filter=all&page=1' | pup h4 | tr -d '\n' | sed 's/.*Page 1 of //' | sed 's/<.*//')"

out_dir="vlad.studio_$(date -I)_${WIDTH}x${HEIGHT}"
mkdir -p "${out_dir}"
tmpfile="$(mktemp)"

for i in $(seq "${pages}")
do
	page=${i}
	url="${gallery_url/'%page%'/$page}"
	printf "Downloading images from page %2d/%2d...\n" "${i}" "${pages}"
	curl --fail --silent "${url}" > "${tmpfile}" || \
		{ printf 'An error occured.\n'; break; }
	pup 'img.wall-thumb' < "${tmpfile}" | sed 's/.*joy\///' | sed 's/\/preview.*//' | \
		xargs -I 'repl' -P 4 curl --continue-at - --silent --output "${out_dir}/repl.jpg" "${image_url/'%filename%'/'repl'}"
done

rm "${tmpfile}"
printf "Done.\n"
