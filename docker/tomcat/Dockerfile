# Stage 1 : build Maven
FROM maven:3.8.6-openjdk-8 AS build

WORKDIR /app

# Copier pom.xml et le repo local en premier pour profiter du cache Docker
COPY pom.xml .
COPY lib/local-maven-repo lib/local-maven-repo/

# Pré-télécharger les dépendances (couche cachée)
RUN mvn dependency:resolve -q

# Copier les sources et construire
COPY src src/
RUN mvn war:exploded -q

# Stage 2 : déploiement sur Tomcat
FROM tomcat:9.0-jdk8

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=build /app/target/openclinic-1.0-SNAPSHOT/ /usr/local/tomcat/webapps/code/

EXPOSE 8080
