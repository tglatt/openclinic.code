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
docker build -t openclinic-mysql ./docker
docker run -d -p 3306:3306 --name openclinic-db openclinic-mysql
```

La base de données est initialisée automatiquement avec le dump inclus.  
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
  Dockerfile            # Image MySQL
  dump.sql              # Données initiales
  mysql.cnf             # Configuration MySQL
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
docker build -t openclinic-mysql ./docker
docker run -d -p 3306:3306 --name openclinic-db openclinic-mysql
```
