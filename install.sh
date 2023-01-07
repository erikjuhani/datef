#!/usr/bin/env sh

DATEF_DOWNLOAD_URL="https://raw.githubusercontent.com/erikjuhani/datef/main/datef.sh"
DATEF_LATEST_COMMIT_URL="https://github.com/erikjuhani/datef/commit/HEAD.patch"
HOME_BIN_DIR="$HOME/bin"

# Check if runnning machine is a mac.
# If not end script.
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "Not on a darwin system, terminating"
  exit 1
fi

# Create bin directory under $HOME if it does not exist
if [ ! -d "$HOME_BIN_DIR" ]; then
  mkdir "$HOME_BIN_DIR"
fi

function download_datef() {
  curl -sSL "$DATEF_DOWNLOAD_URL" -o /tmp/datef
  if  [ $? != 0 ]; then
    echo "error downloading datef"
    exit 1
  fi 
  mv -f /tmp/datef "$HOME_BIN_DIR"
  chmod +x "$HOME_BIN_DIR/datef"
}

function annotate_version() {
  HEAD_SHA_THEIRS="${2:-$(awk 'NR==1{ print substr($2,0,7); }' $1)}"
  echo "# @annotated_version $HEAD_SHA_THEIRS" >> "$HOME_BIN_DIR/datef"
}

# Download datef if it does not exist
if [ ! -f "$HOME_BIN_DIR/datef" ]; then
  echo "Installing \`datef\` to $HOME_BIN_DIR"
  download_datef
  curl -sSL "$DATEF_LATEST_COMMIT_URL" -o /tmp/datef_head
  annotate_version /tmp/datef_head
else 
  curl -sSL "$DATEF_LATEST_COMMIT_URL" -o /tmp/datef_head

  HEAD_SHA_THEIRS=$(awk 'NR==1{ print substr($2,0,7); }' /tmp/datef_head)
  HEAD_SHA_OURS=$(tail -n 1 "$HOME_BIN_DIR/datef" | awk '{ print $3; }')

  if [ "$HEAD_SHA_THEIRS" != "$HEAD_SHA_OURS" ]; then
    echo "\`datef\` is outdated"
    echo "Updating \`datef\` $HEAD_SHA_OURS -> $HEAD_SHA_THEIRS"
    download_datef
    annotate_version /tmp/datef_head $HEAD_SHA_THEIRS
    echo "Updated \`datef\` to latest version $HEAD_SHA_THEIRS"
    exit 0
  fi

  echo "datef already found in $HOME_BIN_DIR folder and version "$HEAD_SHA_OURS" is up to date"
  exit 1
fi
