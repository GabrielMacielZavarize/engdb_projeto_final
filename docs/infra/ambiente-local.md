# Ambiente Local — Base (MinIO + PostgreSQL)

Ambiente base do projeto, definido em [`docker-compose.yml`](https://github.com/GabrielMacielZavarize/engdb_projeto_final/blob/main/docker-compose.yml).
Sobe dois serviços: o **PostgreSQL** (banco de origem) e o **MinIO** (object storage que
hospeda o Data Lake na arquitetura medalhão). Um container efêmero cria o bucket inicial.

> Referente à issue **#20** (épico **#13 — INFRA**).

## Pré-requisitos
- Docker + Docker Compose v2 (`docker compose version`).
- ~2 GB de RAM livres para estes dois serviços.

## Como subir

```bash
# 1. Crie seu arquivo de variáveis a partir do exemplo
cp .env.example .env      # (Windows PowerShell: Copy-Item .env.example .env)

# 2. (Opcional) ajuste credenciais/portas no .env

# 3. Suba o ambiente
docker compose up -d

# 4. Acompanhe os logs (opcional)
docker compose logs -f
```

## Serviços e portas

| Serviço       | URL / Porta              | Credenciais            |
|---------------|--------------------------|------------------------|
| MinIO API     | `http://localhost:9000`  | ver `.env.example`     |
| MinIO Console | `http://localhost:9001`  | ver `.env.example`     |
| PostgreSQL    | `localhost:5434`         | ver `.env.example` (db `olist_source`) |

> ⚠️ As credenciais do `.env.example` são apenas para desenvolvimento local.
> O arquivo `.env` real está no `.gitignore` e não deve ser versionado.
>
> O Console do MinIO (`:9001`) sobe sem proteção de rede (só a autenticação do
> próprio MinIO). Em rede compartilhada, restrinja por firewall.

## Validação rápida

Os comandos abaixo funcionam igual em Windows, macOS e Linux (rodam **dentro**
dos containers, não dependem de `psql` instalado no host):

```bash
# MinIO: o bucket "datalake" deve ter sido criado automaticamente
docker compose logs createbuckets

# PostgreSQL: checar se está pronto (saída esperada: "accepting connections")
docker compose exec -T postgres pg_isready -U olist -d olist_source

# PostgreSQL: testar conexão executando uma query
docker compose exec -T postgres psql -U olist -d olist_source -c "SELECT version();"
```

> No PowerShell, use a flag `-T` (sem TTY), como nos exemplos acima.

Pelo Console do MinIO (`http://localhost:9001`) o bucket `datalake` deve aparecer na lista.

## Encerrar

```bash
docker compose down       # para os serviços, mantém os dados
docker compose down -v    # para os serviços e APAGA os volumes (dados)
```

## Persistência

Os dados ficam em volumes Docker nomeados (sobrevivem a `docker compose down`):

- `engdb_postgres_data` — dados do PostgreSQL
- `engdb_minio_data` — objetos do MinIO (Data Lake)
