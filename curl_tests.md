# 🧪 Testes cURL para API UniEventos

## Configuração Base
```bash
BASE_URL="http://172.171.192.14:8081/unieventos"
```

## 1. 🔐 Teste de Login

```bash
# Login básico
curl -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "login": "admin",
    "password": "hSy0aKPR168w",
    "stayLogged": true
  }'
```

**Resposta esperada:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTc2MDkwMjgzM30.dCK6kChZ6y33rVjWljQ0uz5y8eE0XEIbnja01-dOWz0"
}
```

## 2. 👥 Teste de Usuários

### 2.1 Listar Usuários
```bash
# Substitua TOKEN pelo token obtido no login
TOKEN="seu_token_aqui"

curl -X GET "$BASE_URL/usuarios?page=0&size=5&sortBy=nome" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

### 2.2 Buscar Usuário Logado
```bash
curl -X GET "$BASE_URL/usuarios/me" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

### 2.3 Criar Usuário (FORMATO CORRETO)
```bash
curl -X POST "$BASE_URL/usuarios" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "login": "teste_curl_1",
    "curso": "Ciência da Computação",
    "email": "teste1@exemplo.com",
    "senha": "123456",
    "nome": "Usuario",
    "sobrenome": "Teste1",
    "role": "ADMIN"
  }'
```

### 2.4 Criar Usuário Gestor
```bash
curl -X POST "$BASE_URL/usuarios" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "login": "gestor_teste",
    "curso": "Ciência da Computação",
    "email": "gestor@exemplo.com",
    "senha": "123456",
    "nome": "Gestor",
    "sobrenome": "Teste",
    "role": "GESTOR"
  }'
```

### 2.5 Criar Usuário Colaborador
```bash
curl -X POST "$BASE_URL/usuarios" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "login": "colaborador_teste",
    "curso": "Ciência da Computação",
    "email": "colaborador@exemplo.com",
    "senha": "123456",
    "nome": "Colaborador",
    "sobrenome": "Teste",
    "role": "COLABORADOR"
  }'
```

**✅ ROLES ACEITOS:**
- `"ADMIN"` - Administrador (maior permissão)
- `"GESTOR"` - Gestor (permissão intermediária)
- `"COLABORADOR"` - Colaborador (permissão básica)

**⚠️ IMPORTANTE:**
- Use `"curso": "Nome do Curso"` (não `cursoId`)
- Use roles em MAIÚSCULO
- Resposta vazia = sucesso (201)

## 3. 🎉 Teste de Eventos

### 3.1 Listar Eventos
```bash
curl -X GET "$BASE_URL/eventos?page=0&size=5&sortBy=dateInicio" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

### 3.2 Criar Evento
```bash
curl -X POST "$BASE_URL/eventos" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "nomeEvento": "Evento Teste cURL",
    "descricao": "Descrição do evento de teste via cURL",
    "dateInicio": "2024-01-15T10:00:00.000Z",
    "dateFim": "2024-01-15T18:00:00.000Z",
    "categoria": "Teste"
  }'
```

## 4. 📂 Teste de Categorias

```bash
curl -X GET "$BASE_URL/categorias?size=10" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

## 5. 🔍 Testes de Validação

### 5.1 Login Duplicado
```bash
# Primeiro usuário
curl -X POST "$BASE_URL/usuarios" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "login": "usuario_duplicado",
    "cursoId": 1,
    "email": "duplicado1@exemplo.com",
    "senha": "123456",
    "nome": "Usuario",
    "sobrenome": "Duplicado1",
    "role": "USER"
  }'

# Segundo usuário com mesmo login (deve falhar)
curl -X POST "$BASE_URL/usuarios" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "login": "usuario_duplicado",
    "cursoId": 1,
    "email": "duplicado2@exemplo.com",
    "senha": "123456",
    "nome": "Usuario",
    "sobrenome": "Duplicado2",
    "role": "USER"
  }'
```

### 5.2 Email Inválido
```bash
curl -X POST "$BASE_URL/usuarios" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "login": "teste_email_invalido",
    "cursoId": 1,
    "email": "email_sem_arroba",
    "senha": "123456",
    "nome": "Usuario",
    "sobrenome": "Email",
    "role": "USER"
  }'
```

## 6. 🚨 Testes de Erro

### 6.1 Sem Token
```bash
curl -X GET "$BASE_URL/usuarios" \
  -H "Content-Type: application/json"
```

### 6.2 Token Inválido
```bash
curl -X GET "$BASE_URL/usuarios" \
  -H "Authorization: Bearer token_invalido" \
  -H "Content-Type: application/json"
```

### 6.3 Dados Incompletos
```bash
curl -X POST "$BASE_URL/usuarios" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "login": "teste_incompleto"
  }'
```

## 7. 📊 Script de Teste Completo

Execute o script completo:
```bash
# Teste geral da API
./test_api.sh

# Teste específico de criação de usuários
./test_user_creation.sh
```

## 8. 🔧 Debug e Troubleshooting

### Verificar Conectividade
```bash
# Ping do servidor
ping 172.171.192.14

# Verificar se a porta está aberta
telnet 172.171.192.14 8081

# Verificar se o endpoint responde
curl -I "$BASE_URL/auth/login"
```

### Logs Úteis
- Verifique os logs do servidor para erros detalhados
- Use `-v` no cURL para ver headers completos: `curl -v ...`
- Use `-i` para ver headers de resposta: `curl -i ...`

### Códigos de Status Esperados
- `200` - Sucesso
- `201` - Criado com sucesso
- `400` - Dados inválidos
- `401` - Não autorizado
- `403` - Proibido
- `404` - Não encontrado
- `409` - Conflito (ex: login duplicado)
- `500` - Erro interno do servidor
