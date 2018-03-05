VERSION_FILE=${1-DockerVersion.txt}
# =================================================
# BELOW THIS LINE STARTS UNCHANGABLE PART OF SCRIPT
# =================================================

# =====================================
# optional param $1 - use custom tag
# if undefined, parse from DockerVersion.txt

#=========================================================

function purgeImageByName() {
  if [ -z "$1" ]
  then
    echo "Pass image name as param 1"
    return 1
  fi

  IMAGE_ID=$(docker images -q $1)

  if [ -z "$IMAGE_ID" ]
  then
    echo "No Image named $1 found"
    return 0
  fi

  echo docker images | grep ${IMAGE_ID} | awk '{print $1 ":" $2}' | xargs docker rmi
  docker images | grep ${IMAGE_ID} | awk '{print $1 ":" $2}' | xargs docker rmi
}

# version can be tagged v0.0.1 rather than 0.0.1
function resolveVersionTag() {
	echo "$(baseTag)$1"
}

#=======================================
# if you want versioning v0.0.1, add here
function baseTag() {
	echo ""
}

# ===============================
# returns current project version
function resolveLatest() {
	awk -F= '/^latest=/{print $2}' ${VERSION_FILE}
}

# =====================================
# updates latest to new revision
function updateLatest() {
	if [ -n "$1" ] ; then
		sed -i.bak -e "s/^latest=.*/latest=$1/g" ${VERSION_FILE}
		rm -f ${VERSION_FILE}.bak
	else
		echo "[!] Error: missing new revision parameter " >&2
		return 1
	fi
}


# =====================================
# Queries git for existance of tag
function tagExists() {
	tag=${1:-$(resolveLatest)}
	test -n "$tag" && test -n "$(git tag | grep "^$tag\$")"
}

function differsFromLatest() {
        tag=$(resolveLatest)
        headtag=$(git tag -l --points-at HEAD)
        if tagExists $tag; then
          if [ "$tag" == "$headtag" ]; then
            #[I] tag $tag exists, and matches tag for the commit
            return 1
          else
            #[I] Codebase differs: $tag does not match commit.
            return 0
          fi
        else
          # [I] No tag found for $tag
          return 0
        fi
}

function getVersion() {
	result=$(resolveLatest)

	if differsFromLatest; then
		result="$result-$(git rev-parse --short HEAD)"
	fi

	if _hasGitChanges ; then
		result="$result-raw"
	fi
	echo $result
}


# ================================================================
# True if repo was modified (-s . - to check relatively to folder)
function _hasGitChanges() {
	test -n "$(git status -s)"
}


# ===================================================
# gitflow release helpers https://github.com/Voronenko/gitflow-release
# ===================================================

# =====================================
# 0.0.1 => 0.0.2
function _bump_patch_version_dry(){
  if [ -z "$1" ]
  then
    echo "Pass version as param 1"
    return 1
  fi

  declare -a part=( ${1//\./ } )
  declare    new
  declare -i carry=1

  for (( CNTR=${#part[@]}-1; CNTR>=0; CNTR-=1 )); do
    len=${#part[CNTR]}
    new=$((part[CNTR]+carry))
    [ ${#new} -gt $len ] && carry=1 || carry=0
    [ $CNTR -gt 0 ] && part[CNTR]=${new: -len} || part[CNTR]=${new}
  done
  new="${part[*]}"
  echo -e "${new// /.}"
}

# =====================================
# 0.0.1 => 0.1.0

function _bump_minor_version_dry(){
  if [ -z "$1" ]
  then
    echo "Pass version as param 1"
    return 1
  fi

  declare -a part=( ${1//\./ } )
  declare    new
  declare -i carry=1

  for (( CNTR=${#part[@]}-2; CNTR>=0; CNTR-=1 )); do
    len=${#part[CNTR]}
    new=$((part[CNTR]+carry))
    [ ${#new} -gt $len ] && carry=1 || carry=0
    [ $CNTR -gt 0 ] && part[CNTR]=${new: -len} || part[CNTR]=${new}
  done
  part[2]=0 #zerorify minor version
  new="${part[*]}"
  echo -e "${new// /.}"
}
