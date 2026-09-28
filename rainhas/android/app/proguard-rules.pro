# O SDK de anúncios do Google traz o WorkManager, que usa o Room. O Room cria
# o banco de dados por reflexão, chamando o construtor vazio da classe gerada
# (ex.: WorkDatabase_Impl). Sem esta regra o R8 remove esse construtor e o app
# fecha ao abrir, no build de release.
-keep class * extends androidx.room.RoomDatabase {
    <init>();
}
