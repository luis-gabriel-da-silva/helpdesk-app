# HELP! desk

Aplicação web e mobile para abertura, acompanhamento e atendimento de chamados de suporte. O projeto reúne um cliente Flutter, uma API REST em Laravel e um banco MySQL. Os técnicos e os clientes usam a mesma aplicação com permissões diferentes.

**Aluno:** Luis Gabriel da Silva  
**Projeto integrado:** HELP! desk — gerenciamento de chamados de suporte

## Visão geral

O objetivo do HELP! desk é organizar solicitações de suporte em um único lugar. Um cliente registra o problema, informa categoria e prioridade e pode anexar uma imagem ou arquivo de log. Depois acompanha o status e conversa com a equipe responsável pelo chamado.

Os técnicos visualizam a fila de chamados, abrem os detalhes, respondem às mensagens e atualizam o status. A API aplica as regras de acesso, valida os dados e persiste chamados, mensagens, usuários e notificações.

### Funcionalidades

- Login com token de acesso do Laravel Sanctum.
- Cadastro pela API; novas contas recebem o perfil de cliente.
- Abertura, listagem, consulta, edição e exclusão de chamados.
- Categorias: hardware, acesso/login, banco de dados/infraestrutura e financeiro.
- Prioridades: baixa, média e alta.
- Status: pendente, em andamento e concluído.
- Mensagens e anexos no histórico do chamado.
- Atualização do perfil, incluindo foto.
- Notificações internas para novos chamados e mensagens.
- Painel com experiências diferentes para clientes e técnicos.
- Documentação interativa da API pelo Laravel Scramble.

## Como funciona

1. O usuário entra com e-mail e senha. A API valida as credenciais e devolve um token Sanctum.
2. O Flutter armazena o token em armazenamento seguro e o envia como `Authorization: Bearer <token>` nas rotas protegidas.
3. O cliente abre um chamado. O registro guarda título, categoria, prioridade e o identificador do cliente. A descrição inicial é salva como a primeira mensagem do chamado.
4. A API gera notificações internas para os técnicos. Mensagens posteriores notificam o cliente ou a equipe relacionada ao chamado.
5. Um técnico pode responder e alterar o status. A API registra qual técnico fez a atualização.

### Regras de acesso

| Ação | Cliente | Técnico |
|---|---|---|
| Listar chamados | Apenas os próprios | Todos os chamados |
| Consultar chamado | Apenas se abriu o chamado | Todos os chamados |
| Criar chamado | Sim | A API permite, embora o fluxo principal seja de clientes |
| Editar dados do chamado | Apenas o próprio e enquanto não estiver concluído | Não pela operação de edição atual |
| Excluir chamado | Apenas o próprio | Pode excluir qualquer chamado |
| Enviar mensagem | Apenas nos próprios chamados | Pode responder aos chamados |
| Alterar status | Não | Sim |

As permissões são validadas no backend; esconder ou mostrar ações na interface não substitui essas verificações.

## Tecnologias

### Cliente

- Flutter e Dart.
- `go_router` para navegação por rotas nomeadas.
- `http` para chamadas à API.
- `flutter_secure_storage` para guardar o token e os dados da sessão.
- `file_picker` para selecionar anexos.

### API e dados

- PHP 8.3 e Laravel 12.
- Laravel Sanctum para autenticação por token.
- MySQL 8.4.
- Laravel Scramble para gerar documentação OpenAPI interativa.
- Migrations, Eloquent Models, Form Requests, API Resources, Services e Repositories.

### Execução local

- Docker Compose.
- Nginx para servir o Flutter Web e encaminhar chamadas para a API.
- phpMyAdmin para consultar o banco pelo navegador.

## Arquitetura

```text
helpdesk_app/
└── lib/
    ├── core/          # rotas, tema, textos, validações e configurações comuns
    ├── models/        # modelos usados pelo cliente Flutter
    ├── services/      # autenticação e comunicação HTTP com a API
    ├── screens/       # login, dashboard, perfil, formulário e detalhes
    └── widgets/       # componentes reutilizáveis

helpdesk-api/
├── app/
│   ├── Http/          # controllers, requests e resources
│   ├── Models/        # entidades Eloquent
│   ├── Repositories/  # contratos e acesso a usuários, chamados, notificações e anexos
│   └── Services/      # regras de negócio e autorização
├── database/
│   ├── factories/     # geração de dados de teste
│   ├── migrations/    # estrutura do banco
│   └── seeders/       # contas de demonstração
├── routes/api.php     # rotas REST
└── config/scramble.php
```

Nas operações da API, o controller recebe a requisição, um Form Request valida a entrada quando aplicável, um Service executa as regras de negócio e autorização, e um Repository acessa o banco. Os API Resources formatam os dados enviados ao Flutter. Essa separação é usada em chamados, autenticação/perfil, notificações e autorização de anexos.

No Flutter, as telas chamam classes da pasta `services/`; elas fazem as requisições e convertem respostas em modelos. O `core/routes/` define as rotas nomeadas, e o tema e os componentes compartilhados ficam fora das telas.

### Telas do aplicativo

| Caminho no app | Tela | Função |
|---|---|---|
| `helpdesk_app/lib/screens/login/login_screen.dart` | Login | Autentica e inicia a sessão. |
| `helpdesk_app/lib/screens/home/home_screen.dart` | Início / dashboard | Lista chamados e notificações conforme o perfil. |
| `helpdesk_app/lib/screens/ticket_form/ticket_form_screen.dart` | Abrir/editar chamado | Cria ou edita chamados, incluindo prioridade, categoria e anexo. |
| `helpdesk_app/lib/screens/ticket_detail/ticket_detail_screen.dart` | Detalhes do chamado | Exibe dados, mensagens, anexos e ações permitidas. |
| `helpdesk_app/lib/screens/profile/profile_screen.dart` | Perfil | Edita dados pessoais, foto e preferências disponíveis. |

As rotas nomeadas correspondentes ficam em `helpdesk_app/lib/core/routes/app_routes.dart` e `app_router.dart`: `/login`, `/home`, `/tickets/new`, `/tickets/:id`, `/tickets/:id/edit` e `/profile/:id`.

### Capturas de tela do aplicativo

![Página de login](docs/screenshots/login.png)
![Dashboard do cliente](docs/screenshots/dashboard-cliente.png)
![Dashboard do técnico](docs/screenshots/dashboard-tecnico.png)
![Novo chamado](docs/screenshots/novo-chamado.png)
![Detalhes do chamado](docs/screenshots/detalhes-chamado.png)
![Página do perfil](docs/screenshots/perfil.png)


### Principais entidades

| Entidade | Função |
|---|---|
| `User` | Contas de clientes e técnicos, perfil e foto |
| `Ticket` | Título, categoria, prioridade, status, cliente e técnico responsável |
| `TicketMessage` | Descrição inicial, respostas e referência a anexos |
| `UserNotification` | Notificações internas e estado de leitura |

As tabelas de `users`, `tickets`, `ticket_messages`, `user_notifications` e tokens Sanctum são criadas pelas migrations.

## API REST

As rotas usam o prefixo `/api`. As rotas protegidas exigem um token Sanctum válido.

| Método | Rota | Acesso | Descrição |
|---|---|---|---|
| `POST` | `/api/register` | Público | Cria um cliente; exige `name`, `email`, `password` e `password_confirmation`. |
| `POST` | `/api/login` | Público | Valida e-mail e senha e retorna `access_token` e dados do usuário. |
| `GET` | `/api/attachments/{path}` | Sanctum; dono do chamado ou técnico | Entrega um anexo ou avatar após validar a autorização. |
| `POST` | `/api/logout` | Sanctum | Revoga o token usado na requisição. |
| `GET` | `/api/users/{id}` | Sanctum; próprio usuário ou técnico | Retorna os dados do usuário indicado. |
| `POST`, `PUT` | `/api/profile` | Sanctum | Atualiza o perfil do usuário autenticado; aceita foto. |
| `GET` | `/api/tickets` | Sanctum | Lista chamados conforme o perfil do usuário. |
| `POST` | `/api/tickets` | Sanctum | Cria um chamado e sua mensagem inicial; aceita anexo. |
| `GET` | `/api/tickets/{id}` | Sanctum | Retorna os detalhes e o histórico se o usuário tiver acesso. |
| `PUT` | `/api/tickets/{id}` | Sanctum | Edita os dados permitidos do chamado. |
| `DELETE` | `/api/tickets/{id}` | Sanctum | Exclui o chamado conforme as regras de acesso. |
| `POST` | `/api/tickets/{id}/messages` | Sanctum | Adiciona mensagem e, opcionalmente, anexo. |
| `PATCH` | `/api/tickets/{id}/status` | Sanctum; técnico | Atualiza o status e registra o técnico responsável. |
| `GET` | `/api/notifications` | Sanctum | Lista notificações do usuário autenticado. |
| `PATCH` | `/api/notifications/{id}/read` | Sanctum | Marca como lida uma notificação do usuário autenticado. |

As categorias aceitas pela API são `hardware`, `login`, `db_infra` e `financeiro`; prioridades são `baixa`, `media` e `alta`; status são `pendente`, `em_andamento` e `concluido`.

Chamados aceitam anexos de imagem ou log de até 15 MB. Fotos de perfil aceitam JPG, JPEG, PNG ou WebP de até 5 MB. Anexos de chamados só são servidos ao cliente que abriu o chamado e aos técnicos. Fotos são servidas ao próprio usuário, aos técnicos e aos clientes que compartilham um chamado com aquele usuário. Essas consultas exigem token Sanctum.

## Documentação interativa

Com a aplicação em execução no modo local, abra:

- **Interface Scramble:** <http://localhost:8080/docs/api>
- **Especificação OpenAPI:** <http://localhost:8080/docs/api.json>

Para experimentar as rotas protegidas, execute `POST /api/login` na documentação, copie o valor de `access_token` e informe-o como Bearer token na autorização da página. As rotas públicas não precisam desse token.

## Executar com Docker

Os comandos abaixo devem ser executados na raiz do repositório, no PowerShell. Na primeira execução, crie o arquivo de ambiente:

```powershell
Copy-Item .env.docker.example .env.docker
docker compose --env-file .env.docker build
docker compose --env-file .env.docker run --rm --no-deps api php artisan key:generate --show
```

Copie a chave `base64:...` exibida para `APP_KEY=` em `.env.docker`. Depois inicie os serviços e crie o banco:

```powershell
docker compose --env-file .env.docker up -d
docker compose --env-file .env.docker exec api php artisan migrate --seed --force
```

Endereços locais:

| Serviço | Endereço |
|---|---|
| Aplicação Flutter Web | <http://localhost:8080> |
| API Laravel direta | <http://localhost:8000/api> |
| Documentação Scramble | <http://localhost:8080/docs/api> |
| phpMyAdmin | <http://localhost:8081> |

Para o phpMyAdmin, use o banco `helpdesk`, usuário `helpdesk` e a senha local `helpdesk_local_password` definidos no Compose.

### Contas de demonstração

O `DatabaseSeeder` cria três clientes e três técnicos. As contas são somente para desenvolvimento local; todas usam a senha `123456`.

| Perfil | E-mail |
|---|---|
| Técnico | `tecnico@empresa.com` |
| Técnico | `tecnico2@empresa.com` |
| Técnico | `tecnico3@empresa.com` |
| Cliente | `usuario@empresa.com` |
| Cliente | `usuario2@empresa.com` |
| Cliente | `usuario3@empresa.com` |

### Comandos úteis

```powershell
# Acompanhar os logs
docker compose --env-file .env.docker logs -f

# Abrir um terminal dentro do container Laravel (serviço api)
docker compose --env-file .env.docker exec api bash

# Executar um seed sem abrir o terminal interativo
docker compose --env-file .env.docker exec api php artisan db:seed --class=DatabaseSeeder --force

# Recriar imagens e aplicar alterações no Flutter Web/API
docker compose --env-file .env.docker up -d --build api web

# Parar os containers sem apagar os dados
docker compose --env-file .env.docker down
```

Os dados do MySQL e os anexos ficam em volumes Docker e são preservados ao parar os containers. `docker compose down -v` também remove esses volumes e apaga os dados locais.

O shell acima abre o container da **API Laravel**. O Flutter não roda nesse container: no Docker, o serviço `web` entrega a versão web já compilada pelo Nginx. Para abrir o aplicativo no navegador quando o Compose estiver ligado, acesse <http://localhost:8080>.

## Rodar o Flutter localmente com a API no Docker

Este modo deixa banco e API no Docker e executa o Flutter no computador. Na primeira vez, conclua antes a configuração do `.env.docker` e gere a chave `APP_KEY` conforme os passos da seção anterior. Depois, na raiz do repositório, inicie banco e API e prepare o banco:

```powershell
docker compose --env-file .env.docker up -d --build db api
docker compose --env-file .env.docker exec api php artisan migrate --seed --force
```

Em outro terminal PowerShell, instale as dependências Flutter e inicie no Chrome:

```powershell
Set-Location .\helpdesk_app
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api
```

Para descobrir os dispositivos disponíveis, use `flutter devices`. O endereço `http://localhost:8000/api` funciona para Flutter Web no computador. Para o emulador Android, o app usa por padrão `http://10.0.2.2:8000/api`.

Para instalar dependências da API e executar tudo fora do Docker, é necessário ter PHP, Composer e MySQL instalados. Na pasta `helpdesk-api`, execute `composer install`, copie `.env.example` para `.env`, configure as credenciais de um MySQL local e rode:

```powershell
php artisan key:generate
php artisan migrate --seed
php artisan serve --host=0.0.0.0 --port=8000
```

Em outro terminal, rode os comandos Flutter da seção anterior. Nesse modo, a API deve estar acessível em `http://localhost:8000`.

Para uma URL de API diferente, defina `API_BASE_URL` com `--dart-define` ao iniciar ou compilar o Flutter. A documentação Scramble fica disponível no ambiente `local`.

## Observação de segurança

O Compose deste repositório é voltado a demonstrações locais. Antes de publicar o sistema, troque as credenciais de desenvolvimento, proteja anexos que não devam ser públicos, configure HTTPS e desative o modo de depuração.
