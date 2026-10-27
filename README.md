# UTS Manajemen Basis Data - Ghevyra Nur Fadilah

PostgreSQL 15 dan pgAdmin4 dengan Docker Compose.

## Cara menjalankan
1. Salin `.env.example` menjadi `.env`, lalu isi nilainya.
2. Jalankan `docker compose up -d`
3. Jalankan script SQL berurutan:
   - `docker exec -it postgres_ghevyra psql -U postgres -d postgres -f /sql/01_schema.sql`
   - `docker exec -it postgres_ghevyra psql -U postgres -d postgres -f /sql/02_users.sql`

## Port
- PostgreSQL: 22011
- pgAdmin4: 44011