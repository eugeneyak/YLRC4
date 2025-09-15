### LRC4

Коротко: Ruby-приложение (бот/сервис) с интеграцией Telegram и Gemini. Проект запускается через `main.rb`, использует ключи API из переменных окружения.

### Требования
- Docker 24+ (или совместимая версия)
- Доступные значения переменных окружения

### Переменные окружения
- `GEMINI_API_KEY` — ключ доступа к Gemini API
- `TG_BOT_API_KEY` — ключ Telegram Bot API

Можно передавать переменные через `-e` или с помощью файла окружения.

Пример `.env` (создайте в корне проекта):
```env
GEMINI_API_KEY=your_gemini_key
TG_BOT_API_KEY=your_bot_key
```

### Сборка Docker-образа
```bash
docker build -t lrc4:latest .
```

### Запуск контейнера
- Обычный запуск с переменными окружения:
```bash
docker run --rm -it \
  -e GEMINI_API_KEY=your_gemini_key \
  -e TG_BOT_API_KEY=your_bot_key \
  lrc4:latest
```

- Запуск с файлом `.env`:
```bash
docker run --rm -it --env-file .env lrc4:latest
```

- Переопределение команды (например, запустить `worker.rb`):
```bash
docker run --rm -it --env-file .env lrc4:latest ruby worker.rb
```

### Локальный запуск (без Docker)
```bash
bundle install
GEMINI_API_KEY=your_gemini_key \
TG_BOT_API_KEY=your_bot_key \
ruby main.rb
```

### Структура
- `main.rb` — точка входа по умолчанию
- `workers/` — фоновые воркеры/сервисы
- `telegram/` — обёртки для Telegram API и бота

### Примечания
- В `Dockerfile` переменные окружения объявлены как пустые — заполните их при запуске.
- Если требуется другой стартовый файл — переопределите команду в `docker run`.
