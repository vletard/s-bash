#!/bin/bash

# Encrypte l'ensemble des fichiers fournis en argument vers la sortie standard
# L'encryption est symétrique et utilise la clé privée rsa dans ~/.ssh/

pass=$(tr -d '\\n' < $HOME/.ssh/id_rsa)

echo "Attention, sortie standard utilisée pour binaire !" >&2
sleep 17
tar cvz "$@" | openssl aes-256-cbc -salt -pass "pass:$pass"
