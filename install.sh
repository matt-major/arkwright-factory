#!/usr/bin/env bash
# Installs the Arkwright agents for Claude Code, Codex CLI, and GitHub Copilot CLI,
# either into the current project or globally.
# Usage: path/to/install.sh [-p|--project] [-g|--global] [-y|--yes] [--link] [claude|codex|copilot|all]
#   -p, --project  Install into the current project (its git root, or the current directory).
#   -g, --global   Install into your home directory, for every project.
#   -y, --yes      Don't prompt. Anything not given defaults to: all, project.
#   --link         Symlink the files instead of copying, so `git pull` updates them.
#   all            Install for every tool found on your PATH.
# Anything not given on the command line is asked for.
set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"

usage() {
  echo "usage: $0 [-p|--project] [-g|--global] [-y|--yes] [--link] [claude|codex|copilot|all]" >&2
  exit 1
}

choice=""
scope=""
yes=false
mode=copy
for arg in "$@"; do
  case "$arg" in
    -p|--project) scope=project ;;
    -g|--global) scope=global ;;
    -y|--yes) yes=true ;;
    --link) mode=link ;;
    claude|codex|copilot|all) choice="$arg" ;;
    *) usage ;;
  esac
done

if [[ -z $choice && $yes == true ]]; then
  choice=all
elif [[ -z $choice ]]; then
  [[ -t 0 ]] || usage
  echo "Which tool should Arkwright be installed for?"
  echo "  1) Claude Code"
  echo "  2) Codex CLI"
  echo "  3) GitHub Copilot CLI"
  echo "  4) All installed tools"
  read -r -p "Choose [4]: " reply
  case "${reply:-4}" in
    1) choice=claude ;;
    2) choice=codex ;;
    3) choice=copilot ;;
    4) choice=all ;;
    *) echo "Invalid choice: $reply" >&2; exit 1 ;;
  esac
fi

if [[ -z $scope && $yes == true ]]; then
  scope=project
elif [[ -z $scope ]]; then
  [[ -t 0 ]] || usage
  echo "Where should it be installed?"
  echo "  1) Project: into $PROJECT_ROOT, to commit and share with your team"
  echo "  2) Global:  into your home directory, for every project"
  read -r -p "Choose [1]: " reply
  case "${reply:-1}" in
    1) scope=project ;;
    2) scope=global ;;
    *) echo "Invalid choice: $reply" >&2; exit 1 ;;
  esac
fi

tools=()
if [[ $choice == all ]]; then
  for tool in claude codex copilot; do
    command -v "$tool" >/dev/null && tools+=("$tool")
  done
  if [[ ${#tools[@]} -eq 0 ]]; then
    echo "No supported tool found on your PATH: claude, codex, or copilot." >&2
    exit 1
  fi
else
  tools=("$choice")
fi

if [[ $scope == project ]]; then
  if [[ $PROJECT_ROOT == "$REPO_ROOT" ]]; then
    echo "Run this from the project you want to install into, or pass --global." >&2
    exit 1
  fi
  claude_dir="$PROJECT_ROOT/.claude/agents"
  codex_dir="$PROJECT_ROOT/.codex/agents"
  copilot_dir="$PROJECT_ROOT/.github/agents"
else
  claude_dir="$HOME/.claude/agents"
  codex_dir="$CODEX_HOME/agents"
  copilot_dir="$HOME/.copilot/agents"
fi

# install_files <dest-dir> <file>...
install_files() {
  local dest="$1"; shift
  mkdir -p "$dest"
  for file in "$@"; do
    # Remove first, so a copy never writes through a symlink from an earlier --link.
    rm -f "$dest/$(basename "$file")"
    if [[ $mode == link ]]; then
      ln -s "$file" "$dest/"
    else
      cp "$file" "$dest/"
    fi
    echo "  $dest/$(basename "$file")"
  done
}

for tool in "${tools[@]}"; do
  echo "$tool:"
  case "$tool" in
    claude)  install_files "$claude_dir" "$REPO_ROOT"/claude/agents/*.md ;;
    codex)   install_files "$codex_dir" "$REPO_ROOT"/codex/agents/*.toml
             # Codex reads profiles only from its home, so Arkwright's is always global.
             install_files "$CODEX_HOME" "$REPO_ROOT/codex/arkwright.config.toml" ;;
    copilot) install_files "$copilot_dir" "$REPO_ROOT"/copilot/agents/*.agent.md ;;
  esac
done

echo
echo "Start Arkwright with:"
for tool in "${tools[@]}"; do
  case "$tool" in
    claude)  echo "  claude --agent arkwright" ;;
    codex)   echo "  codex -p arkwright" ;;
    copilot) echo "  copilot --agent arkwright" ;;
  esac
done

if [[ $scope == project && " ${tools[*]} " == *" codex "* ]]; then
  echo
  echo "Note: Codex loads project agents only in a trusted project. Trust this"
  echo "project when Codex asks. Arkwright's Codex profile is always installed to"
  echo "$CODEX_HOME, because Codex reads profiles only from there."
fi

if [[ $scope == project && $mode == link ]]; then
  echo
  echo "Note: the symlinks point into $REPO_ROOT, so they won't work for teammates"
  echo "if you commit them. Install without --link to commit the agents."
fi
