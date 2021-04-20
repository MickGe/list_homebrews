#!/bin/bash

OLDIFS=$IFS
IFS=$'\r\n'

Target="$HOME/brews.md"
MyHostname=$(hostname)

if test -f "$Target"; then
	rm "$Target"
	echo "File $Target is deleted"
	echo "It will be created with new values"
else
	echo "File $Target will be created"
fi

echo "# Homebrews $MyHostname" > "$Target"
echo "$IFS"'[TOC]' >> "$Target"

list_brews ()
{
	printf '> firt: check for brew list --formula...%s' "$IFS"
	#ListBrews="$(brew list --formula)"
	ListBrews="$(brew leaves)"
	printf '> second: check for brew list --cask...%s' "$IFS"
	ListCasks="$(brew list --cask)"
}

checkVar ()
{
	local Variable1
	local Variable2
	Variable1=$1
	Variable2=$2
	if [ "${Variable1+xxx}" = "xxx" ] && [ -z "$Variable1" ]
	then Variable1="$Variable2"
	fi
	echo "$Variable1"
}

getMeta ()
{
	local Formulae
	local FormulaType
	Formulae=$1
	FormulaType=$2
  FormulaName=$3
	echo "$IFS## ""$FormulaName" >> "$Target"
	printf '> now, find descriptions of %s' "$FormulaName"
	for Formula in $Formulae
	do 
		printf "."
		local Infos
		Infos=$(curl -X GET 'https://formulae.brew.sh/api/'"$FormulaType"'/'"$Formula"'.json' -H "Accept: application/json" 2>/dev/null)
		local Desc
		Desc=$(echo "$Infos" | sed -n 's|.*"desc":"\([^"]*\)".*|\1|p')
		Desc=$(checkVar "$Desc" '_No description_')
		local HomePage
		HomePage=$(echo "$Infos" | sed -n 's|.*"homepage":"\([^"]*\)".*|\1|p')
		HomePage=$(checkVar "$HomePage" '#')
		local Version
		VersionCask=$(echo "$Infos" | sed -n 's|.*"version":"\([^"]*\)".*|\1|p')
		VersionCask=$(checkVar "$VersionCask" '_unknown_')
		Version=$(echo "$Infos" | sed -n 's|.*"versions":{"stable":"\([^"]*\)".*|\1|p')
		Version=$(checkVar "$Version" "$VersionCask")
		{
			echo "$IFS### $Formula";
			echo "$IFS> $Desc  ";
			echo "$IFS""__Version:__ $Version  ";
			echo "$IFS""[Homepage]($HomePage)  ";
		} >> "$Target"
	done
		printf '%s' "$IFS"
}

getAllMeta ()
{
	printf 'Wait...%s' "$IFS"
	list_brews
	getMeta "${ListBrews[@]}" formula Formulae
	getMeta "${ListCasks[@]}" cask Casks
	echo 'Done!!!'
}

getAllMeta

IFS=$OLDIFS

open "$Target"

exit
