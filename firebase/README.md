# 🔥 Configurações Firebase - Basal Fit

Esta pasta contém todas as regras de segurança e configurações do Firebase para o projeto Basal Fit.

## 📁 Estrutura de Arquivos

### 🔐 **Regras Atuais (Recomendadas)**

- **[`firestore.rules`](./firestore.rules)** - Regras de segurança atualizadas do Firestore
- **[`storage.rules`](./storage.rules)** - Regras de segurança do Firebase Storage (referência)

### 📋 **Regras Legadas**

- **[`firestore_rules_legacy.txt`](./firestore_rules_legacy.txt)** - Regras antigas do Firestore
- **[`storage_rules_legacy.txt`](./storage_rules_legacy.txt)** - Regras antigas do Storage

### 🔧 **Configuração de Projeto**

- **[`google-services.json.example`](./google-services.json.example)** - Exemplo de configuração do Google Services
- **`firebase.json`** - Configuração de deploy (na raiz do projeto)

## ⚙️ Configuração Inicial

### **1. Configurar Google Services**

1. **Baixe o arquivo de configuração:**

   - Acesse [Firebase Console](https://console.firebase.google.com)
   - Selecione seu projeto
   - Vá em **Configurações do projeto > Seus aplicativos**
   - Baixe o `google-services.json` (Android) ou `GoogleService-Info.plist` (iOS)

2. **Configure o projeto:**

   ```bash
   # Copie o arquivo para a pasta raiz (Android)
   cp google-services.json ./

   # Configure as variáveis de ambiente (se necessário)
   # Ou use o arquivo de exemplo como referência
   ```

3. **Instale Firebase CLI (opcional):**
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase init
   ```

## 🚀 Como Aplicar as Regras

### **1. Regras do Firestore**

#### **Via Firebase CLI:**

```bash
# Na pasta raiz do projeto
firebase deploy --only firestore:rules
```

#### **Via Console Web:**

1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Selecione seu projeto
3. Vá em **Firestore Database > Regras**
4. Copie o conteúdo de [`firestore.rules`](./firestore.rules)
5. Cole no editor e clique em **Publicar**

### **2. Regras do Storage (Opcional)**

⚠️ **IMPORTANTE:** O projeto atual **NÃO** usa Firebase Storage. As imagens são armazenadas em base64 no Firestore.

Se quiser reativar o Storage:

#### **Via Firebase CLI:**

```bash
firebase deploy --only storage
```

#### **Via Console Web:**

1. Acesse **Storage > Regras**
2. Copie o conteúdo de [`storage.rules`](./storage.rules)
3. Adapte conforme necessário
4. Publique as regras

## 🛡️ Melhorias Implementadas

### **Regras do Firestore Atualizadas:**

#### **1. Funções Auxiliares**

- `isAuthenticated()` - Verifica autenticação
- `isOwner(userId)` - Verifica propriedade
- `isValidUserProfile()` - Valida dados do perfil
- `isValidWeightRecord()` - Valida registros de peso
- `isValidExerciseRecord()` - Valida registros de exercício
- `isValidTMBRecord()` - Valida registros de TMB
- `isValidExercise()` - Valida exercícios

#### **2. Validações Robustas**

- **Campos obrigatórios** verificados
- **Tipos de dados** validados
- **Limites de tamanho** aplicados
- **Valores válidos** para enums
- **Segurança de acesso** garantida

#### **3. Estrutura de Segurança**

```
/users/{userId}                    # Perfil do usuário
  ├── /weight_records/{recordId}   # Registros de peso
  ├── /exercise_records/{recordId} # Registros de exercício
  └── /tmb_records/{recordId}      # Registros de TMB

/exercises/{exerciseId}            # Exercícios públicos
```

## 📊 Validações Implementadas

### **Perfil do Usuário:**

- **Nome:** 1-150 caracteres
- **Email:** Formato válido
- **Idade:** 13-120 anos
- **Peso:** 15-450 kg
- **Altura:** 45-295 cm
- **Gênero:** Masculino/Feminino
- **Nível de Atividade:** Valores predefinidos
- **Imagem:** Base64 ou URL válida

### **Registros de Peso:**

- **Peso:** 15-450 kg
- **Data:** Timestamp válido
- **Nota:** Máximo 500 caracteres

### **Registros de Exercício:**

- **Duração:** 1-1440 minutos (máx 24h)
- **Calorias:** Valor positivo
- **Data:** Timestamp válido
- **Nota:** Máximo 500 caracteres

### **Registros de TMB:**

- **TMB:** 800-4000 kcal
- **GET:** 1000-8000 kcal
- **Dados corporais:** Mesmas validações do perfil

### **Exercícios:**

- **Nome:** 1-100 caracteres
- **Categoria:** 1-50 caracteres
- **Calorias/min:** 0-50 kcal
- **Descrição:** Máximo 500 caracteres

## 🔄 Migração das Regras

### **Mudanças Principais:**

1. **Estrutura funcional** com funções auxiliares
2. **Validações robustas** para todos os dados
3. **Limites apropriados** baseados nas constantes do app
4. **Segurança aprimorada** com verificações detalhadas
5. **Suporte a base64** para imagens

### **Compatibilidade:**

- ✅ **Dados existentes** continuam funcionando
- ✅ **Validações** garantem qualidade dos novos dados
- ✅ **Segurança** aprimorada sem quebrar funcionalidades

## 🚨 Importante

### **Para Desenvolvedores:**

1. **Teste as regras** em ambiente de desenvolvimento primeiro
2. **Backup dos dados** antes de aplicar em produção
3. **Monitore erros** após aplicar novas regras
4. **Ajuste validações** se necessário para casos específicos

### **Para Produção:**

1. **Aplique em horário de baixo tráfego**
2. **Monitore logs** do Firebase Console
3. **Tenha plano de rollback** com regras antigas
4. **Documente mudanças** para a equipe

## 📞 Suporte

Para dúvidas sobre as regras:

- Consulte a documentação do [Firebase Security Rules](https://firebase.google.com/docs/rules)
- Teste no [Rules Playground](https://firebase.google.com/docs/rules/simulator)
- Verifique logs no Firebase Console

---

**Segurança em primeiro lugar! 🛡️**
