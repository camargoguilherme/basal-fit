# 🐛 Debug - Problemas de Perfil do Usuário

## ⚠️ Problemas Identificados e Soluções

### 1. **Tela fica em Loading Infinito**

#### ✅ **Soluções Implementadas:**

- ✅ Adicionado verificação de `mounted` antes de `setState`
- ✅ Garantia que `_isLoading = false` sempre execute no `finally`
- ✅ Separação de estado de upload (`_isUploadingImage`)
- ✅ Melhor tratamento de erros com logs detalhados

#### 🔍 **Como Verificar:**

```dart
// Logs aparecerão no console:
print('Iniciando upload da imagem...');
print('Upload concluído. URL: $imageUrl');
print('Salvando perfil no Firestore...');
print('Perfil salvo com sucesso!');
```

### 2. **Erro no Upload de Imagem**

#### 🛡️ **Possíveis Causas:**

1. **Regras do Firebase Storage não configuradas**
2. **Problema de permissões do Android**
3. **Arquivo de imagem corrompido**
4. **Problemas de conexão de rede**

#### ✅ **Soluções Implementadas:**

##### A) **Melhor Tratamento de Erros:**

```dart
// Verifica se arquivo existe
if (!await imageFile.exists()) {
  throw Exception('Arquivo de imagem não encontrado');
}

// Errors específicos
if (e.toString().contains('permission-denied')) {
  throw Exception('Erro de permissão: Verifique as regras do Firebase Storage');
} else if (e.toString().contains('network')) {
  throw Exception('Erro de conexão: Verifique sua internet');
}
```

##### B) **Metadata e Monitoramento:**

```dart
// Adiciona metadata
final metadata = SettableMetadata(
  contentType: 'image/jpeg',
  customMetadata: {
    'userId': _userId,
    'uploadDate': DateTime.now().toIso8601String(),
  },
);

// Monitora progresso
uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
  print('Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
});
```

##### C) **Interface Visual Melhorada:**

- ✅ Indicador de upload separado
- ✅ Feedback visual durante upload
- ✅ Desabilita interação durante upload

## 🔧 **Configurações Necessárias**

### 1. **Firebase Storage Rules**

**⚠️ IMPORTANTE:** Configure as regras no Firebase Console:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}.jpg {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow write: if resource == null ||
        (request.resource.size < 5 * 1024 * 1024 &&
         request.resource.contentType.matches('image/.*'));
    }
  }
}
```

**Como configurar:**

1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Selecione seu projeto
3. Vá em **Storage** > **Rules**
4. Cole as regras acima
5. Clique em **Publicar**

### 2. **Permissões Android** ✅ Já Configuradas

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.CAMERA" />
```

## 🧪 **Como Testar**

### Teste 1: Upload Básico

```bash
1. Abra a tela de perfil
2. Toque na foto de perfil
3. Escolha "Galeria"
4. Selecione uma imagem pequena (< 2MB)
5. Toque em "Salvar Perfil"
6. Verifique os logs no console
```

### Teste 2: Teste de Conectividade

```bash
1. Desabilite WiFi/dados
2. Tente fazer upload
3. Deve mostrar "Erro de conexão"
4. Reabilite conexão e tente novamente
```

### Teste 3: Teste de Arquivo Grande

```bash
1. Tente fazer upload de imagem > 5MB
2. Deve mostrar erro de tamanho/permissão
```

## 📊 **Logs de Debug**

### Logs Normais (Sucesso):

```
I/flutter: Verificando arquivo: /path/to/image.jpg
I/flutter: Iniciando upload para Firebase Storage...
I/flutter: Upload progress: 25%
I/flutter: Upload progress: 50%
I/flutter: Upload progress: 75%
I/flutter: Upload progress: 100%
I/flutter: Upload concluído. Obtendo URL de download...
I/flutter: URL de download obtida: https://firebasestorage...
I/flutter: Salvando perfil no Firestore...
I/flutter: Perfil salvo com sucesso!
```

### Logs de Erro Comum:

```
I/flutter: Erro detalhado no upload: [firebase_storage/unauthorized] User does not have permission to access this object.
```

## 🚨 **Problemas Conhecidos e Soluções**

### ❌ Problema: "permission-denied"

**Solução:** Configure as regras do Firebase Storage (ver seção acima)

### ❌ Problema: "network-request-failed"

**Solução:** Verifique conexão com internet

### ❌ Problema: "object-not-found"

**Solução:** Arquivo foi removido/movido da galeria

### ❌ Problema: Loading infinito

**Solução:** Implementada verificação de `mounted` e `finally` garantido

## 🔄 **Fluxo de Debug Passo-a-Passo**

1. **Verifique os Logs:**

   ```bash
   flutter logs --verbose
   ```

2. **Teste Conexão Firebase:**

   ```bash
   # Verifique se Firestore funciona
   # Tente salvar perfil SEM imagem primeiro
   ```

3. **Teste Upload Isolado:**

   ```bash
   # Use imagem pequena (< 1MB)
   # Formato JPEG
   ```

4. **Verifique Regras Firebase:**
   ```bash
   # Console Firebase > Storage > Rules
   # Deve permitir acesso ao próprio usuário
   ```

## ✅ **Checklist de Verificação**

- [ ] Regras do Firebase Storage configuradas
- [ ] Usuário autenticado no Firebase
- [ ] Permissões Android concedidas
- [ ] Internet funcionando
- [ ] Logs aparecendo no console
- [ ] Arquivo de imagem existe e é válido
- [ ] Tamanho da imagem < 5MB

---

## 💡 **Próximos Passos se Problemas Persistirem**

1. **Teste com regras permissivas temporariamente:**

   ```javascript
   match /{allPaths=**} {
     allow read, write: if request.auth != null;
   }
   ```

2. **Verifique configuração do Firebase:**

   - `google-services.json` atualizado
   - Firebase Storage habilitado no projeto

3. **Teste em dispositivo real:**
   - Emulador pode ter limitações de storage

---

🎯 **Resultado Esperado:** Upload de imagem funcionando e salvamento de perfil sem travamentos!
