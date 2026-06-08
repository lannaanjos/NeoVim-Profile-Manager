#!/usr/bin/env bash

# /\/\/\ CONFIGURAÇÃO
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$HOME/.config"

# profiles
declare -A PROFILES=(
	[Default]="nvim-default"
	[Misc]="nvim-misc"
)

# criando symlinks
for profile in "${!PROFILES[@]}"; do
	src="$REPO_ROOT/profiles/$profile"
	dest="$CONFIG_DIR/${PROFILES[$profile]}"

	if [ ! -d "$src" ]; then
		echo "Diretório de perfil não encontrado: $src"
		continue
	fi

	if [ -L "$dest" ]; then
		echo "Já existe: $dest -> $(readlink "$dest")"
	elif [ -e "$dest" ]; then
		echo "O diretório $dest existe mas não é um symlink (skipando)..."
	else
		ln -s "$src" "$dest"
		echo "Criado: $dest -> $src"
	fi
done
