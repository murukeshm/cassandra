#! /bin/bash
git commit --allow-empty -m "Update docs ($(date))"
commit_changes () {
	git checkout gh-pages
	git add trunk [0-9].*
	git commit -a --amend --no-edit --allow-empty
	if git diff --quiet HEAD 'HEAD^'
	then
		git reset 'HEAD^'
	fi
}
trap commit_changes EXIT

gen_docs () (
	set -e
	git checkout "$1"
	make -C doc html
	git checkout gh-pages
	v="${1#*-}"
	rm -rf "$v"
	mv doc/build/html "$v"
	rm -r doc
	git add "$v"
	git commit -a --amend --no-edit
)

# Get all tags containing the commit that added `make html`
git tag -l 'cassandra-*' --sort=v:refname --contains cad277be41ad4d5488cb96c5ef3f2fcb1cc8d3d9 |
	while read version
	do
		gen_docs "$version"
	done
gen_docs trunk

versions=(trunk [0-9].*)
{
	printf '%s\n' '<select onChange="window.location.pathname=window.location.pathname.replace(/[0-9.]+|trunk/,this.value)">'
	for i in  "${versions[@]}"
	do
		printf '    <option value="%s">%s</option>\n' "$i" "$i"
	done | sort -rV
	printf '%s\n' '</select>'
}> versions.html

grep Copyright "${versions[@]}" --include='*.html' -Rl | xargs sed -i '/Copyright/r versions.html'
for i in "${versions[@]}"
do
	(
		cd "$i"
		grep Copyright . --include='*.html' -Rl | xargs sed -i "/option.*$i/s/option/& selected='selected'/"
	)
done
rm -r doc versions.html
git add "${versions[@]}"
