# OpenClinic

## Prérequis

- Java 8 (Temurin recommandé)
- Maven 3.6+
- Docker
- IntelliJ IDEA avec le plugin [Smart Tomcat](https://plugins.jetbrains.com/plugin/9492-smart-tomcat)
- Tomcat 9 (`brew install tomcat@9` sur macOS)

---

## Démarrage

### 1. Cloner le projet

```bash
git clone <url-du-repo>
cd openclinic.code
```

### 2. Démarrer la base de données

```bash
docker build -t openclinic-mysql ./docker/mysql
docker run -d -p 3306:3306 --name openclinic-db openclinic-mysql
```

La base de données est initialisée automatiquement avec le dump inclus (et les scripts complémentaires comme `zz_nupsref.sql`).  
Connexion : `root / root`, port `3306`.

### 3. Construire le projet

```bash
mvn war:exploded
```

Cela compile le code et génère le répertoire déployable dans `target/openclinic-1.0-SNAPSHOT/`.

### 4. Configurer la run configuration IntelliJ

Ouvrir **Run → Edit Configurations**, créer une nouvelle configuration **Smart Tomcat** avec les paramètres suivants :

| Paramètre | Valeur |
|-----------|--------|
| Tomcat Server | Apache Tomcat 9 (chemin de votre installation) |
| Deployment Directory | `target/openclinic-1.0-SNAPSHOT` |
| Context Path | `/code` |
| Module | `openclinic.code` |

Dans l'onglet **Before Launch**, ajouter : **Run Maven Goal** → `war:exploded`

### 5. Lancer l'application

Démarrer la configuration depuis IntelliJ. L'application est accessible à :

```
http://localhost:8080/code
```

---

## Alternative : tout lancer avec Docker Compose

Pour un environnement de développement complet (base de données + application) sans IntelliJ :

```bash
mvn war:exploded
docker compose -f docker-compose.dev.yml up -d
```

- `db` : construit depuis `docker/mysql`, healthcheck MySQL, données persistées dans le volume `mysql_data`.
- `app` : Tomcat 9 qui monte en live `target/openclinic-1.0-SNAPSHOT` ainsi que `docker/context.dev.xml` (datasources pointant vers le service `db`).

L'application est accessible sur `http://localhost:8080/code` et la base sur `localhost:3306`.

Après une modification Java, relancer `mvn war:exploded` : Tomcat recharge le déploiement monté en volume.

Pour repartir d'une base vierge :

```bash
docker compose -f docker-compose.dev.yml down -v
docker compose -f docker-compose.dev.yml up -d --build
```

---

## Structure du projet

```
src/
  main/
    java/               # Code source Java
    webapp/             # Ressources web (JSP, HTML, WEB-INF/)
      META-INF/
        context.xml     # Configuration JNDI (datasources MySQL)
      WEB-INF/
        web.xml         # Descripteur de déploiement
    resources/          # Fichiers de config (log4j.properties, logback.xml)
docker/
  mysql/
    Dockerfile          # Image MySQL
    00_init.sql         # Création de l'utilisateur applicatif
    dump.sql            # Données initiales
    zz_nupsref.sql      # Table nupsref (absente du dump, exécutée après celui-ci)
    mysql.cnf           # Configuration MySQL
  tomcat/
    Dockerfile          # Image Tomcat (build Maven multi-stage + déploiement)
  context.dev.xml       # context.xml pour docker-compose (datasources -> service "db")
docker-compose.dev.yml  # Stack complète db + app pour le développement
lib/
  local-maven-repo/     # JARs propriétaires (Primrose, Aspose, etc.)
pom.xml                 # Dépendances Maven
```

---

## Base de données

| Pool | Base | Usage |
|------|------|-------|
| `openclinic` | `openclinic_dbo` | Données cliniques principales |
| `admin` | `ocadmin_dbo` | Administration, utilisateurs |
| `stats` | `ocstats_dbo` | Statistiques |
| `ikirezi` | `ikirezi` | Module Ikirezi |

Toutes les connexions sont configurées dans `src/main/webapp/META-INF/context.xml`.

---

## Connexion base de données

```
Host     : localhost
Port     : 3306
User     : root
Password : root
```

---

## Workflow de développement

Après chaque modification Java, relancer :

```bash
mvn war:exploded
```

puis redémarrer Tomcat depuis IntelliJ.

Pour reconstruire la base depuis zéro :

```bash
docker rm -f openclinic-db
docker volume prune
docker build -t openclinic-mysql ./docker/mysql
docker run -d -p 3306:3306 --name openclinic-db openclinic-mysql
```
