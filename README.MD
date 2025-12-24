# clean-old-logs

---

**clean-old-logs** — скрипт для удаления файлов с расширением *.log старше N дней по указанному пути

---

## Установка
```bash
git clone https://github.com/<username>/clean-old-logs
cd clean-old-logs
chmod +x clean_old_logs.sh
```

## Использование `clean_old_logs.sh`

Базовый синтаксис
```bash
./clean_old_logs.sh --path /var/log --days 30
```

Просмотр дополнительной информации
```bash
./clean_old_logs.sh --help
```