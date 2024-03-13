# Web converter

Приложение «WebConverter» предназначено для преобразования запросов к базам данных с языка реляционной алгебры и реляционного исчисления на язык SQL с последующим их выполнением.

## Запуск

Для запуска необходимо в корневой папке проекта выполнить команды:

1. `docker-compose build`
2. `docker-compose up`

Frontend будет запущен по адресу `http://localhost:3000/`  
Backend будет запущен по адресу `http://localhost:8000/`

## Использованные технологии

- **Frontend:**
  - TypeScript
  - Next.js
  - React
  - React Query
  - React Hook Form
  - React Hotkeys Hook
  - shadcn/ui
  - Tailwind CSS
- **Backend:**
  - Python
  - FastAPI
  - Uvicorn
  - psycopg2

**База данных:** PostgreSQL
