#! /bin/bash
git tag -l |
	grep -xP 'cassandra-\d\.\d+(.\d+)?' |
	sort -rV |
	while read version
	do
		git checkout "$version"
		(
			set -e
			cd doc
			make SPHINXBUILD=sphinx-build2 html
			mv build/html ../${version#*-}
		)
	done

{
	printf '%s\n' '<select onChange="window.location.pathname=window.location.pathname.replace(/[0-9.]+/,this.value)">'
	for i in [0-9].*
	do
		printf '    <option value="%s">%s</option>\n' "$i" "$i"
	done | sort -V
	printf '%s\n' '</select>'
}> versions.html

grep Copyright [0-9].* --include='*.html' -Rl | xargs sed -i '/Copyright/r versions.html'
for i in [0-9].*
do
	(
		cd "$i"
		grep Copyright . --include='*.html' -Rl | xargs sed -i "/option.*$i/s/option/& selected='selected'/"
	)
done
