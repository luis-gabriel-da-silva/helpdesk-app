# Rodar o Helpdesk com Docker

Este compose sobe a versão web do Flutter, a API Laravel e um banco MySQL para desenvolvimento local.

## Primeira inicialização

No PowerShell, na pasta raiz do projeto:

```powershell
Copy-Item .env.docker.example .env.docker
docker compose --env-file .env.docker build
docker compose --env-file .env.docker run --rm --no-deps api php artisan key:generate --show
```

Copie a chave `base64:...` impressa no terminal para `APP_KEY=` no arquivo `.env.docker`. Depois:

```powershell
docker compose --env-file .env.docker up -d
docker compose --env-file .env.docker exec api php artisan migrate --seed --force
```

Abra **http://localhost:8080**. O Nginx serve o Flutter Web e encaminha `/api` para o Laravel. Para administrar o banco pelo navegador, abra **http://localhost:8081** no phpMyAdmin e entre com o usuário `helpdesk` e a senha `helpdesk_local_password`.

## Comandos úteis

```powershell
docker compose --env-file .env.docker logs -f
docker compose --env-file .env.docker down
```

`down` preserva o banco e os anexos nos volumes. Para apagar também esses dados de teste, use `docker compose --env-file .env.docker down -v`.

Este compose é para rodar localmente. Antes de publicar na internet, troque as senhas de desenvolvimento, configure HTTPS e defina `APP_DEBUG=false`.
