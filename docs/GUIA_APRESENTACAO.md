# Guia de estudo e apresentação do HELP! desk

Este guia sugere uma ordem para entender o projeto e um roteiro curto para demonstrar o app. A ideia é explicar o caminho de uma ação do usuário até o banco, sem decorar cada arquivo.

## Ordem para estudar

1. **Visão geral:** leia `README.md` para entender o problema, os papéis (cliente e técnico) e as regras do sistema.
2. **Ambiente:** veja `docker-compose.yml`. Ele sobe o MySQL (`db`), a API Laravel (`api`), o phpMyAdmin (`phpmyadmin`) e o Flutter compilado para Web (`web`).
3. **Entrada do Flutter:** leia `helpdesk_app/lib/main.dart` e `app.dart`. O `main` prepara o Flutter e restaura a sessão salva; `app.dart` registra as telas, o tema e o roteador.
4. **Rotas:** leia `core/routes/app_routes.dart` e `app_router.dart`. Entenda os nomes, os caminhos e como o parâmetro `:id` chega às telas de detalhe, edição e perfil.
5. **Comunicação com a API:** leia `services/api_config.dart`, depois `auth_service.dart` e `ticket_service.dart`. Eles definem o endereço da API, cabeçalhos/token e convertem respostas JSON em modelos.
6. **Fluxo de uso principal:** acompanhe `screens/login/login_screen.dart` → `screens/home/home_screen.dart` → `screens/ticket_form/ticket_form_screen.dart` → `screens/ticket_detail/ticket_detail_screen.dart`. Foque em `initState`, carregamento, envio de formulário e atualização de estado.
7. **Formato dos dados:** consulte `models/` para ver como JSON da API vira objetos Dart, por exemplo `TicketModel` e `UserModel`.
8. **Entrada do backend:** leia `helpdesk-api/routes/api.php` para ver cada endpoint e quais exigem autenticação Sanctum.
9. **Responsabilidades da API:** acompanhe um endpoint pelo controller, depois service, repository/model e Form Request/Resource. Exemplo: `TicketController::store` → `TicketService::createTicket` → models e `TicketResource`.
10. **Persistência:** por fim, olhe `helpdesk-api/database/migrations/` para entender tabelas e relações. Não precisa memorizar cada coluna para apresentar as funcionalidades.

## Mapa das telas e rotas Flutter

| Nome da rota | Caminho | Para que serve |
|---|---|---|
| `login` | `/login` | Entrada do usuário |
| `home` | `/home` | Painel e lista de chamados, com ações por papel |
| `ticket-form` | `/tickets/new` | Abrir chamado |
| `ticket-detail` | `/tickets/:id` | Ver chamado, histórico, responder e acompanhar status |
| `ticket-edit` | `/tickets/:id/edit` | Reutiliza o formulário para editar |
| `profile` | `/profile/:id` | Ver/editar perfil |

## Mapa resumido dos endpoints

As rotas abaixo estão em `helpdesk-api/routes/api.php`. As públicas não precisam de token; as demais ficam no grupo `auth:sanctum` e recebem `Authorization: Bearer <token>`.

| Método e endpoint | Ação |
|---|---|
| `POST /api/register`, `POST /api/login` | Criar conta de cliente ou iniciar sessão (públicas) |
| `POST /api/technicians` | Cadastrar técnico; exige token Sanctum de um técnico já cadastrado |
| `POST /api/logout` | Revogar o token atual |
| `GET /api/tickets` | Listar chamados conforme o papel do usuário |
| `POST /api/tickets` | Criar chamado; a descrição inicial vira a primeira mensagem |
| `GET /api/tickets/{id}` | Consultar detalhes e histórico |
| `PUT /api/tickets/{id}` / `DELETE /api/tickets/{id}` | Editar ou excluir conforme as permissões |
| `POST /api/tickets/{id}/messages` | Enviar mensagem e possível anexo |
| `PATCH /api/tickets/{id}/status` | Alterar status, permitido a técnicos |
| `POST /api/profile` ou `PUT /api/profile` | Atualizar perfil (o app usa multipart quando envia foto) |
| `GET /api/users/{id}` | Consultar dados públicos de um usuário |
| `GET /api/notifications`, `PATCH /api/notifications/{id}/read` | Listar notificações e marcá-las como lidas |

Para `POST /api/technicians`, envie nome, e-mail, senha e confirmação de senha com o token Bearer de um técnico já existente. O papel é definido pela API. Em um banco novo, o `DatabaseSeeder` cria os primeiros técnicos para permitir esse fluxo.

## Roteiro de demonstração

1. Entre como cliente e mostre o painel: lista, pesquisa/filtros e dados resumidos.
2. Abra **Novo chamado**: explique título, categoria, prioridade, descrição e anexo opcional.
3. Abra o chamado criado: mostre os detalhes e envie uma mensagem para demonstrar o histórico.
4. Entre como técnico: mostre que a fila é diferente, abra o mesmo chamado e altere o status/responda.
5. Mostre notificações e perfil, se houver tempo.
6. Encerre explicando que as permissões importantes são verificadas também na API; a interface apenas apresenta as ações disponíveis.

Antes da apresentação, deixe contas de demonstração prontas e confirme que o Docker/API está ativo. Evite depender de cadastro ou configuração de rede ao vivo.

## Como explicar o caminho de uma ação

Use a criação de chamado como exemplo:

1. A tela coleta os campos e chama `TicketService.createTicket`.
2. O serviço Flutter monta uma requisição HTTP multipart, porque o anexo é opcional, e inclui o token Sanctum.
3. A rota Laravel exige autenticação e encaminha para `TicketController::store`.
4. `StoreTicketRequest` valida os dados. `TicketService` aplica regras, grava o chamado, a primeira mensagem e eventual arquivo, e notifica técnicos.
5. `TicketResource` formata a resposta. O Flutter converte o JSON em `TicketModel` e atualiza a tela.

## Perguntas que podem aparecer

- **Por que há services?** Para separar a tela da comunicação HTTP no Flutter e separar o controller das regras de negócio no Laravel.
- **Como a sessão é mantida?** O Laravel Sanctum emite um token; o Flutter guarda-o em armazenamento seguro e envia-o como Bearer nas rotas protegidas.
- **Como cliente e técnico têm acesso diferente?** A API consulta o papel do usuário autenticado e valida autorização no serviço. Ocultar um botão no app não seria segurança suficiente.
- **Como funciona o anexo?** O seletor fornece bytes na Web ou um caminho no dispositivo; o Flutter envia multipart e a API guarda o arquivo associado à mensagem.
- **Por que a descrição inicial aparece na conversa?** Ela é salva como a primeira mensagem do chamado, então todo o histórico usa o mesmo modelo.

Se não souber um detalhe, mostre o caminho no código e explique o que conseguiu confirmar. É melhor distinguir uma regra que você verificou de uma suposição.
