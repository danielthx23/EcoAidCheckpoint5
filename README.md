# HOW TO - Guia de Deploy Passo a Passo

## 📋 Pré-requisitos

Antes de iniciar o deploy, certifique-se de que possui:

* **Azure CLI** instalado: [https://aka.ms/installazurecliwindows](https://aka.ms/installazurecliwindows)
* **Conta GitHub** com acesso ao repositório
* **Conta Azure ativa** (Azure for Students é suficiente)
* **Arquivo `deploy.cmd`** salvo na raiz do projeto

---

## 🧩 Passo 1: Preparar o ambiente

1. Abra o **Prompt de Comando (CMD)** ou **PowerShell**
2. Clone o repositório localmente (opcional):

```bash
git clone https://github.com/dan25ak1/EcoAidCheckpoint5.git
cd EcoAidCheckpoint5
```

---

## ⚙️ Passo 2: Personalizar variáveis

No início do arquivo `deploy.cmd` ou `deploy.sh`, edite as seguintes variáveis conforme o seu projeto:

| Variável              | Descrição                                                                                  |
| --------------------- | ------------------------------------------------------------------------------------------ |
| `RESOURCE_GROUP_NAME` | Nome do grupo de recursos                                                                  |
| `WEBAPP_NAME`         | Nome único para o Web App (globalmente único no Azure)                                     |
| `SQL_SERVER_NAME`     | Nome único do SQL Server (também globalmente único)                                        |
| `SQL_ADMIN_USER`      | Usuário administrador do SQL Server                                                        |
| `SQL_ADMIN_PASSWORD`  | Senha forte (mínimo 8 caracteres, letra maiúscula, minúscula, número e caractere especial) |
| `GITHUB_REPO_NAME`    | Repositório GitHub no formato `usuario/repositorio`                                        |

---

## 🚀 Passo 3: Executar o script

1. **Entre na pasta** `scripts`:

```cmd
cd scripts
```

2. **Execute o script** [deploy.cmd](scripts/deploy.cmd) ou [deploy.sh](scripts/deploy.sh):

```cmd
deploy.cmd
```

---

```cmd
chmod +x deploy.sh
```
```cmd
./deploy.sh 
```

O script fará automaticamente:

* Login no Azure;
* Criação de grupo de recursos;
* Criação de SQL Server e banco de dados;
* Configuração do firewall;
* Criação do App Service e Application Insights;
* Configuração do GitHub Actions para deploy contínuo.

---

## 🔐 Passo 4: Autenticação

Durante a execução, você será solicitado a:

* **Fazer login na Azure** (abrirá uma janela do navegador)
* **Autorizar o GitHub** (será exibido um código para inserir em [https://github.com/login/device](https://github.com/login/device))

---

## 🧾 Passo 5: Verificar o deploy

Após a execução bem-sucedida:

* Acesse a aplicação:

  ```
  https://<seu-webapp-name>.azurewebsites.net
  ```

* Monitore os logs em tempo real:

  ```cmd
  az webapp log tail --name <WEBAPP_NAME> --resource-group <RESOURCE_GROUP_NAME>
  ```

* Acompanhe o workflow de deploy no GitHub Actions:

  ```
  https://github.com/<seu-usuario>/<seu-repo>/actions
  ```

---

## 👤 Passo 6: Criar um usuário para acessar a API

```bash
curl -X POST https://<seu-webapp-name>.azurewebsites.net/usuarios/cadastrar \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Silva",
    "usuario": "joao@email.com",
    "senha": "Senha@123",
    "foto": null
  }'
```

---

## 🧱 JSON de Operações da API (GET, POST, PUT, DELETE)

Abaixo estão exemplos baseados nas tabelas `tb_usuario`, `tb_categoria` e `tb_produto`.

### 🔹 Usuários

**POST /usuarios/cadastrar**

```json
{
  "nome": "João Silva",
  "usuario": "joao@email.com",
  "senha": "Senha@123",
  "foto": null
}
```

**GET /usuarios**

```json
[
  {
    "id": 1,
    "nome": "João Silva",
    "usuario": "joao@email.com",
    "foto": null
  }
]
```

**PUT /usuarios/1**

```json
{
  "nome": "João S. Almeida",
  "foto": "https://exemplo.com/joao.jpg"
}
```

---

### 🔹 Categorias

**POST /categorias**

```json
{
  "tipo": "Roupas",
  "descricao": "Peças de vestuário em bom estado"
}
```

**GET /categorias**

```json
[
  {
    "id": 1,
    "tipo": "Roupas",
    "descricao": "Peças de vestuário em bom estado"
  }
]
```

**PUT /categorias/1**

```json
{
  "descricao": "Vestuário usado, porém bem conservado"
}
```

**DELETE /categorias/1**

---

### 🔹 Produtos

**POST /produtos**

```json
{
  "nome": "Camisa Polo",
  "descricao": "Camisa polo azul em ótimo estado",
  "condicao": "Usado",
  "preco": 49.99,
  "foto": "https://exemplo.com/camisa.jpg",
  "usuario_id": 1,
  "categoria_id": 1
}
```

**GET /produtos**

```json
[
  {
    "id": 1,
    "nome": "Camisa Polo",
    "descricao": "Camisa polo azul em ótimo estado",
    "condicao": "Usado",
    "preco": 49.99,
    "foto": "https://exemplo.com/camisa.jpg",
    "usuario_id": 1,
    "categoria_id": 1
  }
]
```

**PUT /produtos/1**

```json
{
  "preco": 39.99,
  "condicao": "Semi-novo"
}
```

**DELETE /produtos/1**

---

## 🧰 Dica final

Caso precise repetir o processo:

* Exclua o **Resource Group** antes de rodar o script novamente:

  ```cmd
  az group delete --name <RESOURCE_GROUP_NAME> --yes --no-wait
  ```

---

📘 **Pronto!**
Seu projeto **EcoAidCheckpoint5** estará rodando no Azure com deploy automatizado via **GitHub Actions**, banco SQL configurado e endpoints da API prontos para uso.

