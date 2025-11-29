#!/bin/bash
# Inspired by https://github.com/Nevcairiel/Bartender4/blob/master/locale/wowace-locale-import.sh

cf_token=

# Load secrets
if [ -f ".env" ]; then
	. ".env"
fi

[ -z "$cf_token" ] && cf_token=$CF_API_KEY

declare -A locale_files=(
  ["BlizzMove"]="_BlizzMove_locales.lua"
)
declare -A namespace_root=(
  ["BlizzMove"]="./"
)

tempfile=$( mktemp )
trap 'rm -f $tempfile' EXIT

do_import() {
  namespace="$1"
  file="$2"
  : > "$tempfile"

  echo -n "Importing $namespace..."
  result=$( curl -sS -0 -X POST -w "%{http_code}" -o "$tempfile" \
    -H "X-Api-Token: $CF_API_KEY" \
    -F "metadata={ language: \"enUS\", namespace: \"$namespace\", \"missing-phrase-handling\": \"DeletePhrase\" }" \
    -F "localizations=<$file" \
    "https://legacy.curseforge.com/api/projects/17809/localization/import"
  ) || exit 1
  case $result in
    200) echo "done." ;;
    *)
      echo "error! ($result)"
      [ -s "$tempfile" ] && grep -q "errorMessage" "$tempfile" | jq --raw-output '.errorMessage' "$tempfile"
      exit 1
      ;;
  esac
}

for namespace in "${!locale_files[@]}"; do
echo
  echo "Finding strings for $namespace..."
  lua .github/scripts/find-locale-strings.lua "${locale_files[$namespace]}" ${namespace_root[$namespace]}
  do_import "$namespace" "${locale_files[$namespace]}"
done

exit 0