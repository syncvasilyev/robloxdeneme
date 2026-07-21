# robloxdeneme

Bu depo, Rojo ile Roblox Studio'ya senkronize edilen bir Roblox oyun projesidir.

## Kurulum (her iki geliştirici de aynı adımları izler)

1. [Aftman](https://github.com/LPGhatguy/aftman) kur (araç sürüm yöneticisi), sonra bu depo kökünde:
   ```
   aftman install
   ```
   Bu, `aftman.toml` içinde pinlenen Rojo CLI sürümünü kurar.

2. Roblox Studio'ya [Rojo eklentisini](https://create.roblox.com/store/asset/13916111004/Rojo) kur.

3. Depoyu klonla ve senkronizasyon sunucusunu başlat:
   ```
   git clone <repo-url>
   cd robloxdeneme
   rojo serve
   ```

4. Roblox Studio'da boş bir place aç, Rojo eklentisinden "Connect" butonuna bas (varsayılan port: 34872).

## İş akışı

- Kod bu depoda `.luau` dosyaları olarak tutulur (Studio `.rbxl` dosyası değil).
- Değişiklik yapan kişi commit atıp `git push` eder.
- Diğer kişi `git pull` çekip Rojo ile tekrar senkronize eder.
- Aynı anda canlı ortak düzenleme istiyorsanız Roblox'un **Team Create** özelliğini (Configure Place → Collaborators, ücretsizdir) Rojo ile birlikte kullanabilirsiniz.
- Oyunun kendisi (gamepassler, yayınlama, DataStore) hangi hesapta/Group'ta barındırılacaksa, o hesap sahibi diğerini Studio'da collaborator olarak eklemeli.

## Klasör yapısı

```
src/
  ReplicatedStorage/Modules/   -- paylaşılan modüller (Theme, Remotes, ...)
  ServerScriptService/Server/  -- sunucu tarafı sistemler ve veri katmanı
  StarterPlayer/StarterPlayerScripts/Client/ -- istemci tarafı sistemler ve UI
```
