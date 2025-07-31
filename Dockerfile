# ETAP 1: Budowanie aplikacji ("Builder")
# Używamy obrazu z pełnym JDK i Gradle, aby zbudować naszą aplikację.
FROM gradle:8.7-jdk21-jammy AS build

# Ustawiamy katalog roboczy wewnątrz kontenera budującego
WORKDIR /home/gradle/src

# Kopiujemy cały kontekst projektu do kontenera
COPY --chown=gradle:gradle . .

# Uruchamiamy budowanie Gradle WEWNĄTRZ kontenera.
# Ta komenda stworzy plik .jar w /home/gradle/src/build/libs/
RUN gradle build --no-daemon

# ETAP 2: Tworzenie finalnego, lekkiego obrazu ("Runner")
# Używamy minimalnego obrazu tylko z Javą (JRE), aby uruchomić aplikację.
FROM eclipse-temurin:21-jre-jammy

# Ustawiamy katalog roboczy w finalnym obrazie
WORKDIR /app

# Kopiujemy TYLKO zbudowany plik .jar z etapu "build".
# To jest kluczowy krok - nie kopiujemy nic z maszyny hosta, tylko z poprzedniego etapu.
COPY --from=build /home/gradle/src/build/libs/*.jar app.jar

# Informujemy Docker, że aplikacja będzie nasłuchiwać na porcie 8080
EXPOSE 8080

# Komenda, która zostanie uruchomiona przy starcie kontenera
ENTRYPOINT ["java", "-jar", "app.jar"]