#!/bin/bash
set -e

# === Языковые шаблоны ===
declare -A en=(
    [title]="FastUI for Restic backup software by @kxkwork"
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
    [source_shell]="Loading aliases ..."
    [examples]="Examples:"
    [ex_backup]="rbackup            # backup locally and to cloud"
    [ex_forget]="rforget            # remove old backups (local+cloud)"
    [ex_restore_local]="rrestore-local     # restore all locally to /tmp/restore"
    [ex_restore_s3]="rrestore-s3        # restore all from cloud to /tmp/restore"
    [ex_snapshots_local]="rloc snapshots     # show local snapshots"
    [ex_snapshots_s3]="rs3 snapshots      # show cloud snapshots"
    [enjoy]="Enjoy FastUI! Powered by restic & @kxkwork"
)

declare -A ru=(
    [title]="FastUI для Restic — резервные копии от @kxkwork"
    [lang]="Русский"
    [enter_key_id]="Введи B2 KEY ID: "
    [enter_key_secret]="Введи B2 KEY SECRET: "
    [enter_bucket]="Введи имя бакета (он уже должен быть создан): "
    [enter_local_repo]="Введи путь к локальному репо [/backups/restic-local]: "
    [choose_region]="Выбери регион бакета:"
    [region_eu]="EU (Франкфурт)"
    [region_us]="US (Калифорния)"
    [choose_shell]="Выбери shell для алиасов:"
    [shell_bash]=".bashrc"
    [shell_zsh]=".zshrc"
    [enter_password]="Введи пароль для бэкапа (будет скрыт): "
    [confirm_password]="Повтори пароль: "
    [passwords_nomatch]="Пароли не совпадают. Попробуй снова."
    [success]="Всё готово!"
    [check_pwfile]="Проверь или создай файл пароля: /root/restic-password.txt"
    [source_shell]="Загружаем алиасы ..."
    [examples]="Примеры:"
    [ex_backup]="rbackup            # бэкап локально и в облако"
    [ex_forget]="rforget            # удаление старых бэкапов (локально и облако)"
    [ex_restore_local]="rrestore-local     # восстановить всё локально в /tmp/restore"
    [ex_restore_s3]="rrestore-s3        # восстановить всё из облака в /tmp/restore"
    [ex_snapshots_local]="rloc snapshots     # локальные снапшоты"
    [ex_snapshots_s3]="rs3 snapshots      # снапшоты в облаке"
    [enjoy]="Пользуйся FastUI! Всё работает — @kxkwork"
)

declare -A pl=(
    [title]="FastUI dla Restic backup software by @kxkwork"
    [lang]="Polski"
    [enter_key_id]="Podaj swój B2 KEY ID: "
    [enter_key_secret]="Podaj swój B2 KEY SECRET: "
    [enter_bucket]="Podaj nazwę bucketa (musi już istnieć): "
    [enter_local_repo]="Podaj ścieżkę do repozytorium lokalnego [/backups/restic-local]: "
    [choose_region]="Wybierz region bucketa:"
    [region_eu]="EU (Frankfurt)"
    [region_us]="US (Kalifornia)"
    [choose_shell]="Wybierz shell do aliasów:"
    [shell_bash]=".bashrc"
    [shell_zsh]=".zshrc"
    [enter_password]="Podaj hasło do backupu (niewidoczne): "
    [confirm_password]="Powtórz hasło: "
    [passwords_nomatch]="Hasła się nie zgadzają. Spróbuj ponownie."
    [success]="Gotowe!"
    [check_pwfile]="Sprawdź lub stwórz plik hasła: /root/restic-password.txt"
    [source_shell]="Ładuję aliasy ..."
    [examples]="Przykłady:"
    [ex_backup]="rbackup            # backup lokalnie i do chmury"
    [ex_forget]="rforget            # usuwanie starych backupów (lokalnie i w chmurze)"
    [ex_restore_local]="rrestore-local     # przywróć wszystko lokalnie do /tmp/restore"
    [ex_restore_s3]="rrestore-s3        # przywróć wszystko z chmury do /tmp/restore"
    [ex_snapshots_local]="rloc snapshots     # lokalne snapshoty"
    [ex_snapshots_s3]="rs3 snapshots      # snapshoty w chmurze"
    [enjoy]="Korzystaj z FastUI! Działa z restic & @kxkwork"
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

echo -e "\n\033[1;32m${msg[title]}\033[0m\n"

CONFIG="/root/.restic-env"
PWFILE="/root/restic-password.txt"
[ -f "$CONFIG" ] && source "$CONFIG"

# Функция автозаполнения и запроса
function get_val() {
    local varname="$1"
    local prompt="$2"
    local def="$3"
    local var
    eval "var=\"\$$varname\""
    if [[ -z "$var" ]]; then
        if [[ "$prompt" =~ "password" ]]; then
            while true; do
                read -s -p "$prompt" v1; echo
                read -s -p "${msg[confirm_password]}" v2; echo
                [[ "$v1" == "$v2" && -n "$v1" ]] && break
                echo "${msg[passwords_nomatch]}"
            done
            eval "$varname=\"\$v1\""
        else
            read -p "$prompt" v
            v="${v:-$def}"
            eval "$varname=\"\$v\""
        fi
    fi
    eval "echo \"\$$varname\""
}

B2_KEY_ID=$(get_val "B2_KEY_ID" "${msg[enter_key_id]}" "")
B2_KEY=$(get_val "B2_KEY" "${msg[enter_key_secret]}" "")
B2_BUCKET=$(get_val "B2_BUCKET" "${msg[enter_bucket]}" "")
RESTIC_LOCAL_REPO=$(get_val "RESTIC_LOCAL_REPO" "${msg[enter_local_repo]}" "/backups/restic-local")
REGION=${REGION:-}
if [[ -z "$REGION" ]]; then
    echo "${msg[choose_region]}"
    select r in "${msg[region_eu]}" "${msg[region_us]}"; do
        case $REPLY in
            1) REGION="s3.eu-central-003.backblazeb2.com"; break ;;
            2) REGION="s3.us-west-002.backblazeb2.com"; break ;;
        esac
    done
fi
SHELL_RC=${SHELL_RC:-}
if [[ -z "$SHELL_RC" ]]; then
    echo "${msg[choose_shell]}"
    select s in "${msg[shell_bash]}" "${msg[shell_zsh]}"; do
        case $REPLY in
            1) SHELL_RC="/root/.bashrc"; break ;;
            2) SHELL_RC="/root/.zshrc"; break ;;
        esac
    done
fi
RESTIC_PW=$(get_val "RESTIC_PW" "${msg[enter_password]}" "")

echo "$RESTIC_PW" > "$PWFILE"
chmod 600 "$PWFILE"

cat > "$CONFIG" <<EOF
export RESTIC_PASSWORD_FILE="$PWFILE"
export AWS_ACCESS_KEY_ID="$B2_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$B2_KEY"
export RESTIC_LOCAL_REPO="$RESTIC_LOCAL_REPO"
export RESTIC_S3_REPO="s3:https://$REGION/$B2_BUCKET/restic-b2"
EOF

# Алиасы — не дублируем
if ! grep -q 'alias resticenv=' "$SHELL_RC" 2>/dev/null; then
cat >> "$SHELL_RC" <<'EOFA'
# === FastUI for Restic Aliases ===
alias resticenv='source /root/.restic-env'
alias rloc='resticenv && restic -r "$RESTIC_LOCAL_REPO"'
alias rs3='resticenv && restic -r "$RESTIC_S3_REPO"'
alias rbackup='rloc backup --exclude-file=/root/exclude.txt --files-from=/root/backup_list.txt && rs3 backup --exclude-file=/root/exclude.txt --files-from=/root/backup_list.txt'
alias rforget='rloc forget --keep-daily 30 --keep-last 60 --prune && rs3 forget --keep-daily 30 --keep-last 60 --prune'
alias rrestore-local='rloc restore latest --target /tmp/restore'
alias rrestore-s3='rs3 restore latest --target /tmp/restore'
EOFA
fi

echo -e "\n\033[1;36m${msg[source_shell]}\033[0m"
source "$SHELL_RC"

echo
echo -e "\033[1;32m${msg[success]}\033[0m"
echo "${msg[check_pwfile]}"
echo -e "\n${msg[examples]}"
echo "  ${msg[ex_backup]}"
echo "  ${msg[ex_forget]}"
echo "  ${msg[ex_restore_local]}"
echo "  ${msg[ex_restore_s3]}"
echo "  ${msg[ex_snapshots_local]}"
echo "  ${msg[ex_snapshots_s3]}"
echo
echo -e "\033[1;32m${msg[enjoy]}\033[0m"
