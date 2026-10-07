# 💈 Barber Shop API

API REST para gerenciamento de **clientes** e **agendamentos** de uma barbearia, desenvolvida com **Java 25** e **Spring Boot** como parte do projeto full stack da DIO.

> 🔗 Frontend do projeto: [dio-projeto-full-stack-agendamento-barbearia](https://github.com/bartguitar/dio-projeto-full-stack-agendamento-barbearia)

---

## 📋 Sobre o projeto

A Barber Shop API oferece o cadastro de clientes e o controle da agenda da barbearia. Ela impede que dois clientes sejam agendados no mesmo horário e garante que e-mail e telefone de cada cliente sejam únicos.

### Funcionalidades

- Cadastro, consulta, listagem, atualização e remoção de clientes
- Criação e remoção de agendamentos
- Consulta da agenda mensal, com os agendamentos ordenados por data
- Validação de dados de entrada (campos obrigatórios e formato de e-mail)
- Bloqueio de e-mail, telefone e horário duplicados
- Versionamento do banco de dados com migrations
- Ambiente de desenvolvimento containerizado com hot reload e debug remoto

---

## 🛠️ Tecnologias

| Categoria | Tecnologia |
|---|---|
| Linguagem | Java 25 |
| Framework | Spring Boot 4.1.1 (Spring Web MVC, Spring Data JPA, Bean Validation) |
| Banco de dados | PostgreSQL 17.2 |
| Migrations | Flyway |
| Mapeamento de objetos | MapStruct 1.6.3 |
| Produtividade | Lombok, Spring Boot DevTools |
| Build | Gradle (Kotlin DSL) |
| Testes | JUnit Platform |
| Containers | Docker e Docker Compose |

---

## 🏗️ Arquitetura

O projeto segue uma arquitetura em camadas, com separação entre serviços de escrita e serviços de consulta:

```
src/main/java/br/com/dio/barber_api
├── config/              # Configurações (CORS)
├── controller/          # Endpoints REST
│   ├── request/         # DTOs de entrada
│   └── response/        # DTOs de saída
├── entity/              # Entidades JPA (ClientEntity, ScheduleEntity)
├── exception/           # Exceções de negócio
├── exceptionhandler/    # Tratamento global de erros
├── mapper/              # Mapeadores MapStruct
├── repository/          # Repositórios Spring Data JPA
└── service/
    ├── impl/            # Regras de escrita (save, update, delete)
    └── query/           # Regras de consulta e verificações
```

### Modelo de dados

```
CLIENTS                          SCHEDULES
├── id (PK, bigserial)           ├── id (PK, bigserial)
├── name (varchar 150)           ├── start_at (timestamp)
├── email (varchar 150, único)   ├── end_at (timestamp)
└── phone (char 11, único)       └── client_id (FK → CLIENTS.id)
                                     UNIQUE (start_at, end_at)
```

Um cliente pode ter vários agendamentos. O esquema é criado e versionado pelo Flyway, e o Hibernate apenas o valida (`ddl-auto: validate`).

---

## 🚀 Como executar

### Pré-requisitos

- [Docker](https://www.docker.com/) e Docker Compose
- (Opcional, para rodar sem Docker) JDK 25 e uma instância do PostgreSQL

### Com Docker Compose (recomendado)

1. Clone o repositório:

```bash
git clone https://github.com/bartguitar/dio-projeto-full-stack-agendamento-barbearia-backend.git
cd dio-projeto-full-stack-agendamento-barbearia-backend
```

2. Crie a rede externa usada pelo Compose (apenas na primeira vez):

```bash
docker network create barber-shop-net
```

3. Suba os containers:

```bash
docker compose up --build
```

A API ficará disponível em `http://localhost:8080`.

| Serviço | Porta no host | Descrição |
|---|---|---|
| API | `8080` | Aplicação Spring Boot |
| Debug remoto | `5005` | Porta de debug Java |
| PostgreSQL | `5433` | Banco de dados (mapeada de `5432` para evitar conflitos) |

### Sem Docker

1. Crie um banco PostgreSQL e defina as variáveis de ambiente:

```bash
export DB_URL=jdbc:postgresql://localhost:5432/barber-shop-api
export DB_USER=barber-shop-api
export DB_PASSWORD=barber-shop-api
export SPRING_PROFILES_ACTIVE=dev
```

2. Execute a aplicação:

```bash
./gradlew bootRun
```

As migrations do Flyway são aplicadas automaticamente na inicialização.

### Variáveis de ambiente

| Variável | Descrição | Valor usado no Compose |
|---|---|---|
| `DB_URL` | URL JDBC do PostgreSQL | `jdbc:postgresql://db:5432/barber-shop-api` |
| `DB_USER` | Usuário do banco | `barber-shop-api` |
| `DB_PASSWORD` | Senha do banco | `barber-shop-api` |
| `SPRING_PROFILES_ACTIVE` | Perfil ativo | `dev` |

> ⚠️ As credenciais acima são apenas para desenvolvimento local. Em produção, use valores seguros.

---

## 📡 Endpoints

### Clientes — `/clients`

| Método | Rota | Descrição | Status de sucesso |
|---|---|---|---|
| `POST` | `/clients` | Cadastra um cliente | `201 Created` |
| `GET` | `/clients` | Lista todos os clientes | `200 OK` |
| `GET` | `/clients/{id}` | Busca um cliente por ID | `200 OK` |
| `PUT` | `/clients/{id}` | Atualiza um cliente | `200 OK` |
| `DELETE` | `/clients/{id}` | Remove um cliente | `204 No Content` |

**Corpo de `POST` e `PUT`:**

```json
{
  "name": "João Silva",
  "email": "joao@email.com",
  "phone": "11999999999"
}
```

Todos os campos são obrigatórios, e o e-mail precisa ter formato válido.

### Agendamentos — `/schedules`

| Método | Rota | Descrição | Status de sucesso |
|---|---|---|---|
| `POST` | `/schedules` | Cria um agendamento | `201 Created` |
| `GET` | `/schedules/{year}/{month}` | Lista os agendamentos de um mês | `200 OK` |
| `DELETE` | `/schedules/{id}` | Remove um agendamento | `204 No Content` |

**Corpo de `POST /schedules`:**

```json
{
  "startAt": "2026-10-15T14:00:00Z",
  "endAt": "2026-10-15T14:30:00Z",
  "clientId": 1
}
```

**Resposta de `GET /schedules/2026/10`:**

```json
{
  "year": 2026,
  "month": 10,
  "scheduledAppointments": [
    {
      "id": 1,
      "day": 15,
      "startAt": "2026-10-15T14:00:00Z",
      "endAt": "2026-10-15T14:30:00Z",
      "clientId": 1,
      "clientName": "João Silva"
    }
  ]
}
```

### Exemplo de uso

```bash
curl -X POST http://localhost:8080/clients \
  -H "Content-Type: application/json" \
  -d '{"name":"João Silva","email":"joao@email.com","phone":"11999999999"}'
```

### Formato de erro

Erros tratados pelo handler global retornam:

```json
{
  "status": 500,
  "timestamp": "2026-10-07T13:00:00Z",
  "message": "Agendamento não encontrado"
}
```

---

## 📏 Regras de negócio

- O **e-mail** e o **telefone** de cada cliente são únicos.
- Não é possível criar dois agendamentos com o mesmo intervalo (`startAt` e `endAt`).
- Só é possível atualizar ou remover clientes e agendamentos que existem.
- Ao remover um cliente, seus agendamentos também são removidos.
- A consulta mensal considera o mês completo em UTC.

---

## 🗄️ Migrations

As migrations ficam em `src/main/resources/db/migration`. Para gerar um novo arquivo com timestamp automático:

```bash
./gradlew generateFlywayMigrationFile -PmigrationName=nome_da_migracao
```

---

## 🔧 Desenvolvimento

- O **DevTools** reinicia a aplicação automaticamente após o build, usando o arquivo `trigger.txt`.
- O container expõe a porta **5005** para debug remoto.
- O perfil `dev` exibe e formata os SQLs executados.
- O CORS está liberado para qualquer origem, para facilitar a integração com o frontend em desenvolvimento.

### Testes

```bash
./gradlew test
```

---

## 👨‍💻 Autor

Desenvolvido por **Adriel** ([@bartguitar](https://github.com/bartguitar)) como projeto prático do bootcamp da [DIO](https://www.dio.me/).
