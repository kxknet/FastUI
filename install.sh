#!/bin/bash
set -e

# ----------- Языки ----------------
declare -A en=(
    [lang]="English"
    [enter_key_id]="Enter your B2 KEY ID: "
    [enter_key_secret]="Enter your B2 KEY SECRET: "
    [enter_bucket]="Enter bucket name (must already exist): "
    [enter_local_repo]="Enter local repo path [/backups/restic-local]: "
    [choose_region]="Choose bucket region:"
    [region_eu]="EU (Frankfurt)"
    [region_us]="US (California)"
    [choose_shell]="Choose your shell for aliasing:"
    [shell_bash]=".bashrc"
    [shell_zsh]=".zshrc"
    [enter_password]="Enter backup password (input hidden): "
    [confirm_password]="Repeat password: "
    [passwords_nomatch]="Passwords do not match. Try again."
    [success]="All done!"
    [check_pwfile]="Check or create password file: /root/restic-password.txt"
    [source_shell]="Load aliases: source ~/"
    [example]="Examples:"
    [example1]="rloc snapshots    # local snapshots"
    [example2]="rs3 snapshots     # cloud snapshots"
    [example3]="rloc ls latest    # last local backup files"
    [example4]="rs3 ls latest     # last cloud backup files"
    [use_now]="You can use these aliases now!"
)

declare -A ru=(
    [lang]="Русский"
    [enter_key_id]="Введи B2 KEY ID: "
    [enter_key_secret]="Введи B2 KEY SECRET: "
    [enter_bucket]="Введи имя бакета (уже должен быть создан): "
    [enter_local_repo]="Введи путь к локальному репозиторию [/backups/restic-local]: "
    [choose_region]="Введи регион бакета:"
    [region_eu]="EU (Франкфурт)"
    [region_us]="US (Калифорния)"
    [choose_shell]="Выбери shell для алиасов:"
    [shell_bash]=".bashrc"
    [shell_zsh]=".zshrc"
    [enter_password]="Введи пароль для бэкапа (будет скрыт): "
    [confirm_password]="Повтори пароль: "
    [passwords_nomatch]="Пароли не совпали. Пробуй снова."
    [success]="Всё готово!"
    [check_pwfile]="Проверь или создай файл пароля: /root/restic-password.txt"
    [source_shell]="Загрузи алиасы: source ~/"
    [example]="Примеры:"
    [example1]="rloc snapshots    # локальные снапшоты"
    [example2]="rs3 snapshots     # облачные снапшоты"
    [example3]="rloc ls latest    # файлы последнего локального"
    [example4]="rs3 ls latest     # файлы последнего облачного"
    [use_now]="Можешь использовать алиасы прямо сейчас!"
)

declare -A pl=(
    [lang]="Polski"
    [enter_key_id]="Podaj swój B2 KEY ID: "
    [enter_key_secret]="Podaj swój B2 KEY SECRET: "
    [enter_bucket]="Podaj nazwę bucketa (musi już istnieć): "
    [enter_local_repo]="Podaj ścieżkę do repozytorium lokalnego [/backups/restic-local]: "
    [choose_region]="Wybierz region bucketa:"
    [region_eu]="EU (Frankfurt)"
    [region_us]="US (Kalifornia)"
    [choose_shell]="Wybierz swój shell do aliasów:"
    [shell_bash]=".bashrc"
    [shell_zsh]=".zshrc"
    [enter_password]="Podaj hasło do backupu (niewidoczne): "
    [confirm_password]="Powtórz hasło: "
    [passwords_nomatch]="Hasła się nie zgadzają. Spróbuj ponownie."
    [success]="Gotowe!"
    [check_pwfile]="Sprawdź lub stwórz plik hasła: /root/restic-password.txt"
    [source_shell]="Załaduj aliasy: source ~/"
    [example]="Przykłady:"
    [example1]="rloc snapshots    # lokalne snapshoty"
    [example2]="rs3 snapshots     # snapshoty w chmurze"
    [example3]="rloc ls latest    # pliki ostatniego lokalnego backupu"
    [example4]="rs3 ls latest     # pliki ostatniego backupu w chmurze"
    [use_now]="Możesz używać tych aliasów już teraz!"
)

langs=(en ru pl)
langvars=(en ru pl)
PS3="Select language / Выбери язык / Wybierz język [1-3]: "
echo
select LNG in "English" "Русский" "Polski"; do
    case $REPLY in
        1) declare -n msg=en; break ;;
        2) declare -n msg=ru; break ;;
        3) declare -n msg=pl; break ;;
        *) echo "1=English, 2=Русский, 3=Polski";;
    esac
done

echo
read -p "${msg[enter_key_id]}" B2_KEY_ID
read -p "${msg[enter_key_secret]}" B2_KEY
read -p "${msg[enter_bucket]}" B2_BUCKET
read -p "${msg[enter_local_repo]}" RESTIC_LOCAL_REPO
RESTIC_LOCAL_REPO=${RESTIC_LOCAL_REPO:-/backups/restic-local}

echo
echo "${msg[choose_region]}"
select REGION in "${msg[region_eu]}" "${msg[region_us]}"; do
    case $REPLY in
        1) ENDPOINT="s3.eu-central-003.backblazeb2.com"; break ;;
        2) ENDPOINT="s3.us-west-002.backblazeb2.com"; break ;;
        *) echo "1=${msg[region_eu]}, 2=${msg[region_us]}";;
    esac
done

echo
echo "${msg[choose_shell]}"
select SHELLRC in "${msg[shell_bash]}" "${msg[shell_zsh]}"; do
    case $REPLY in
        1) SHELL_RC="/root/.bashrc"; break ;;
        2) SHELL_RC="/root/.zshrc"; break ;;
        *) echo "1=.bashrc, 2=.zshrc";;
    esac
done

# Ввод пароля (hidden + проверка)
while true; do
    echo
    read -s -p "${msg[enter_password]}" RESTIC_PW1; echo
    read -s -p "${msg[confirm_password]}" RESTIC_PW2; echo
    [[ "$RESTIC_PW1" == "$RESTIC_PW2" && -n "$RESTIC_PW1" ]] && break
    echo "${msg[passwords_nomatch]}"
done

echo "$RESTIC_PW1" > /root/restic-password.txt
chmod 600 /root/restic-password.txt

cat > /root/.restic-env <<EOF
export RESTIC_PASSWORD_FILE="/root/restic-password.txt"
export AWS_ACCESS_KEY_ID="$B2_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$B2_KEY"
export RESTIC_LOCAL_REPO="$RESTIC_LOCAL_REPO"
export RESTIC_S3_REPO="s3:https://$ENDPOINT/$B2_BUCKET/restic-b2"
EOF

# Алиасы
if ! grep -q 'alias resticenv=' "$SHELL_RC" 2>/dev/null; then
    cat >> "$SHELL_RC" <<'EOFA'
# === Restic Aliases ===
alias resticenv='source /root/.restic-env'
alias rloc='resticenv && restic -r "$RESTIC_LOCAL_REPO"'
alias rs3='resticenv && restic -r "$RESTIC_S3_REPO"'
EOFA
fi

echo
echo "=== ${msg[success]} ==="
echo "${msg[check_pwfile]}"
echo "${msg[source_shell]}${SHELL_RC##*/}"
echo "${msg[example]}"
echo "  ${msg[example1]}"
echo "  ${msg[example2]}"
echo "  ${msg[example3]}"
echo "  ${msg[example4]}"
echo
echo "${msg[use_now]}"
