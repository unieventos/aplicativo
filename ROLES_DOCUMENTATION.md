# 👥 Documentação de Roles - API UniEventos

## Roles Disponíveis na API

A API UniEventos suporta **3 tipos de roles** com diferentes níveis de permissão:

### 1. ADMIN (ID: 1)
- **Nome:** Administrador
- **Nível:** Maior nível de permissão
- **Descrição:** Acesso completo ao sistema
- **Permissões:** Todas as operações (CRUD completo)

### 2. GESTOR (ID: 2)
- **Nome:** Gestor
- **Nível:** Nível intermediário de permissão
- **Descrição:** Gestão de conteúdo e usuários
- **Permissões:** Gerenciar eventos, usuários e conteúdo

### 3. COLABORADOR (ID: 3)
- **Nome:** Colaborador
- **Nível:** Nível básico de permissão
- **Descrição:** Acesso limitado ao sistema
- **Permissões:** Visualizar e participar de eventos

## Estrutura no Banco de Dados

### Tabela `role`
```sql
role_id: BIGINT (Identificador único)
name: VARCHAR(50) (Nome do role, único e obrigatório)
```

### Relacionamento com Usuários
- **Tipo:** Many-to-One (Usuario → Role)
- **Regra:** Um usuário pode ter apenas um role
- **Regra:** Um role pode ser atribuído a múltiplos usuários

## Criação dos Roles

Os roles são criados automaticamente através do script de migração:
- **Arquivo:** `2025-03-15_CREATE_DEFAULT_ROLES.xml`
- **Função:** Insere os três roles padrão no sistema
- **Execução:** Automática durante a inicialização do banco

## Integração Flutter

### Código Atualizado
```dart
DropdownButtonFormField<String>(
  decoration: InputDecoration(labelText: "Perfil"),
  items: [
    DropdownMenuItem(value: 'ADMIN', child: Text('Administrador')),
    DropdownMenuItem(value: 'GESTOR', child: Text('Gestor')),
    DropdownMenuItem(value: 'COLABORADOR', child: Text('Colaborador')),
  ],
  onChanged: (value) {
    if (value != null) {
      _roleController.text = value;
    }
  },
  validator: (v) => v == null || v.isEmpty ? 'Selecione um perfil' : null,
),
```

### Validação
- **Obrigatório:** Usuário deve selecionar um role
- **Valores aceitos:** ADMIN, GESTOR, COLABORADOR
- **Formato:** Maiúsculo (conforme API)

## Testes Realizados

### ✅ Roles Funcionais
- `"ADMIN"` ✅ - Testado e funcionando
- `"GESTOR"` ✅ - Testado e funcionando  
- `"COLABORADOR"` ✅ - Testado e funcionando

### ❌ Roles Não Suportados
- `"usuario"` ❌ - Não existe na API
- `"USER"` ❌ - Não existe na API
- `"ADMINISTRADOR"` ❌ - Nome incorreto
- Qualquer outro valor ❌ - Não aceito

## Controle de Permissões

### @PreAuthorize no Controller
```java
@PreAuthorize("hasAnyRole('ADMIN', 'GESTOR')")
@PostMapping
public ResponseEntity<?> createUser(@RequestBody @Valid CreateUserRecord createUserDTO)
```

**Significado:** Apenas usuários com roles ADMIN ou GESTOR podem criar novos usuários.

## Hierarquia de Permissões

```
ADMIN (Nível 3)
├── Acesso completo ao sistema
├── Pode criar/editar/deletar usuários
├── Pode gerenciar eventos
└── Pode acessar todas as funcionalidades

GESTOR (Nível 2)
├── Pode criar/editar usuários
├── Pode gerenciar eventos
└── Acesso limitado a configurações

COLABORADOR (Nível 1)
├── Pode visualizar eventos
├── Pode participar de eventos
└── Acesso básico ao sistema
```

## Status da Integração

- [x] **Flutter atualizado** com os 3 roles corretos
- [x] **API testada** com todos os roles
- [x] **Validação implementada** no frontend
- [x] **Documentação criada** com especificações

## Data da Atualização
19 de Outubro de 2024

## Status
✅ **COMPLETO** - Integração totalmente funcional com os 3 roles corretos
