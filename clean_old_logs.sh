#!/bin/bash

set -o pipefail

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'
GREEN='\033[0;32m'

LOG_PATH=""
DAYS=""

print_help() {
    cat <<EOF
Использование: $0 [OPTIONS]

Опции:
  -p, --path PATH     Путь по которому нужно искать файлы для удаления
  -d, --days DAYS     Количество дней (файлы старше N дней)
  -h, --help          Помощь
Примеры:
  # Базовый синтаксис  $0 --path /var/log/myapp --days 30
EOF
    exit 0
}


log() {
    local level="$1"
    local msg="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    case "$level" in
        INFO)
            echo -e "${GREEN}[$timestamp] ${BLUE}[INFO]${NC} $msg"
            ;;
        ERROR)
            echo -e "${GREEN}[$timestamp] ${RED}[ERROR]${NC} $msg"
            ;;
        *)
            echo -e "${GREEN}[$timestamp]${NC} $msg"
            ;;
    esac
}

parse_args() {
    if [[ $# -eq 0 ]]; then
        print_help
        exit 0
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--path)
                LOG_PATH="$2"
                shift 2
                ;;
            -d|--days)
                DAYS="$2"
                shift 2
                ;;
            -h|--help)
                print_help
                ;;
            *)
                log ERROR "Неизвестный аргумент: $1"
                print_help
                ;;
        esac
    done
}

validate_vars() {
    if [[ -z "$LOG_PATH" || -z "$DAYS" ]]; then
        log ERROR "Необходимо указать --path и --days"
        exit 1
    fi

    if [[ "$DAYS" -le 0 ]]; then
        log ERROR "Количество дней должно быть положительным числом"
        exit 1
    fi

    if [[ ! -d "$LOG_PATH" ]]; then
        log ERROR "Директория '$LOG_PATH' не существует"
        exit 1
    fi
}

search_files() {
  readarray -t FILES < <(find "$LOG_PATH" -type f -name "*.log" -mtime +"${DAYS}")

  if [[ ${#FILES[@]} -eq 0 ]]; then
	  log INFO "Файлы старше $DAYS дней с расширением .log не найдены"                   exit 0
  fi

  log INFO "Найдено ${#FILES[@]} файл(ов) старше $DAYS дней:"
  printf '  %s\n' "${FILES[@]}"
}

confirm_deletion() {
    echo
    read -rp "Удалить эти файлы? (yes/no): " answer
    case "$answer" in
        yes|y)
            return 0
            ;;
        *)
            log INFO "Операция отменена..."
            exit 0
            ;;
    esac
}

delete_files() {
    log INFO "Удаление ${#FILES[@]} файл(ов)..."
    local deleted_count=0

    for file in "${FILES[@]}"; do
        if rm -f "$file"; then
            echo "  Удален: $file"
            ((deleted_count++))
        else
            log ERROR "Не удалось удалить: $file"
        fi
    done
    log INFO "Удаление завершено. Удалено файлов: $deleted_count"
}

main() {
    parse_args "$@"
    validate_vars
    search_files
    confirm_deletion
    delete_files
}

main "$@"