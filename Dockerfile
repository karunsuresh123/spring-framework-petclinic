# Base image with JDK for compiling and running the Maven build
FROM eclipse-temurin:17-jdk-jammy as build
WORKDIR /app

# Copy Maven configuration files
COPY .mvn/ .mvn
COPY mvnw pom.xml ./

# Resolve all dependencies
RUN ./mvnw dependency:resolve

# Copy the project source code
COPY src ./src

# Build the application, skipping tests to speed up the build
RUN ./mvnw package -Dmaven.test.skip=true

# Optionally, list the contents of /app/target to verify the WAR file exists
RUN ls /app/target

# Production stage with Tomcat
FROM tomcat:9-jdk17-corretto as production
EXPOSE 8080

# Remove default web applications from Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file from the build stage to the Tomcat webapps directory
# Ensure that the WAR file is indeed being copied
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# List webapps directory to verify the WAR file is in place
RUN ls /usr/local/tomcat/webapps

# Start Tomcat server
CMD ["catalina.sh", "run"]
