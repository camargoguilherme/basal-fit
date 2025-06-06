# 👤 Funcionalidades de Perfil do Usuário - Basal Fit

## 📋 Resumo das Implementações

Foi implementado um sistema completo de gerenciamento de perfil do usuário no aplicativo Basal Fit, permitindo que os usuários personalizem suas informações pessoais e configurem sua experiência no app.

## 🆕 Novas Funcionalidades

### 1. **Tela de Perfil Completa**

- ✅ Upload de foto de perfil (câmera ou galeria)
- ✅ Edição de informações pessoais
- ✅ Alteração de senha
- ✅ Interface moderna e intuitiva

### 2. **Informações Pessoais**

- 📝 Nome completo (obrigatório)
- 🎂 Idade
- ⚤ Gênero (Masculino/Feminino)
- 📏 Altura (cm)
- ⚖️ Peso (kg)
- 🏃‍♂️ Nível de atividade física

### 3. **Upload de Foto de Perfil**

- 📷 Captura via câmera
- 🖼️ Seleção da galeria
- 🔄 Redimensionamento automático (512x512px)
- 🗜️ Compressão (70% qualidade)
- ☁️ Armazenamento no Firebase Storage

### 4. **Integração com Interface**

- 👋 Saudação personalizada na tela principal
- 🖼️ Foto de perfil no AppBar
- 🎨 Card de boas-vindas com nome do usuário
- 📱 Acesso rápido ao perfil pelo avatar

### 5. **Segurança**

- 🔐 Alteração de senha com reautenticação
- ✅ Validação de senhas (mínimo 6 caracteres)
- 🔒 Confirmação de senha obrigatória

## 📁 Arquivos Criados/Modificados

### Novos Arquivos:

- `lib/models/user_profile.dart` - Modelo de dados do perfil
- `lib/modules/home/profile_screen.dart` - Tela de perfil

### Arquivos Modificados:

- `pubspec.yaml` - Adicionadas dependências
- `lib/services/firebase_service.dart` - Serviços de perfil
- `lib/modules/home/home_screen.dart` - Interface personalizada
- `lib/modules/home/home_module.dart` - Rota do perfil
- `android/app/src/main/AndroidManifest.xml` - Permissões

## 📦 Dependências Adicionadas

```yaml
firebase_storage: ^11.6.0 # Upload de imagens
image_picker: ^1.0.7 # Seleção de imagens
permission_handler: ^11.3.0 # Gerenciamento de permissões
```

## 🔧 Permissões Android

```xml
<!-- Permissões para acesso à galeria e câmera -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="29" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

## 🎯 Como Usar

### Acessar o Perfil:

1. **Via Avatar**: Toque na foto de perfil no AppBar
2. **Via Menu**: Toque no card "Meu Perfil" na tela principal

### Alterar Foto de Perfil:

1. Na tela de perfil, toque na área da foto
2. Escolha entre "Câmera" ou "Galeria"
3. Selecione/capture a imagem
4. Toque em "Salvar Perfil"

### Alterar Senha:

1. Na tela de perfil, toque em "Alterar Senha"
2. Digite a senha atual
3. Digite e confirme a nova senha
4. Toque em "Alterar"

## 🔄 Fluxo de Dados

```
Usuário → Tela de Perfil → FirebaseService → Firebase Auth/Firestore/Storage
```

1. **Criação**: Perfil inicial criado no primeiro acesso
2. **Atualização**: Dados sincronizados em tempo real
3. **Upload**: Imagens armazenadas no Firebase Storage
4. **Segurança**: Reautenticação para alterações sensíveis

## 🎨 Interface

### Tela Principal:

- Saudação personalizada com nome do usuário
- Foto de perfil no AppBar (clicável)
- Card de boas-vindas estilizado

### Tela de Perfil:

- Design moderno e limpo
- Campos organizados logicamente
- Validações em tempo real
- Botões de ação destacados

## 🛡️ Validações

- ✅ Nome obrigatório
- ✅ Senha mínima de 6 caracteres
- ✅ Confirmação de senha
- ✅ Reautenticação para alterações
- ✅ Tratamento de erros

## 🚀 Próximos Passos Sugeridos

1. **Notificações**: Avisos de perfil incompleto
2. **Backup**: Sincronização com outros devices
3. **Privacidade**: Configurações de visibilidade
4. **Temas**: Personalização de cores
5. **Métricas**: Dashboard com progresso pessoal

## 🔧 Comandos para Execução

```bash
# Instalar dependências
flutter pub get

# Executar aplicação
flutter run

# Build para produção
flutter build apk --release
```

---

✅ **Status**: Funcionalidade implementada e pronta para uso!

🎯 **Resultado**: Sistema completo de perfil de usuário integrado ao Basal Fit.
